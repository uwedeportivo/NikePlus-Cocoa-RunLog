//
//  CDMRunData.h
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CDMRunData : NSObject {
@private
  NSArray *data;
}

- (id)initWithExtendedData:(NSArray *)extendedData;

- (NSArray *)data;


@end
