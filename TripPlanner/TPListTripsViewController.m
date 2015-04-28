//
//  TPListTripsViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPListTripsViewController.h"
#import "CoreDataController.h"
#import "AppDelegate.h"
#import "Trip.h"
#import "TPListEventsViewController.h"
#import "TPOverviewViewController.h"
#import "TPFligthAcommodationViewControllerViewController.h"

@interface TPListTripsViewController ()
{
    __weak IBOutlet UITableView *tableOfTrips;
    __weak IBOutlet UIImageView *imgArrow;
    __weak IBOutlet UILabel *lblMessage;
    NSArray *arrayOfTrips;
    CoreDataController *coreDataController;
}
@end

@implementation TPListTripsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    coreDataController = ((AppDelegate*) [UIApplication sharedApplication].delegate).coreDataController;
    arrayOfTrips = [coreDataController getAllTrips];
    
     tableOfTrips.sectionIndexBackgroundColor = [UIColor colorWithRed:2 green:247 blue:247 alpha:1];
    tableOfTrips.backgroundColor = [UIColor colorWithRed:2 green:247 blue:247 alpha:1];
    // Do any additional setup after loading the view.
}

// This shows the new trips after adding a new one
-(void)viewWillAppear:(BOOL)animated
{
    arrayOfTrips = [coreDataController getAllTrips];
    [tableOfTrips reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource, Delegate
// Invert sections and rows to make a blanck space
// If there's no trips, show a message and image
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfRowsInSection = [arrayOfTrips count];
    if (!numberOfRowsInSection) {
        [tableView setHidden:YES];
        [lblMessage setHidden:NO];
        [imgArrow setHidden:NO];
    }
    else {
        [lblMessage setHidden:YES];
        [imgArrow setHidden:YES];
        [tableView setHidden:NO];
    }
    return numberOfRowsInSection;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellTrip";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.layer.borderWidth = 1;
    cell.layer.cornerRadius = 5;
    cell.textLabel.text = ((Trip*)[arrayOfTrips objectAtIndex:indexPath.section]).destination;
    
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [coreDataController deleteTrip:[arrayOfTrips objectAtIndex:indexPath.section]];
        arrayOfTrips = [coreDataController getAllTrips];
        [tableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showTripSegue"]) {
        UITabBarController *tabBarController = [segue destinationViewController];
        UINavigationController *navigationController = [tabBarController.viewControllers objectAtIndex:0];
        TPListEventsViewController *TPListEventsVC = [navigationController.viewControllers objectAtIndex:0];
    ;
        TPOverviewViewController *TPOverviewVC = [tabBarController.viewControllers objectAtIndex:2];
        ;
        TPFligthAcommodationViewControllerViewController *TPFligthAcommodationViewControllerVC = [tabBarController.viewControllers objectAtIndex:1];
        NSIndexPath *indexPath = [tableOfTrips indexPathForSelectedRow];
        [TPListEventsVC setActualTrip:[arrayOfTrips objectAtIndex:indexPath.section]];
        [TPOverviewVC setActualTrip:[arrayOfTrips objectAtIndex:indexPath.section]];
        [TPFligthAcommodationViewControllerVC setActualTrip:[arrayOfTrips objectAtIndex:indexPath.section]];
    }
}

- (IBAction)btnSettings:(id)sender
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Currency" message:@"Choose a currency" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        [textField addTarget:self action:@selector(valueAdded:) forControlEvents:UIControlEventEditingDidEnd];
    }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void) valueAdded: (UITextField*) sender
{
    NSLog(@"%@",sender.text);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults synchronize];
    
}

@end
