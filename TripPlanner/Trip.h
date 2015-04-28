//
//  Trip.h
//  TripPlanner
//
//  Created by Abel Castro on 20/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Acommodation, Event, Fligth;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * codeOfCountry;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) Fligth *fligth;
@property (nonatomic, retain) Acommodation *acommodation;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
