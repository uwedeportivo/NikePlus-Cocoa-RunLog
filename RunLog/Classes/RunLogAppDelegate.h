//
//  RunLogAppDelegate.h
//  RunLog
//
//  Created by Uwe Hoffmann on 9/8/10.
//  Copyright 2010 codemanic. All rights reserved.
//

#import <CorePlot/CorePlot.h>

@interface RunLogAppDelegate : NSObject <NSApplicationDelegate> {
  CPLayerHostingView *graphView;
  CPXYGraph *graph;
  NSWindow *window;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CPLayerHostingView *graphView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
- (IBAction)saveAction:sender;
- (IBAction)exportToPDF:(id)sender;
@end

