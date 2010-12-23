//
//  CDMNumericLists.h
//  RunLog
//
//  Created by Uwe Hoffmann on 10/25/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSUInteger CDMNumericConvolve(double *values, NSUInteger valuesSize,
                                     const double kernel[], NSUInteger kernelSize);

extern NSUInteger CDMNumericCorrelate(double *values, NSUInteger valuesSize,
                                      const double kernel[], NSUInteger kernelSize);

extern NSUInteger CDMNumericDiff(double *values, NSUInteger valuesSize);

extern NSUInteger CDMNumericFilterZero(double *values, NSUInteger valuesSize);

extern double CDMNumericMax(double *values, NSUInteger valuesSize);

extern double CDMNumericMin(double *values, NSUInteger valuesSize);

extern void CDMNumericMap(double *values, NSUInteger valuesSize,
                          double (^block)(double));

extern NSArray *CDMNumericArrayFromRange(NSRange range);
