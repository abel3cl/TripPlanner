//
//  DayOpen.h
//  TripPlanner
//
//  Created by Abel Castro on 22/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface DayOpen : NSManagedObject

@property (nonatomic, retain) NSDate * hourOpeningMorning;
@property (nonatomic, retain) NSDate * hourOpeningEvening;
@property (nonatomic, retain) NSDate * hourClosingEvening;
@property (nonatomic, retain) NSDate * hourClosingMorning;
@property (nonatomic, retain) NSNumber * dayOfWeek;
@property (nonatomic, retain) Event *event;

@end
