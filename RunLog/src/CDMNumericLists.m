//
//  CDMNumericLists.m
//  RunLog
//
//  Created by Uwe Hoffmann on 10/25/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMNumericLists.h"

NSUInteger CDMNumericConvolve(double *values, NSUInteger valuesSize,
                              const double kernel[], NSUInteger kernelSize) {
  if (valuesSize < kernelSize) {
    return valuesSize;
  }
  
  NSUInteger n = valuesSize - kernelSize;
  
  for (NSUInteger i = 0; i < n; i++) {
    double accumulator = 0.0;
    
    for (NSUInteger j = 0; j < kernelSize; j++) {
      accumulator += values[i + j] * kernel[kernelSize - j - 1];
    }
    values[i] = accumulator;
  }
  return n;
}

NSUInteger CDMNumericCorrelate(double *values, NSUInteger valuesSize,
                               const double kernel[], NSUInteger kernelSize) {
  if (valuesSize < kernelSize) {
    return valuesSize;
  }
  
  NSUInteger n = valuesSize - kernelSize;
  
  for (NSUInteger i = 0; i < n; i++) {
    double accumulator = 0.0;
    
    for (NSUInteger j = 0; j < kernelSize; j++) {
      accumulator += values[i + j] * kernel[j];
    }
    values[i] = accumulator;
  }
  return n;
}

NSUInteger CDMNumericDiff(double *values, NSUInteger valuesSize) {    
  for (NSUInteger i = 0; i < valuesSize - 1; i++) {
    values[i] = values[i + 1] - values[i];
  }
  return valuesSize - 1;
}

NSUInteger CDMNumericFilterZero(double *values, NSUInteger valuesSize) {
  NSUInteger numberOfZeros = 0;
  
  for (NSUInteger i = 0; i < valuesSize; i++) {
    if (values[i] != 0.0) {
      if (numberOfZeros > 0) {
        values[i - numberOfZeros] = values[i];
      }
    } else {
      numberOfZeros++;
    }
  }
  return valuesSize - numberOfZeros;
}

double CDMNumericMax(double *values, NSUInteger valuesSize) {
  if (valuesSize == 0) {
    return 0.0;
  }
  
  double maxValue = values[0];
  for (NSUInteger i = 1; i < valuesSize; i++) {
    if (maxValue < values[i]) {
      maxValue = values[i];
    }
  }
  return maxValue;
}

double CDMNumericMin(double *values, NSUInteger valuesSize) {
  if (valuesSize == 0) {
    return 0.0;
  }
  
  double minValue = values[0];
  for (NSUInteger i = 1; i < valuesSize; i++) {
    if (minValue > values[i]) {
      minValue = values[i];
    }
  }
  return minValue;
}

void CDMNumericMap(double *values, NSUInteger valuesSize, double (^block)(double)) {
  for (NSUInteger i = 0; i < valuesSize; i++) {
    values[i] = block(values[i]);
  }
}

NSArray *CDMNumericArrayFromRange(NSRange range) {
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:range.length];
  
  for (NSUInteger i = 0; i < range.length; i++) {
    [result addObject:[NSNumber numberWithDouble:(double) (range.location + i)]];
  }
  return result;
}

