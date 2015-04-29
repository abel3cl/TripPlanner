//
//  CoreDataController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "CoreDataController.h"
#import "AppDelegate.h"
#import "Trip.h"
#import "Event.h"
#import "Fligth.h"
#import "Acommodation.h"
#import "DayOpen.h"

@interface CoreDataController ()
{
    NSManagedObjectContext *managedObjectContext;
}
@end

@implementation CoreDataController

-(id) init
{
    self = [super init];
    if(self) {
        managedObjectContext = ((AppDelegate*) [UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}

#pragma mark - Trip Methods
-(void) addTripDestination: (NSString*) destination
                 startDate:(NSDate*) startDate
                   endDate:(NSDate*) endDate
                  currency: (NSString*) currency
              withLatitude: (NSNumber*) latitude
             withLongitude: (NSNumber*)  longitude
           withCodeCountry: (NSString*) codeCountry
{
    Trip *tripEntity = (Trip*)[NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:managedObjectContext];
    tripEntity.destination = destination;
    tripEntity.startDate = startDate;
    tripEntity.endDate = endDate;
    tripEntity.currency = currency;
    tripEntity.latitude = latitude;
    tripEntity.longitude = longitude;
    tripEntity.codeOfCountry = codeCountry;
    
    NSError *errorSaving = nil;
    
    [self createEventInCalendar:tripEntity];
    if(![managedObjectContext save:&errorSaving])
    {
        NSLog(@"Error saving trip %@ %@", errorSaving, [errorSaving localizedDescription]);
    }
}

-(void) deleteTrip: (Trip*) trip
{
    [self deleteEventInCalendar:trip];
    [managedObjectContext deleteObject:trip];
    NSError *error = nil;
    
    if(![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@",error, [error localizedDescription]);
        exit(-1);
    }
}

-(NSArray*) getAllTrips{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"destination" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    /// Passing sectionNameKeyPath, it groups by "category"
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"destination" cacheName:@"Root"];
   
    NSError *error = nil;
    
    if(![fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@",error, [error localizedDescription]);
        exit(-1);
    }
    
    return fetchedResultsController.fetchedObjects;
}

-(void) updateTrip: (Trip*) trip withPriceOfFligth: (NSNumber*) priceFligth withCurrency: (NSString*) currencyOfFligth priceOfAcommodation: (NSNumber*) priceAcommodation withCurrency: (NSString*) currencyOfAcommodation completion: (void(^)(void)) callback;
{
    Fligth* fligthEntity = (Fligth*)[NSEntityDescription insertNewObjectForEntityForName:@"Fligth" inManagedObjectContext:managedObjectContext];
    
    fligthEntity.price = priceFligth;
    fligthEntity.currency = currencyOfFligth;
    fligthEntity.trip = trip;
    
    Acommodation* acommodationEntity = (Acommodation*)[NSEntityDescription insertNewObjectForEntityForName:@"Acommodation" inManagedObjectContext:managedObjectContext];
    acommodationEntity.price = priceAcommodation;
    acommodationEntity.currency = currencyOfAcommodation;
    acommodationEntity.trip = trip;
    
    NSError *errorSaving = nil;
    
    if(![managedObjectContext save:&errorSaving])
    {
        NSLog(@"Error saving fligthAcommodation %@ %@", errorSaving, [errorSaving localizedDescription]);
    }
    callback();
}

#pragma mark - Event Methods
-(void) addEvent: (NSDictionary*) event withPeriods: (NSMutableArray*) periodsM withPrice: (NSNumber*) price forTrip:(Trip *) trip
{
    Event* eventEntity = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
    
    
    eventEntity.name = [event valueForKey:@"name"];
    eventEntity.price = price;
    eventEntity.trip = trip;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate dateWithTimeIntervalSince1970:0]];
   

    // Set Hours
    NSMutableSet *setOfDaysOpen = [NSMutableSet set];
    NSArray *periods = [periodsM copy];
    //NSArray *periodsL = [[event valueForKey:@"opening_hours"] valueForKey:@"periods"];
    
    for (int index = 0; index < 7; index++) {
        DayOpen* dayOpenEntity = (DayOpen*)[NSEntityDescription insertNewObjectForEntityForName:@"DayOpen" inManagedObjectContext:managedObjectContext];
        dayOpenEntity.event = eventEntity;
        
        NSMutableArray *days = [NSMutableArray array];
        // Counts the periods (if there's 2 -> 2 shifts)
        for (NSDictionary *day in periods)
        {
            if( (NSUInteger)[[[day valueForKey:@"open"] valueForKey:@"day"] isEqualToNumber:[NSNumber numberWithInteger:index]] )
            {
                [days addObject:day];
            }
        }
        
        // Just 1 shift
        if ([days count] > 0) {
            
            NSString *hourOpen = [[[[days objectAtIndex:0] valueForKey:@"open"] valueForKey:@"time"] substringToIndex:2];
            NSString *minuteOpen = [[[[days objectAtIndex:0] valueForKey:@"open"] valueForKey:@"time"] substringFromIndex:2];
            
            components.hour = [hourOpen intValue];
            components.minute = [minuteOpen intValue];
            NSDate *dateOpen = [calendar dateFromComponents:components];
            
            dayOpenEntity.dayOfWeek = [[[days objectAtIndex:0] valueForKey:@"open"] valueForKey:@"day"];
            dayOpenEntity.hourOpeningMorning = dateOpen;
            
            NSString *hourClose = [[[[days objectAtIndex:0] valueForKey:@"close"] valueForKey:@"time"] substringToIndex:2];
            NSString *minuteClose = [[[[days objectAtIndex:0] valueForKey:@"close"] valueForKey:@"time"] substringFromIndex:2];
            components.hour = [hourClose intValue];
            components.minute = [minuteClose intValue];
            NSDate *dateClose = [calendar dateFromComponents:components];
            dayOpenEntity.hourClosingMorning = dateClose;
            
            // There's 2 shifts
            if ([days count] > 1) {
                
                NSString *hourOpen = [[[[days objectAtIndex:1] valueForKey:@"open"] valueForKey:@"time"] substringToIndex:2];
                NSString *minuteOpen = [[[[days objectAtIndex:1] valueForKey:@"open"] valueForKey:@"time"] substringFromIndex:2];
                components.hour = [hourOpen intValue];
                components.minute = [minuteOpen intValue];
                NSDate *dateOpen = [calendar dateFromComponents:components];
                
                dayOpenEntity.hourOpeningEvening = dateOpen;
                
                NSString *hourClose = [[[[days objectAtIndex:1] valueForKey:@"close"] valueForKey:@"time"] substringToIndex:2];
                NSString *minuteClose = [[[[days objectAtIndex:1] valueForKey:@"close"] valueForKey:@"time"] substringFromIndex:2];
                components.hour = [hourClose intValue];
                components.minute = [minuteClose intValue];
                NSDate *dateClose = [calendar dateFromComponents:components];
                
                dayOpenEntity.hourClosingEvening = dateClose;
            }
            [setOfDaysOpen addObject:dayOpenEntity];
        }      
    }
    
    eventEntity.daysOpen = setOfDaysOpen;
    
    NSError *errorSaving = nil;
    
    if(![managedObjectContext save:&errorSaving])
    {
        NSLog(@"Error saving event %@ %@", errorSaving, [errorSaving localizedDescription]);
    }
}

#pragma mark - EventKit
-(void) createEventInCalendar: (Trip*) trip
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
        completion:^(BOOL granted, NSError *error) {
        
        if (!granted) {
            return;
        }
        
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [NSString stringWithFormat:@"Trip to %@",trip.destination];
        event.startDate = trip.startDate;
        event.endDate = trip.endDate;
        event.calendar = [store defaultCalendarForNewEvents];
        event.allDay = YES;
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];
}

-(void) deleteEventInCalendar: (Trip*) trip
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(BOOL granted, NSError *error) {
                              
        if (!granted) {
                return;
        }
                              
        NSError *err = nil;
                              
        NSPredicate *predicate = [store predicateForEventsWithStartDate:trip.startDate endDate:trip.endDate calendars:[NSArray arrayWithObject:store.defaultCalendarForNewEvents]];
        EKEvent *event  = [[store eventsMatchingPredicate:predicate] firstObject];
        [store removeEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];

}

@end
