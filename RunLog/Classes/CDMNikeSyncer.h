//
//  CDMNikeSyncer.h
//  RunLog
//
//  Created by Uwe Hoffmann on 11/4/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RunLogAppDelegate;

@interface CDMNikeSyncer : NSObject {
@private
  NSUInteger nikeId;
  RunLogAppDelegate *appDelegate;
  BOOL isSyncing;
  NSString *syncStatus;
  NSMutableArray *runsToSync;
  NSUInteger syncCursor;
}

@property (nonatomic, readonly) BOOL isSyncing;
@property (nonatomic, readonly) NSString *syncStatus;


- (id)init;
- (void)setNikeId:(NSUInteger)anId;

- (void)sync;

@end
