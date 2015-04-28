//
//  Event.m
//  TripPlanner
//
//  Created by Abel Castro on 21/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "Event.h"
#import "DayOpen.h"
#import "Trip.h"


@implementation Event

@dynamic name;
@dynamic price;
@dynamic trip;
@dynamic daysOpen;


-(BOOL) isOpenForDay:(NSNumber*) dayOfWeekNumber
{
    NSArray *daysOpen = [self.daysOpen allObjects];
    
    for (DayOpen *day in daysOpen) {
        
        if ([day.dayOfWeek isEqualToNumber:dayOfWeekNumber]) {
            if (day.hourOpeningEvening || day.hourOpeningMorning) {
                return YES;
            }
        }
    }
    return NO;
}
@end
