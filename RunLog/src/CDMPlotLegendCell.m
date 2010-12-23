//
//  CDMPlotLegendCell.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/11/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMPlotLegendCell.h"


@implementation CDMPlotLegendCell

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSNumber *runIdNumber = (NSNumber *)[self objectValue];
  RunLogAppDelegate *appDelegate = 
  (RunLogAppDelegate *)[[NSApplication sharedApplication] delegate];
  
  NSColor *plotColor = [appDelegate colorForRunId:runIdNumber];
  
	if (plotColor == nil) {
    return [super highlightColorWithFrame:cellFrame inView:controlView];
  }
  return plotColor;
}


@end
