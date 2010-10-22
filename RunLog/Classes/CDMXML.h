//
//  CDMXML.h
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSXMLDocument (CDMXML)

- (NSString *)textAtTag:(NSString *)tag error:(NSError **)error;
- (NSArray *)commaSeparatedTextAtTag:(NSString *)tag error:(NSError **)error;

@end
