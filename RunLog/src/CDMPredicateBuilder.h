//
//  CDMPredicateBuilder.h
//  RunLog
//
//  Created by Uwe Hoffmann on 12/21/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ParseKit/ParseKit.h>

@interface CDMPredicateBuilder : NSObject {
@private
  PKParser *parser;
  NSEntityDescription *entity;
}

- (id)initWithEntity:(NSEntityDescription *)anEntity;
- (NSFetchRequest *)buildFromQuery:(NSString *)query;

@end
