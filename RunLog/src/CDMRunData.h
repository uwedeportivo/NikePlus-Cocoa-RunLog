//
//  CDMRunData.h
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CDMRunData : NSObject <CPPlotDataSource> {
@private
  NSArray *yData;
  NSArray *flippedYData;
  NSArray *xData;
  double minimumValueForXAxis;
  double maximumValueForXAxis;
  double minimumValueForYAxis;
  double maximumValueForYAxis;
  NSNumber *runId;
}

- (id)initWithExtendedData:(NSArray *)extendedData runId:(NSNumber *)anId;

- (void)flipYForRangeMin:(double)minY max:(double)maxY;

@property (readonly, nonatomic) double minimumValueForXAxis;
@property (readonly, nonatomic) double maximumValueForXAxis;
@property (readonly, nonatomic) double minimumValueForYAxis;
@property (readonly, nonatomic) double maximumValueForYAxis;
@property (readonly, nonatomic) NSNumber *runId;

@end
