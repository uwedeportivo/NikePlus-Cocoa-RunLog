//
//  CDMURLFetcher.m
//  BlackPearl
//
//  Created by Uwe Hoffmann on 6/18/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import "CDMURLFetcher.h"

@implementation CDMURLFetcher

- (id)initWithCompletionHandler:(void (^)(NSData *data, NSError *error))handler {
  if ((self = [super init])) {
    completionBlock = [handler copy];
  }
    
  return self;
}

- (void)dealloc {
  [completionBlock release];
  [dataBuffer release];
  [super dealloc];
}

+ (void)fetch:(NSURLRequest *)request 
      completionHandler:(void (^)(NSData *data, NSError *error))handler {
  id delegate = [[self alloc] initWithCompletionHandler:handler];
  
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
  
  [connection start];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  completionBlock(nil, error);
  [self release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [dataBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  dataBuffer = [[NSMutableData alloc] init];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  completionBlock(dataBuffer, nil);
  [self release];
}

@end
