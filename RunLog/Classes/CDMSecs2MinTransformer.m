//
//  CDMSecs2MinTransformer.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/9/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMSecs2MinTransformer.h"


@implementation CDMSecs2MinTransformer

+ (Class)transformedValueClass {
  return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;   
}

- (id)transformedValue:(id)value {  
  if (value == nil) return nil;
  
  if (![value respondsToSelector: @selector(doubleValue)]) {
    [NSException raise:NSInternalInconsistencyException format:@"Value does not respond to -doubleValue.  No idea what to do. (Value is an instance of %@).",
     [value class]];
  }
  
  double secs = [value doubleValue];
  double mins = secs / 60000.0;
  
  return [NSNumber numberWithDouble:mins];
}

@end
