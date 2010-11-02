//
//  RunLogAppDelegate.m
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//


#import "RunLogAppDelegate.h"
#import "CDMURLFetcher.h"
#import "CDMXML.h"
#import "CDMArray.h"
#import "CDMRunData.h"

#import <CorePlot/CorePlot.h>

@implementation RunLogAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  //nikeid = 617307368  
  //runid = 608402641
  
  NSURL *url = [NSURL URLWithString:@"http://nikerunning.nike.com/nikeplus/v1/services/widget/get_public_run.jsp?userID=617307368&id=608402641"];
  NSURLRequest *pageRequest = [NSURLRequest requestWithURL:url];

  [CDMURLFetcher fetch:pageRequest completionHandler:^(NSData *data, NSError *error) {
    if (error == nil) {
      NSError *error = nil;
      NSXMLDocument *xmlDoc = 
        [[[NSXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];
      
      NSLog(@"xmlDoc = %@", xmlDoc);
      
      error = nil;
        
      NSArray *extendedDataStr = 
        [xmlDoc commaSeparatedTextAtTag:@"extendedData" error:&error];
      
      NSArray *extendedData = [extendedDataStr map:^(id elem) {
        NSString *elemStr = (NSString *) elem;
        
        return [NSNumber numberWithDouble:[elemStr doubleValue]]; 
      }];
      NSLog(@"extendedData = %@", extendedData);
      
      CDMRunData *runData = [[CDMRunData alloc] initWithExtendedData:extendedData];
            
      error = nil;
      NSLog(@"calories = %@", [xmlDoc textAtTag:@"calories" error:&error]);

      error = nil;
      NSLog(@"startTime = %@", [xmlDoc textAtTag:@"startTime" error:&error]);

      double minimumValueForXAxis = runData.minimumValueForXAxis;
      double maximumValueForXAxis = runData.maximumValueForXAxis;
      double minimumValueForYAxis = runData.minimumValueForYAxis;
      double maximumValueForYAxis = runData.maximumValueForYAxis;
            
      graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
      
      CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
      [graph applyTheme:theme]; 
      graphView.hostedLayer = graph;
            
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
            
      CPScatterPlot *linePlot = [[[CPScatterPlot alloc] init] autorelease];
      linePlot.identifier = @"Run";
      linePlot.dataLineStyle.miterLimit = 1.0;
      linePlot.dataLineStyle.lineWidth = 3.0;
      linePlot.dataLineStyle.lineColor = [CPColor blueColor];
      linePlot.dataSource = runData;
      [graph addPlot:linePlot];

      [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:linePlot, nil]];
      CPPlotRange *xRange = plotSpace.xRange;
      NSDecimal oldLocation = xRange.location;
      [xRange expandRangeByFactor:CPDecimalFromDouble(1.05)];
      xRange.location = oldLocation;
      
      CPPlotRange *yRange = plotSpace.yRange;
      oldLocation = yRange.location;
      [yRange expandRangeByFactor:CPDecimalFromDouble(1.05)];
      yRange.location = oldLocation;

      graph.plotAreaFrame.borderLineStyle = nil;
      
      [graph reloadData];
      [graphView needsDisplay]; 
    }
  }]; 
}

- (IBAction)exportToPDF:(id)sender {
	NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];
	[pdfSavingDialog setRequiredFileType:@"pdf"];
	
	if ([pdfSavingDialog runModalForDirectory:nil file:nil] == NSOKButton) {
		NSData *dataForPDF = [graph dataForPDFRepresentationOfLayer];
		[dataForPDF writeToFile:[pdfSavingDialog filename] atomically:NO];
	}		
}


/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "RunLog" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"RunLog"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%@ No model to generate a store from", [self class], @"persistentStoreCoordinator");
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], @"saveAction");
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], @"applicationShouldTerminate");
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asg 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

- (void)dealloc {
  [graph release];
  [managedObjectContext release];
  [persistentStoreCoordinator release];
  [managedObjectModel release];
    [super dealloc];
}

@end

