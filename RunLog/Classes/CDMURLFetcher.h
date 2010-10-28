//
//  CDMURLFetcher.h
//  BlackPearl
//
//  Created by Uwe Hoffmann on 6/18/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CDMURLFetcher : NSObject {
@private
  void (^completionBlock)(NSData *data, NSError *error);
  NSMutableData *dataBuffer;
}

+ (void)fetch:(NSURLRequest *)request 
      completionHandler:(void (^)(NSData *data, NSError *error))handler;

@end
