//
//  CDMNikeRunAccessors.h
//  RunLog
//
//  Created by Uwe Hoffmann on 11/9/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSManagedObject(NikeRunAccessors)

@property (nonatomic, retain) NSNumber *calories;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSData *extendedData;
@property (nonatomic, retain) NSNumber *runId;
@property (nonatomic, retain) NSDate *startTime;

@end
