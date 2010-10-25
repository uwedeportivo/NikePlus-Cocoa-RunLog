//
//  CDMArray.m
//  RunLog
//
//  Created by Uwe Hoffmann on 10/25/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMArray.h"


@implementation NSArray (CDMArray)

- (NSArray *)map:(id (^)(id object))block {
  NSUInteger count = [self count];
  id *temp = (id *)malloc(count * sizeof(id));
  
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    temp[idx] = [block(obj) retain];
  }];
  
  NSUInteger i;
  NSArray *result = [NSArray arrayWithObjects:temp count:count];
  for (i=0; i < count; i++) [temp[i] release];
  free(temp);
  return result;
}

@end
