//
//  CDMNikeSyncer.m
//  RunLog
//
//  Created by Uwe Hoffmann on 11/4/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMNikeSyncer.h"
#import "CDMURLFetcher.h"
#import "RunLogAppDelegate.h"
#import "CDMXML.h"
#import "CDMArray.h"
#import "CDMDateTime.h"
#import "CDMNikeRunAccessors.h"

static NSString * const kNikeRunURLFormat = 
  @"http://nikerunning.nike.com/nikeplus/v1/services/widget/get_public_run.jsp?userID=%d&id=%d";

static NSString * const kNikeRunListURLFormat =
  @"http://nikerunning.nike.com/nikeplus/v1/services/widget/get_public_run_list.jsp?userID=%d";


@interface CDMNikeSyncer() 

- (void)syncStep;
- (void)finishSync;
- (void)fetchRunList;
- (void)findMissingRuns:(NSArray *)runIds;
- (void)fetchRun:(NSUInteger)runId;
- (void)saveRun:(NSXMLDocument *)xmlDoc runId:(NSUInteger)runId;

@end

@implementation CDMNikeSyncer

@synthesize isSyncing, syncStatus;

- (id)init {
  if ((self = [super init])) {
    syncStatus = @"";
    isSyncing = NO;
  }
  
  return self;
}

- (void)dealloc {
  [runsToSync release];
  [super dealloc];
}

- (void)setNikeId:(NSUInteger)anId {
  appDelegate = (RunLogAppDelegate *)[[NSApplication sharedApplication] delegate];
  nikeId = anId;
}

- (void)finishSync {
  [runsToSync release];
  runsToSync = nil;
  [self willChangeValueForKey:@"isSyncing"];
  isSyncing = NO;
  [self didChangeValueForKey:@"isSyncing"];
  [self willChangeValueForKey:@"syncStatus"];
  syncStatus = @"";
  [self didChangeValueForKey:@"syncStatus"];

  syncCursor = 0;
  [appDelegate saveAction:self];
  NSLog(@"finishSync");
}

- (void)syncStep {
  NSLog(@"syncStep");
  if (syncCursor < [runsToSync count]) {
    NSUInteger runId = [[runsToSync objectAtIndex:syncCursor] intValue];
    [self willChangeValueForKey:@"syncStatus"];
    [syncStatus release];
    syncStatus = [[NSString stringWithFormat:@"Fetching run %lu", runId] retain];
    [self didChangeValueForKey:@"syncStatus"];
    [self fetchRun:runId];
  } else {
    [self finishSync];
  }
}

- (void)saveRun:(NSXMLDocument *)xmlDoc runId:(NSUInteger)runId {
  NSManagedObject *nikeRun = [NSEntityDescription
                               insertNewObjectForEntityForName:@"NikeRun"
                               inManagedObjectContext:appDelegate.managedObjectContext];
  
  NSError *error = nil;
  NSArray *extendedDataStr = [xmlDoc commaSeparatedTextAtTag:@"extendedData" error:&error];
  
  NSArray *extendedData = [extendedDataStr map:^(id elem) {
    NSString *elemStr = (NSString *) elem;
    
    return [NSNumber numberWithDouble:[elemStr doubleValue]]; 
  }];
  
  nikeRun.extendedData = [NSArchiver archivedDataWithRootObject:extendedData];
  
  error = nil;
  nikeRun.calories = 
    [NSNumber numberWithDouble:[[xmlDoc textAtTag:@"calories" error:&error] doubleValue]];
  
  error = nil;
  nikeRun.distance = 
    [NSNumber numberWithDouble:[[xmlDoc textAtTag:@"distance" error:&error] doubleValue]];

  error = nil;
  nikeRun.duration = 
    [NSNumber numberWithInt:[[xmlDoc textAtTag:@"duration" error:&error] intValue]];

  error = nil;
  nikeRun.runId = [NSNumber numberWithInt:runId];

  error = nil;
  nikeRun.startTime = CDMParseDateString([xmlDoc textAtTag:@"startTime" error:&error]);
  
  error = nil;
  nikeRun.pace = 
    [NSNumber numberWithDouble:
       ([nikeRun.duration doubleValue] / (60000.0 * [nikeRun.distance doubleValue]))];
  
  NSLog(@"saveRun saved %@", nikeRun);
  syncCursor++;
  [self syncStep];
}

