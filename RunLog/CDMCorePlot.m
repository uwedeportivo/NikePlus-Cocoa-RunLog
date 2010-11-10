//
//  CDMCorePlot.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/4/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMCorePlot.h"

static NSArray *distinctColors;

CPXYGraph *CDMCreateGraph(NSArray *rds) {
  CDMRunData *oneRunData = [rds objectAtIndex:0];
  
  double minimumValueForXAxis = oneRunData.minimumValueForXAxis;
  double maximumValueForXAxis = oneRunData.maximumValueForXAxis;
  double minimumValueForYAxis = oneRunData.minimumValueForYAxis;
  double maximumValueForYAxis = oneRunData.maximumValueForYAxis;
  
  for (CDMRunData *runData in rds) {
    if (minimumValueForXAxis > runData.minimumValueForXAxis) {
      minimumValueForXAxis = runData.minimumValueForXAxis;
    }
    if (maximumValueForXAxis < runData.maximumValueForXAxis) {
      maximumValueForXAxis = runData.maximumValueForXAxis;
    }
    if (minimumValueForYAxis > runData.minimumValueForYAxis) {
      minimumValueForYAxis = runData.minimumValueForYAxis;
    }
    if (maximumValueForYAxis < runData.maximumValueForYAxis) {
      maximumValueForYAxis = runData.maximumValueForYAxis;
    }
  }

  CPXYGraph *graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
  
  CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
  [graph applyTheme:theme]; 
  
  [graph setPaddingLeft:0];
  [graph setPaddingTop:0];
  [graph setPaddingRight:0];
  [graph setPaddingBottom:0];
  
  graph.plotAreaFrame.paddingTop = 20.0;
  graph.plotAreaFrame.paddingBottom = 60.0;
  graph.plotAreaFrame.paddingLeft = 80.0;
  graph.plotAreaFrame.paddingRight = 20.0;
  graph.plotAreaFrame.cornerRadius = 10.0;
  
  // Setup plot space
  CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
  plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForXAxis) length:CPDecimalFromFloat(maximumValueForXAxis - minimumValueForXAxis)];
  plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForYAxis) length:CPDecimalFromFloat(maximumValueForYAxis - minimumValueForYAxis)];
  
  // Grid line styles
  CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
  majorGridLineStyle.lineWidth = 0.75;
  majorGridLineStyle.lineColor = [[CPColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
  
  CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
  minorGridLineStyle.lineWidth = 0.25;
  minorGridLineStyle.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.1];    
  
  CPLineStyle *majorGridLineStyleSim = [CPLineStyle lineStyle];
  majorGridLineStyleSim.lineWidth = 0.75;
  majorGridLineStyleSim.lineColor = [[CPColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
  
  CPLineStyle *minorGridLineStyleSim = [CPLineStyle lineStyle];
  minorGridLineStyleSim.lineWidth = 0.25;
  minorGridLineStyleSim.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.1];    
  
  CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
  CPXYAxis *x = axisSet.xAxis;
  
  CPConstraints constraints = {CPConstraintFixed,CPConstraintFixed};
  x.isFloatingAxis = YES;
  x.constraints = constraints;
  
  x.labelingPolicy = CPAxisLabelingPolicyNone;
  x.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
  x.minorTicksPerInterval = 4;
  x.preferredNumberOfMajorTicks = 9;
  x.majorGridLineStyle = majorGridLineStyle;
  x.minorGridLineStyle = minorGridLineStyle;
  x.labelOffset = 10.0;
  x.title = @"Time (min)";
  x.titleOffset = 30.0;
  
  NSMutableSet *labelSet = [NSMutableSet set];
  NSMutableSet *majorTickSet = [NSMutableSet set];
  for (NSUInteger i = 0; i < 11; i++) {
    double locationValue = minimumValueForXAxis + 
    i * (maximumValueForXAxis - minimumValueForXAxis) / 10;
    double labelValue = locationValue / 6.0;
    CPAxisLabel *newLabel = [[CPAxisLabel alloc] 
                             initWithText:
                             [x.labelFormatter stringFromNumber:[NSNumber numberWithDouble:labelValue]] 
                             textStyle:x.labelTextStyle];
    newLabel.tickLocation = 
    [[NSDecimalNumber numberWithDouble:locationValue] decimalValue];
    newLabel.offset = 10.0;
    [labelSet addObject:newLabel];
    [newLabel release];
    [majorTickSet addObject:[NSDecimalNumber numberWithDouble:locationValue]];
  }
  x.axisLabels = labelSet;
  x.majorTickLocations = majorTickSet;
  
  CPXYAxis *y = axisSet.yAxis;
  
  y.isFloatingAxis = YES;
  y.constraints = constraints;
  
  y.labelingPolicy = CPAxisLabelingPolicyNone;
  [y.labelFormatter setFormat:@"#,##0.00"];
  y.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
  y.majorGridLineStyle = majorGridLineStyle;
  y.minorGridLineStyle = minorGridLineStyle;
  y.minorTicksPerInterval = 4;
  y.preferredNumberOfMajorTicks = 9;
  y.labelOffset = 10.0;
  y.title = @"Pace (mins / km)";
  y.titleOffset = 55.0;
  
  labelSet = [NSMutableSet set];
  majorTickSet = [NSMutableSet set];
  for (NSUInteger i = 0; i < 11; i++) {
    double locationValue = minimumValueForYAxis + 
    i * (maximumValueForYAxis - minimumValueForYAxis) / 10;
    double labelValue = maximumValueForYAxis + minimumValueForYAxis - locationValue;
    CPAxisLabel *newLabel = [[CPAxisLabel alloc] 
                             initWithText:
                             [y.labelFormatter stringFromNumber:[NSNumber numberWithDouble:labelValue]] 
                             textStyle:y.labelTextStyle];
    newLabel.tickLocation = 
    [[NSDecimalNumber numberWithDouble:locationValue] decimalValue];
    newLabel.offset = 10.0;
    [labelSet addObject:newLabel];
    [newLabel release];
    [majorTickSet addObject:[NSDecimalNumber numberWithDouble:locationValue]];
  }
  y.axisLabels = labelSet;
  y.majorTickLocations = majorTickSet;
  
  if (distinctColors == nil) {
    distinctColors = [[NSArray arrayWithObjects:
                      [CPColor blueColor],
                      [CPColor greenColor],
                      [CPColor redColor],
                      [CPColor brownColor],
                      [CPColor orangeColor],
                      [CPColor cyanColor],
                      [CPColor yellowColor],
                      [CPColor magentaColor],
                      [CPColor purpleColor],
                      [CPColor grayColor],
                      nil] retain];
  }
  NSMutableArray *plots = [NSMutableArray array];
  NSUInteger cursor = 0;
  for (CDMRunData *runData in rds) {
    CPScatterPlot *linePlot = [[[CPScatterPlot alloc] init] autorelease];
    linePlot.identifier = @"Run";
    linePlot.dataLineStyle.miterLimit = 1.0;
    linePlot.dataLineStyle.lineWidth = 3.0;
    NSUInteger colorIndex = cursor % [distinctColors count];
    linePlot.dataLineStyle.lineColor = [distinctColors objectAtIndex:colorIndex];
    linePlot.dataSource = runData;
    [graph addPlot:linePlot];
    [plots addObject:linePlot];
    cursor++;
  }
  
  [plotSpace scaleToFitPlots:plots];
  CPPlotRange *xRange = plotSpace.xRange;
  NSDecimal oldLocation = xRange.location;
  [xRange expandRangeByFactor:CPDecimalFromDouble(1.05)];
  xRange.location = oldLocation;
  
  CPPlotRange *yRange = plotSpace.yRange;
  oldLocation = yRange.location;
  [yRange expandRangeByFactor:CPDecimalFromDouble(1.05)];
  yRange.location = oldLocation;
  
  graph.plotAreaFrame.borderLineStyle = nil;
  return graph;
}
