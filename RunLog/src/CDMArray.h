//
//  CDMArray.h
//  RunLog
//
//  Created by Uwe Hoffmann on 10/25/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (CDMArray)

- (NSArray *)map:(id (^)(id object))block;

@end
