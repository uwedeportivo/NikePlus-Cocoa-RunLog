//
//  CDMRunData.m
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import "CDMRunData.h"
#import "CDMNumericLists.h"

const double CDMGaussianKernel[] = { 
  0.0663417, 0.0794254, 0.091361, 0.10097, 0.107213, 0.109379,
  0.107213, 0.10097, 0.091361, 0.0794254, 0.0663417
};

const double CDMMovingAverageKernel[] = {
  0.16666666666666666,0.16666666666666666,0.16666666666666666,
  0.16666666666666666,0.16666666666666666,0.16666666666666666
};

NSArray *CDMTransformAndSmoothRunData(NSArray *extendedData) {
  NSUInteger count = [extendedData count];
  double *values = (double *)malloc(count * sizeof(double));
  
  [extendedData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    values[idx] = [obj doubleValue];
  }];

  count = CDMNumericDiff(values, count);
  count = CDMNumericFilterZero(values, count);
  
  CDMNumericMap(values, count, ^(double x) {
    return 1.0 / (6.0 * x);
  });
    
  count = CDMNumericCorrelate(values, count, CDMMovingAverageKernel, 6);
  count = CDMNumericConvolve(values, count, CDMGaussianKernel, 11);
  
  double min = CDMNumericMin(values, count);
  double max = CDMNumericMax(values, count);
  
  CDMNumericMap(values, count, ^(double x) {
    return min + max - x;
  });
  

  id *temp = (id *)malloc(count * sizeof(id));
  
  for (NSUInteger i = 0; i < count; i++) {
    temp[i] = [NSNumber numberWithDouble:values[i]];
  }
  NSArray *result = [NSArray arrayWithObjects:temp count:count];
  
  free(values);
  free(temp);
  return result;
}

@implementation CDMRunData

@synthesize minimumValueForXAxis, maximumValueForXAxis,
            minimumValueForYAxis, maximumValueForYAxis, runId;

- (id)initWithExtendedData:(NSArray *)extendedData runId:(NSNumber *)anId {
  if ((self = [super init])) {
    runId = [anId retain];
    yData = [CDMTransformAndSmoothRunData(extendedData) retain];
    xData = CDMNumericArrayFromRange(NSMakeRange(0, [yData count]));
    minimumValueForXAxis = 0.0;
    maximumValueForXAxis = (double) [yData count];
    minimumValueForYAxis = [[yData objectAtIndex:0] doubleValue];
    maximumValueForYAxis = minimumValueForYAxis;
    for (NSNumber *value in yData) {
      double v = [value doubleValue];
      
      if (minimumValueForYAxis > v) {
        minimumValueForYAxis = v;
      }
      
      if (maximumValueForYAxis < v) {
        maximumValueForYAxis = v;
      }
    }
  }
  
  return self;
}

- (void)dealloc {
  [runId release];
  [yData release];
  [xData release];
  [super dealloc];
}

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
  return [yData count];
}

- (NSArray *)numbersForPlot:(CPPlot *)plot
                      field:(NSUInteger)fieldEnum
          recordIndexRange:(NSRange)indexRange {
  if (fieldEnum == CPScatterPlotFieldX) {
    return [xData subarrayWithRange:indexRange];
  } else {
    return [yData subarrayWithRange:indexRange];
  }
}

@end
