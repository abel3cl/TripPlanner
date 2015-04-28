//
//  TPListEventsViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPListEventsViewController.h"
#import "TPAddEventViewController.h"
#import "Event.h"
#import "DayOpen.h"

@interface TPListEventsViewController ()
{
    __weak IBOutlet UIBarButtonItem *btnBack;
    __weak IBOutlet UILabel *lblMessage;
    __weak IBOutlet UIImageView *imgArrow;
    __weak IBOutlet UITableView *tableOfEvents;
}
@end

@implementation TPListEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:_actualTrip.destination];
}

// Refresh table after adding a new event
-(void)viewWillAppear:(BOOL)animated
{
    [tableOfEvents reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"AddEventSegue"])
    {
        TPAddEventViewController *tpAddEventVC = [segue destinationViewController];
        [tpAddEventVC setActualTrip:_actualTrip];
    }
}

#pragma mark - UITableView DataSource & Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = [_actualTrip.events count];
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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[[_actualTrip.events allObjects] objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event*)[[_actualTrip.events allObjects] objectAtIndex:indexPath.row];
    NSSet *set = event.daysOpen;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_actualTrip removeEventsObject:[[_actualTrip.events allObjects] objectAtIndex:indexPath.row]];
        [_actualTrip.managedObjectContext save:nil];
        [tableView reloadData];
    }
    
    [tableView resignFirstResponder];
    
}

#pragma mark - Button Back
- (IBAction)btnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
