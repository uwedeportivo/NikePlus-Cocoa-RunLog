//
//  CDMXML.m
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import "CDMXML.h"

@implementation NSXMLDocument (CDMXML)

- (NSString *)textAtTag:(NSString *)tag error:(NSError **)error {
  NSArray *nodes = [self nodesForXPath:[NSString stringWithFormat:@"//%@", tag] error:error];
  NSMutableString *buffer = [NSMutableString string];
  
  if ([nodes count] > 0) {
    for (id node in [[nodes objectAtIndex:0] children]) {
      if ([node isMemberOfClass:[NSXMLNode class]] && [node kind] == NSXMLTextKind) {
        [buffer appendString:[node stringValue]];
      } 
    }
  }
  return buffer;
}

- (NSArray *)commaSeparatedTextAtTag:(NSString *)tag error:(NSError **)error {
  NSMutableCharacterSet *separator = [[[NSMutableCharacterSet alloc] init] autorelease];
  
  [separator formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  NSRange commaRange;
  
  commaRange.location = (unsigned int)',';
  commaRange.length = 1;
  
  [separator addCharactersInRange:commaRange];
  
  return [[[self textAtTag:tag error:error] componentsSeparatedByCharactersInSet:separator] 
          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
}

@end
