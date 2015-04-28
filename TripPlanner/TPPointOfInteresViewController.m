//
//  TPPointOfInteresViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 17/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPPointOfInteresViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WebServiceConnectionsController.h"
#import "AppDelegate.h"
#import "TPAddEventViewController.h"

@interface TPPointOfInteresViewController ()
{
    WebServiceConnectionsController *webServiceCC;
    NSArray *pointsOfInterest;
    __weak IBOutlet UITableView *tableOfPointsOfInterest;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
}
@end

@implementation TPPointOfInteresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointsOfInterest:) name:@"pointsOfInterest" object:nil];
    webServiceCC = ((AppDelegate*)[UIApplication sharedApplication].delegate).webServiceController;
    [activityIndicator setHidesWhenStopped:YES];
    [webServiceCC getPointOfInterestForLat:[_actualTrip.latitude doubleValue] withLng: [_actualTrip.longitude doubleValue]];
}
-(void)viewWillAppear:(BOOL)animated{
    [activityIndicator startAnimating];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource & Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [pointsOfInterest count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellPointOfInterest";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //cell.textLabel.text = [[pointsOfInterest objectAtIndex:indexPath.section] valueForKey:@"name"];
    NSString *photoReference = [[[[pointsOfInterest objectAtIndex:indexPath.section] valueForKey:@"photos"] objectAtIndex:0] valueForKey:@"photo_reference"];
#warning call to details for photo and hours
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=150&photoreference=%@&key=AIzaSyDUVL8CoRS2Y2ALgyl9l1IkHD1tYre_THc",photoReference]];
    //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[myTrips objectAtIndex:indexPath.row] description]]];
    [cell.backgroundView setAlpha:0.4];
#warning change this for connection
    [cell setBackgroundView: [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]]];
    //[cell.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[pointsOfInterest objectAtIndex:section] valueForKey:@"name"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TPAddEventViewController *tpAddEventVC = (TPAddEventViewController*) [[self.navigationController viewControllers ] objectAtIndex:1];
    
    [tpAddEventVC setPointOfInterest: [pointsOfInterest objectAtIndex:indexPath.section]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification
-(void) pointsOfInterest: (NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    pointsOfInterest = [info valueForKey:@"pointsOfInterest"];
    [tableOfPointsOfInterest reloadData];
    [activityIndicator stopAnimating];
}
@end
