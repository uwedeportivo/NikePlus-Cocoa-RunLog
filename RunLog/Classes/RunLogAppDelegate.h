//
//  RunLogAppDelegate.h
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import "CDMNikeSyncer.h"

@interface RunLogAppDelegate : NSObject <NSApplicationDelegate> {
  CPLayerHostingView *graphView;
  CPXYGraph *graph;
  NSWindow *window;
  NSArrayController *runsController;
  CDMNikeSyncer *syncer;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CPLayerHostingView *graphView;
@property (assign) IBOutlet NSArrayController *runsController;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)exportToPDF:(id)sender;

@end

