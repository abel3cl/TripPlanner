//
//  TPOverviewViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 20/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPOverviewViewController.h"
#import "AppDelegate.h"
#import "WebServiceConnectionsController.h"
#import "Acommodation.h"
#import "Fligth.h"
#import "Event.h"
#import "DayOpen.h"
#import <Social/Social.h>


@interface TPOverviewViewController ()
{
    WebServiceConnectionsController *webServiceController;
    __weak IBOutlet UILabel *lblTotalMyCurrency;
    __weak IBOutlet UILabel *lblTotalLocalCurrency;
    __weak IBOutlet UILabel *lblEventsMyCurrency;
    __weak IBOutlet UILabel *lblEventsLocalCurrency;
    __weak IBOutlet UILabel *lblFligthAcommodationMyCurrency;
    __weak IBOutlet UILabel *lblFligthAcommodationLocalCurrency;
    __weak IBOutlet UIButton *btnGenerate;
    __weak IBOutlet UIView *viewLayer;
    __weak IBOutlet UITableView *tableOfEvents;
    
    
    double totalInLocalCurrency;
    double totalInMyCurrency;
    double eventsInLocalCurrency;
    double eventsInMyCurrency;
    double fligthAcommodationInLocalCurrency;
    double fligthAcommodationInMyCurrency;
    double myCurrencyRate;
    double localCurrencyRate;
    
    NSMutableArray *arrayOfDaysAvailable; // days of my trip (Dates)
    NSMutableArray *arrayOfEventsPerDay; // array of arrays
    NSMutableOrderedSet *setOfDaysAvailable; // days of the week 0-SUN, 6-SAT
}
@end

@implementation TPOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Pinch Gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // Style button
    [btnGenerate.layer setBorderWidth:1.0];
    [btnGenerate.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnGenerate.layer setCornerRadius:3.0];
    
    // Register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getExchanges:) name:@"getExchanges" object:nil];
    webServiceController = ((AppDelegate*) [UIApplication sharedApplication].delegate).webServiceController;
   
    // Initializate values
    eventsInLocalCurrency = 0.0;
    eventsInMyCurrency = 0.0;
    fligthAcommodationInLocalCurrency = 0.0;
    fligthAcommodationInMyCurrency = 0.0;
    totalInLocalCurrency = 0.0;
    totalInMyCurrency = 0.0;

    [webServiceController getExchanges];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Generate Budget Methods
-(void) getExchanges: (NSNotification*) notification
{
    NSDictionary *rates = notification.userInfo;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *myCurrency = [defaults valueForKey:@"mycurrency_preference"];
    
    myCurrencyRate =  [[rates valueForKey:myCurrency] doubleValue];
    localCurrencyRate = [[rates valueForKey:_actualTrip.currency] doubleValue];
}

-(void) generateEventsBudget
{
    for (id event in [_actualTrip.events allObjects] ) {
        eventsInLocalCurrency += [[event valueForKey:@"price"] doubleValue];
    }
    eventsInMyCurrency = (eventsInLocalCurrency * myCurrencyRate) / localCurrencyRate;
    lblEventsLocalCurrency.text = [NSString stringWithFormat:@"%.2f %@",eventsInLocalCurrency, _actualTrip.currency];
    lblEventsMyCurrency.text = [NSString stringWithFormat:@"%.2f %@",eventsInMyCurrency, [[NSUserDefaults standardUserDefaults]valueForKey:@"mycurrency_preference"]];
}

-(void) generateFligthAcommodationBudget
{
    if([_actualTrip.acommodation.currency isEqualToString:_actualTrip.currency])
    {
        fligthAcommodationInLocalCurrency += [_actualTrip.acommodation.price doubleValue];
    }
    else
    {
        fligthAcommodationInMyCurrency += [_actualTrip.acommodation.price doubleValue];
    }
    if([_actualTrip.fligth.currency isEqualToString:_actualTrip.currency])
    {
        fligthAcommodationInLocalCurrency += [_actualTrip.fligth.price doubleValue];
    }
    else
    {
        fligthAcommodationInMyCurrency += [_actualTrip.fligth.price doubleValue];
    }
    
    fligthAcommodationInMyCurrency += (fligthAcommodationInLocalCurrency * myCurrencyRate) / localCurrencyRate;
    
    fligthAcommodationInLocalCurrency = (fligthAcommodationInMyCurrency * localCurrencyRate) / myCurrencyRate;
    
    
    lblFligthAcommodationLocalCurrency.text = [NSString stringWithFormat:@"%.2f %@",fligthAcommodationInLocalCurrency, _actualTrip.currency];
    lblFligthAcommodationMyCurrency.text = [NSString stringWithFormat:@"%.2f %@",fligthAcommodationInMyCurrency, [[NSUserDefaults standardUserDefaults]valueForKey:@"mycurrency_preference"]];
}

