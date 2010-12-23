//
//  CDMTwitterController.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/16/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMTwitterController.h"
#import "CDMTwitter.h"
#import "OAToken_KeychainExtensions.h"
#import "RunLogAppDelegate.h"
#import "CDMNikeRunAccessors.h"
#import "ICUTemplateMatcher.h"

@interface CDMTwitterController()

- (void)tweet;

@end

@implementation CDMTwitterController

@synthesize window, twitterProgress, twitterProgressLabel, twitterProgressIndicator, twitterPin, twitterPinTextField, twitterPinStoreInKeychain, twitterBubble, twitterConfirm;

- (id)init {
  if ((self = [super init])) {
    twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
    
    [twitterEngine setConsumerKey:kCDMTwitterConsumerKey 
                           secret:kCDMTwitterConsumerSecret];
    
    twitterAccessToken = [[OAToken alloc] initWithKeychainUsingAppName:kCDMAppName
                                                   serviceProviderName:kCDMTwitterServiceProviderName];
    if (twitterAccessToken != nil) {
      [twitterEngine setAccessToken:twitterAccessToken];
    }
    
    templateEngine = [[MGTemplateEngine templateEngine] retain];
    [templateEngine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:templateEngine]];    
    templatePath = [[[NSBundle mainBundle] pathForResource:@"tweet" ofType:@"txt"] retain];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setFormat:@"0.00"];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy, HH:mm:ss a"];
  }
  
  return self;
}

- (void)dealloc {
  [dateFormatter release];
  [numberFormatter release];
  [templatePath release];
  [templateEngine release];
  [twitterRequestToken release];
  [twitterAccessToken release];
  [twitterEngine release];
  [super dealloc];
}

- (IBAction)tweet:(id)sender {
  RunLogAppDelegate *appDelegate = 
     (RunLogAppDelegate *)[[NSApplication sharedApplication] delegate];
  
  if ([[appDelegate.runsController selectedObjects] count] == 0) {
    return;
  }
  if (twitterAccessToken == nil) {
    [twitterProgressLabel setStringValue:@"Acquiring request token from Twitter"];
    [twitterProgressIndicator startAnimation:self];
    [NSApp beginSheet: twitterProgress
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:kCDMTwitterConsumerKey
                                                     secret:kCDMTwitterConsumerSecret] autorelease];
    
    twitterDataFetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                    consumer:consumer
                                                                       token:nil
                                                                       realm:nil
                                                           signatureProvider:nil] autorelease];
    
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"Getting request token...");
    
    [twitterDataFetcher fetchDataWithRequest:request 
                                    delegate:self
                           didFinishSelector:@selector(twitterRequestTokenTicket:didFinishWithData:)
                             didFailSelector:@selector(twitterRequestTokenTicket:didFailWithError:)];
  } else {
    [self tweet];
  }
}

- (IBAction)cancelTwitterProgress:(id)sender {
  [NSApp endSheet:twitterProgress];
}

- (IBAction)cancelTwitterConfirm:(id)sender {
  [NSApp endSheet:twitterConfirm];
}

- (void)didEndSheet:(NSWindow *)sheet 
         returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo {
  if (sheet == twitterProgress || sheet == twitterConfirm) {
    [sheet orderOut:self];
  } else if (sheet == twitterPin) {
    [twitterPin orderOut:self];
    [twitterProgressLabel setStringValue:@"Acquiring access token from Twitter"];
    [twitterProgressIndicator startAnimation:self];
    [NSApp beginSheet: twitterProgress
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:kCDMTwitterConsumerKey
                                                     secret:kCDMTwitterConsumerSecret] autorelease];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    
    [twitterRequestToken setVerifier:[twitterPinTextField stringValue]];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:twitterRequestToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"Getting access token...");
    
    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(twitterAccessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(twitterAccessTokenTicket:didFailWithError:)];
  }
}

