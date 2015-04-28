//
//  Event.h
//  TripPlanner
//
//  Created by Abel Castro on 21/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DayOpen, Trip;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) NSSet *daysOpen;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addDaysOpenObject:(DayOpen *)value;
- (void)removeDaysOpenObject:(DayOpen *)value;
- (void)addDaysOpen:(NSSet *)values;
- (void)removeDaysOpen:(NSSet *)values;

-(BOOL) isOpenForDay:(NSNumber*) dayOfWeekNumber;

@end
