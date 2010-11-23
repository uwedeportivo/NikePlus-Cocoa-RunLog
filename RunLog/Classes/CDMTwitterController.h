//
//  CDMTwitterController.h
//  RunLog
//
//  Created by Uwe Hoffmann on 11/16/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OAuthConsumer.h"
#import "MGTwitterEngine.h"
#import "MGTemplateEngine.h"
#import "MGTwitterEngineDelegate.h"


@interface CDMTwitterController : NSObject <MGTwitterEngineDelegate> {
@private
  NSWindow *window;
  OAToken *twitterAccessToken;
  OAToken *twitterRequestToken;
  NSWindow *twitterProgress;
  NSTextField *twitterProgressLabel;
  NSProgressIndicator *twitterProgressIndicator;
  OADataFetcher *twitterDataFetcher;  
  MGTwitterEngine *twitterEngine;
  NSWindow *twitterPin;
  NSTextField *twitterPinTextField;
  NSButton *twitterPinStoreInKeychain;
  MGTemplateEngine *templateEngine;
  NSString *templatePath;
  NSNumberFormatter *numberFormatter;
  NSDateFormatter *dateFormatter;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *twitterProgress;
@property (assign) IBOutlet NSTextField *twitterProgressLabel;
@property (assign) IBOutlet NSProgressIndicator *twitterProgressIndicator;
@property (assign) IBOutlet NSWindow *twitterPin;
@property (assign) IBOutlet NSTextField *twitterPinTextField;
@property (assign) IBOutlet NSButton *twitterPinStoreInKeychain;

- (IBAction)cancelTwitterProgress:(id)sender;
- (IBAction)tweet:(id)sender;

- (IBAction)donePin:(id)sender;

- (void)didEndSheet:(NSWindow *)sheet 
         returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo;

- (void)twitterRequestTokenTicket:(OAServiceTicket *)ticket 
                didFinishWithData:(NSData *)data;

- (void)twitterRequestTokenTicket:(OAServiceTicket *)ticket
                 didFailWithError:(NSError *)error;

- (void)twitterAccessTokenTicket:(OAServiceTicket *)ticket 
                didFinishWithData:(NSData *)data;

- (void)twitterAccessTokenTicket:(OAServiceTicket *)ticket
                 didFailWithError:(NSError *)error;


@end