- (void)twitterRequestTokenTicket:(OAServiceTicket *)ticket 
                didFinishWithData:(NSData *)data {
  [NSApp endSheet:twitterProgress];
	if (ticket.didSucceed) {
		NSString *responseBody = [[[NSString alloc] initWithData:data 
                                                    encoding:NSUTF8StringEncoding] autorelease];
		twitterRequestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
		NSLog(@"Got request token. Redirecting to twitter auth page...");
		
		NSString *address = [NSString stringWithFormat:
                         @"https://api.twitter.com/oauth/authorize?oauth_token=%@",
                         twitterRequestToken.key];
		
		NSURL *url = [NSURL URLWithString:address];
		[[NSWorkspace sharedWorkspace] openURL:url];
    
    [NSApp beginSheet: twitterPin
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
	}
}

- (void)twitterRequestTokenTicket:(OAServiceTicket *)ticket
                 didFailWithError:(NSError *)error {
  [NSApp endSheet:twitterProgress];
	NSLog(@"Getting request token failed: %@", [error localizedDescription]);
}

- (IBAction)donePin:(id)sender {
  [NSApp endSheet:twitterPin];
}

- (void)twitterAccessTokenTicket:(OAServiceTicket *)ticket 
               didFinishWithData:(NSData *)data {
  [NSApp endSheet:twitterProgress];
  if (ticket.didSucceed) {
    NSString *responseBody = [[NSString alloc] initWithData:data 
                                                   encoding:NSUTF8StringEncoding];
    
    twitterAccessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [twitterEngine setAccessToken:twitterAccessToken];
    
    // TODO(uwe): respect store in keychain check box
    [twitterAccessToken storeInDefaultKeychainWithAppName:kCDMAppName 
                                      serviceProviderName:kCDMTwitterServiceProviderName];
    [self tweet];
  }
}

- (void)twitterAccessTokenTicket:(OAServiceTicket *)ticket
                didFailWithError:(NSError *)error {
  [NSApp endSheet:twitterProgress];
	NSLog(@"Getting access token failed: %@", [error localizedDescription]);
  
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
  [NSApp endSheet:twitterProgress];
  NSLog(@"Tweeting succeeded");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
  [NSApp endSheet:twitterProgress];
  NSLog(@"Tweeting failed: %@", [error localizedDescription]);
}

- (void)tweet {
  RunLogAppDelegate *appDelegate = 
  (RunLogAppDelegate *)[[NSApplication sharedApplication] delegate];
  
  NSManagedObject *selectedRun = 
  (NSManagedObject *)[[appDelegate.runsController selectedObjects] objectAtIndex:0];
  
  double secs = [selectedRun.duration doubleValue];
  double mins = secs / 60000.0;
  
  NSString *distanceStr = [numberFormatter stringFromNumber:selectedRun.distance];
  NSString *caloriesStr = [numberFormatter stringFromNumber:selectedRun.calories];
  NSString *minsStr = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:mins]];
  NSString *startTimeStr = [dateFormatter stringFromDate:selectedRun.startTime];
  
  NSDictionary *variables = 
  [NSDictionary dictionaryWithObjectsAndKeys:
   distanceStr, @"distance", 
   caloriesStr, @"calories", 
   minsStr, @"duration",
   startTimeStr, @"startTime",
   nil];
  
  NSString *tweet = 
  [templateEngine processTemplateInFileAtPath:templatePath withVariables:variables];
  
  NSLog(@"Tweeting %@", tweet);

  [twitterBubble setStringValue:tweet];
  
  [NSApp beginSheet: twitterConfirm
   modalForWindow: window
   modalDelegate: self
   didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
   contextInfo: tweet];
}

- (IBAction)confirmTweet:(id)sender {
  [NSApp endSheet:twitterConfirm];
  NSString *tweet = [twitterBubble stringValue];
  NSLog(@"Tweeting %@", tweet);
  
  [twitterProgressLabel setStringValue:@"Tweeting..."];
  [twitterProgressIndicator startAnimation:self];
  [NSApp beginSheet: twitterProgress
     modalForWindow: window
      modalDelegate: self
     didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
        contextInfo: nil];
  [twitterEngine sendUpdate:tweet];
}

@end