- (void)findMissingRuns:(NSArray *)runIds {
  NSManagedObjectContext *moc = appDelegate.managedObjectContext;
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"NikeRun" inManagedObjectContext:moc];
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
    
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                      initWithKey:@"runId" ascending:YES];
  [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  [sortDescriptor release];
  
  NSError *error = nil;
  NSArray *nikeRuns = [moc executeFetchRequest:request error:&error];
  
  NSUInteger nikeRunsCount = [nikeRuns count];
  NSUInteger runIdsCount = [runIds count];
  
  NSUInteger i = 0;
  NSUInteger j = 0;
  
  runsToSync = [[NSMutableArray alloc] initWithCapacity:32];
  while (i < nikeRunsCount && j < runIdsCount) {
    NSUInteger nikeRunId = [[[nikeRuns objectAtIndex:i] runId] intValue];
    NSUInteger fetchedId = [[runIds objectAtIndex:j] intValue];
    
    if (fetchedId == nikeRunId) {
      i++;
      j++;
    } else if (fetchedId < nikeRunId) {
      [runsToSync addObject:[NSNumber numberWithInt:fetchedId]];
      j++;
    } else {
      i++;
    }
  }
  
  while (j < runIdsCount) {
    NSUInteger fetchedId = [[runIds objectAtIndex:j] intValue];
    [runsToSync addObject:[NSNumber numberWithInt:fetchedId]];
    j++;
  }
  
  NSLog(@"findMissingRuns found %@", runsToSync);
  [self syncStep];
}

- (void)fetchRunList {
  NSString *runListURLStr = [NSString stringWithFormat:kNikeRunListURLFormat, nikeId];
  
  NSURL *url = [NSURL URLWithString:runListURLStr];
  NSURLRequest *pageRequest = [NSURLRequest requestWithURL:url];
  
  [self willChangeValueForKey:@"syncStatus"];
  [syncStatus release];
  syncStatus = @"Fetching run list";
  [self didChangeValueForKey:@"syncStatus"];

  
  [CDMURLFetcher fetch:pageRequest completionHandler:^(NSData *data, NSError *error) {
    if (error == nil) {
      NSError *error = nil;
      NSXMLDocument *xmlDoc = 
        [[[NSXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];
      
      error = nil;
      NSArray *runIdStr = [xmlDoc nodesForXPath:@"//run/@id" error:&error];
      
      NSArray *runIds = [runIdStr map:^(id elem) {        
        return [NSNumber numberWithInt:[[elem stringValue] intValue]]; 
      }];

      runIds = [runIds sortedArrayUsingSelector:@selector(compare:)];
      NSLog(@"fetchRunList found %@", runIds);
      [self findMissingRuns:runIds];
    }
  }]; 
}

- (void)fetchRun:(NSUInteger)runId {
  NSString *runURLStr = [NSString stringWithFormat:kNikeRunURLFormat, nikeId, runId];
  
  NSURL *url = [NSURL URLWithString:runURLStr];
  NSURLRequest *pageRequest = [NSURLRequest requestWithURL:url];
  
  [CDMURLFetcher fetch:pageRequest completionHandler:^(NSData *data, NSError *error) {
    if (error == nil) {
      NSError *error = nil;
      NSXMLDocument *xmlDoc = 
        [[[NSXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];
      
      NSLog(@"fetchRun for %lu found %@", runId, xmlDoc);
      [self saveRun:xmlDoc runId:runId]; 
    }
  }]; 
}

- (void)sync {
  if (isSyncing) {
    return;
  }
  NSLog(@"started sync");
  [self willChangeValueForKey:@"isSyncing"];
  isSyncing = YES;
  [self didChangeValueForKey:@"isSyncing"];
  [self fetchRunList];
}

@end
