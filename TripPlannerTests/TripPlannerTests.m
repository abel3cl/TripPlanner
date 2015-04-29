//
//  TripPlannerTests.m
//  TripPlannerTests
//
//  Created by Abel Castro on 28/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Event.h"
#import "AppDelegate.h"
#import "DayOpen.h"

@interface TripPlannerTests : XCTestCase

@end

@implementation TripPlannerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void) testIsOpenForDay
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Example Event
    Event *eventEntity = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:appDelegate.managedObjectContext];
    DayOpen* dayOpenEntity = (DayOpen*)[NSEntityDescription insertNewObjectForEntityForName:@"DayOpen" inManagedObjectContext:appDelegate.managedObjectContext];
    
    dayOpenEntity.event = eventEntity;
    dayOpenEntity.dayOfWeek = @0;
    dayOpenEntity.hourOpeningMorning = [NSDate date];
    dayOpenEntity.hourClosingMorning= [NSDate dateWithTimeIntervalSinceNow:1*24*60*60];
    
    NSSet *setOfDaysOpen = [NSSet setWithObject:dayOpenEntity];
    eventEntity.daysOpen = setOfDaysOpen;
    
    BOOL openOnDay = [eventEntity isOpenForDay:@0];
    
    
    XCTAssertEqual(openOnDay, YES);
    
    XCTAssertEqualObjects(eventEntity.daysOpen, setOfDaysOpen);
}


@end
