//
//  CDMDateTime.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/4/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMDateTime.h"

static NSDateFormatter *dateFormatter;

NSDate *CDMParseDateString(NSString *dateString) {
  NSString *hack = [dateString stringByReplacingOccurrencesOfString:@":00" withString:@"00"];
  
  if (dateFormatter == nil) {
    NSLocale *enUSPOSIXLocale;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    assert(dateFormatter != nil);
    
    enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    assert(enUSPOSIXLocale != nil);
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  }
  
  return [dateFormatter dateFromString:hack];
}