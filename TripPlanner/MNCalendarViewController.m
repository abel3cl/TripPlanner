//
//  MNCalendarViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "MNCalendarViewController.h"
#import "MNCalendarView.h"
#import "TPAddTripViewController.h"

@interface MNCalendarViewController () <MNCalendarViewDelegate>
{
    MNCalendarView *calendarView;
    NSDate         *currentDate;
}
@end

@implementation MNCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentDate = [NSDate date];
    calendarView = [[MNCalendarView alloc] initWithFrame:self.view.bounds];
    calendarView.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendarView.selectedDate = [NSDate date];
    calendarView.delegate = self;
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    calendarView.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:calendarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MNCalendarViewDelegate
- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date {
    
    UINavigationController *navigationRoot = (UINavigationController*) self.presentingViewController;
    TPAddTripViewController *addTripVC = (TPAddTripViewController*)[navigationRoot.viewControllers objectAtIndex:1];
    
    if([[_sender valueForKey:@"tag"] isEqualToNumber:@100]) {
        _startDate = date;
        [self updateEndDate]; // Check if the endDate is valid.
    }
    else {
        _endDate = date;
    }
    
    addTripVC.endDate = _endDate;
    addTripVC.startDate = _startDate;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)calendarView:(MNCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    
    if([date  compare: currentDate] < 0)
        return NO;
    
    // If user's choosing endDate. User cannot choose a date before startDate
    if([[_sender valueForKey:@"tag"] isEqualToNumber:@101]) {
        if([date compare: [_startDate dateByAddingTimeInterval:1*24*60*60]] < 0)
            return NO;
    }
    return YES;
}

-(void) updateEndDate
{
    // If the new startDate is greater that endDate
    if ([_endDate compare:_startDate] <= 0) {
        _endDate = [_startDate dateByAddingTimeInterval:1*24*60*60];
    }
}
@end