-(void) generateTotalBudget
{
    totalInLocalCurrency = fligthAcommodationInLocalCurrency + eventsInLocalCurrency;
    totalInMyCurrency = fligthAcommodationInMyCurrency + eventsInMyCurrency;
    
    lblTotalMyCurrency.text = [NSString stringWithFormat:@"%.2f %@",totalInMyCurrency, [[NSUserDefaults standardUserDefaults]valueForKey:@"mycurrency_preference"]];
    lblTotalLocalCurrency.text = [NSString stringWithFormat:@"%.2f %@",totalInLocalCurrency, _actualTrip.currency];
}

#pragma mark - Button share Social Media
- (IBAction)btnShare:(id)sender
{
    SLComposeViewController *slvc;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        slvc = [[SLComposeViewController alloc] init];
        slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [slvc setInitialText: [NSString stringWithFormat:@"I'm about to make a trip to %@",_actualTrip.destination]];
        
        [self presentViewController:slvc animated:YES completion:nil];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed!" message:@"You need a set up Facebook account" preferredStyle:(UIAlertControllerStyleAlert)];
        
        [alert addAction: [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Button Generate Plan
- (IBAction)btnGeneratePlan:(id)sender
{
    [self generateSchedulePlan];
    if (localCurrencyRate) {
        [self generateEventsBudget];
        [self generateFligthAcommodationBudget];
        [self generateTotalBudget];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Problem" message:@"It's not possible generate a budget" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [viewLayer setHidden:YES];
    [sender setHidden:YES];
}

-(void) generateSchedulePlan
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

    NSDate *startDate = _actualTrip.startDate;
    NSDateComponents *componentsStartDate = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_actualTrip.startDate];
    
    NSTimeInterval intervalInSeconds = [_actualTrip.endDate timeIntervalSinceDate:_actualTrip.startDate];
    NSTimeInterval daysAvailable = intervalInSeconds / 60 / 60 / 24;
    
    
    setOfDaysAvailable = [NSMutableOrderedSet orderedSet];
    arrayOfDaysAvailable = [NSMutableArray array];
    arrayOfEventsPerDay = [NSMutableArray array];
    
    // Calculate days of the week availables
    // I substract -1, because google uses 0-6 for weekday and nsdate uses 1-7
    for (NSUInteger i = componentsStartDate.weekday-1; i < componentsStartDate.weekday+daysAvailable-1; i++)
    {
        // which daysOfWeek is Available
        [setOfDaysAvailable addObject:[NSNumber numberWithInteger:i%7]];
    }

    // Calculate the days of the trip
    for (int i = 0; i < daysAvailable; i++) {
        [arrayOfDaysAvailable addObject: startDate];
        startDate = [startDate dateByAddingTimeInterval:24*60*60];
    }

    [self groupEventsByDays];
    [tableOfEvents reloadData];
}

-(void) groupEventsByDays
{
    NSArray *setOfEvents = [_actualTrip.events allObjects];
    
    for (NSNumber *day in setOfDaysAvailable) {
        [arrayOfEventsPerDay addObject:[NSMutableArray array]];
    }
    [arrayOfEventsPerDay addObject:[NSMutableArray array]]; // Events without date, last position
    for (Event *event in setOfEvents)
    {
        BOOL inserted = NO;
        
        for (int i = 0 ; i < [setOfDaysAvailable count]; i++)
        {
            if(!inserted) {
            for (NSNumber *dayOfWeek in setOfDaysAvailable) {
                if ([event isOpenForDay: dayOfWeek]) {
                    if(!inserted) {
                        if ([[arrayOfEventsPerDay objectAtIndex:i] count] == 0) {
                            
                        [[arrayOfEventsPerDay objectAtIndex:i] addObject:event];
                        inserted = YES;
                        break;
                        }
                    }
                }
            }
            }
        }
        if(!inserted)
        {
            [[arrayOfEventsPerDay objectAtIndex:[arrayOfEventsPerDay count] -1] addObject:event];
            NSLog(@"No possible to insert: %@", event.name);
        }
    }
    
}

#pragma mark - UITableViewDataSource & Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrayOfDaysAvailable count] +1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([arrayOfEventsPerDay count] > section)
        return [[arrayOfEventsPerDay objectAtIndex:section] count];
    else return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellEventsPerDay";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[[arrayOfEventsPerDay objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name];
    return cell;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == [arrayOfEventsPerDay count] -1) {
        return @"Not possible to schedule this events";
    }
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [_dateFormatter setDateFormat:@"EEEE: dd-MM-yyyy"];
    NSString *stringDate = [_dateFormatter stringFromDate:[arrayOfDaysAvailable objectAtIndex:section]];

    return stringDate;
}

#pragma mark - Action to Gesture
-(void)respondToPinchGesture:(UIPinchGestureRecognizer*) recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
