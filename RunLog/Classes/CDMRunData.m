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
  4.839414490382868e-2, 5.7938310552296556e-2, 6.664492057835994e-2, 7.365402806066466e-2,
  7.820853879509118e-2, 7.978845608028655e-2, 7.820853879509118e-2, 7.365402806066466e-2,
  6.664492057835994e-2, 5.7938310552296556e-2, 4.839414490382868e-2
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
  
  double *cv = CDMNumericCorrelate(values, count, CDMMovingAverageKernel, 6);
  free(values);
  values = cv;
  count = count - 6;
  
  cv = CDMNumericConvolve(values, count, CDMGaussianKernel, 11);
  free(values);
  values = cv;
  count = count - 11;
  
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
            minimumValueForYAxis, maximumValueForYAxis;

- (id)initWithExtendedData:(NSArray *)extendedData {
  if ((self = [super init])) {
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
