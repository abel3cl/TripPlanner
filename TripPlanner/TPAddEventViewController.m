//
//  TPAddEventViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPAddEventViewController.h"
#import "WebServiceConnectionsController.h"
#import "TPPointOfInteresViewController.h"
#import "AppDelegate.h"
#import "CoreDataController.h"
#import "TPWebSiteViewController.h"

@interface TPAddEventViewController ()
{
    // UIControls
    __weak IBOutlet UITextField *txtNameOfPoint;
    __weak IBOutlet UITextField *txtPriceOfPoint;
    __weak IBOutlet UITextField *txtHourOpeningMorningOfPoint;
    __weak IBOutlet UITextField *txtHourOpeningEveningOfPoint;
    __weak IBOutlet UITextField *txtHourClosingMorningOfPoint;
    __weak IBOutlet UITextField *txtHourClosingEveningOfPoint;
    __weak IBOutlet UISegmentedControl *sgmDays;
    __weak IBOutlet UIButton *btnSave;
    __weak IBOutlet UITableView *tableOfAutocompletePointOfInterest;
    __weak IBOutlet UIButton *btnGoWebsite;
    __weak IBOutlet UIButton *btnAdd;
        
    // Controllers
    WebServiceConnectionsController *webServiceController;
    CoreDataController *coreDataController;
    
    NSArray *pointsOfInterest;
    NSMutableArray *periods;
}
@end

@implementation TPAddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webServiceController = ((AppDelegate*) [UIApplication sharedApplication].delegate).webServiceController;
    coreDataController = ((AppDelegate*) [UIApplication sharedApplication].delegate).coreDataController;
    
    // Register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autocompletePointOfInterest:) name:@"autocompletePointOfInterest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailsPointOfInterest:) name:@"detailsPointOfInterest" object:nil];
    
    // Style buttons
    [btnGoWebsite.layer setBorderWidth:1.0];
    [btnGoWebsite.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnGoWebsite.layer setCornerRadius:3.0];
    [btnSave.layer setBorderWidth:1.0];
    [btnSave.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnSave.layer setCornerRadius:3.0];
    txtPriceOfPoint.placeholder = [txtPriceOfPoint.placeholder stringByAppendingString:_actualTrip.currency];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    if(_pointOfInterest)
    {
        txtNameOfPoint.text = [_pointOfInterest valueForKey:@"name"];
        [webServiceController getInfoPointOfInterest:[_pointOfInterest valueForKey:@"place_id"]];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pointOfInterestSegue"]) {
        TPPointOfInteresViewController *pointOfInterestVC = [segue destinationViewController];
        [pointOfInterestVC setActualTrip:_actualTrip];
    }
    if ([segue.identifier isEqualToString:@"goWebsiteSegue"]) {
        TPWebSiteViewController *tpWebSiteVC = [segue destinationViewController];
        [tpWebSiteVC setUrlWebsite:[_pointOfInterest valueForKey:@"website"]];
    }
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pointsOfInterest count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellAutocompletePointOfInterest"];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CellAutocompletePointOfInterest"];
    }

    cell.textLabel.text = [[pointsOfInterest objectAtIndex:indexPath.row] valueForKey:@"description"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableOfAutocompletePointOfInterest setHidden:YES];
    NSString *nameOfPoint = [[pointsOfInterest objectAtIndex:indexPath.row] valueForKey:@"description"];
    
    txtNameOfPoint.text = nameOfPoint;
    [webServiceController getInfoPointOfInterest:[[pointsOfInterest objectAtIndex:indexPath.row] valueForKey:@"place_id"]];
}

#pragma mark - UITextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _pointOfInterest = nil;
    // Start autocomplete after 3 chars
    if ([textField.text length] > 2) {
        NSString *searchFor = [textField.text stringByAppendingString:string];
        [webServiceController autocompletePointOfInterestName:searchFor withLat: [_actualTrip.latitude  doubleValue] withLng: [_actualTrip.longitude doubleValue] forCountry: _actualTrip.codeOfCountry];
    }
    else {
        [btnGoWebsite setHidden:YES];
        [tableOfAutocompletePointOfInterest setHidden:YES];
        periods = nil;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == 100)
    {
        [btnGoWebsite setHidden:YES];
        [tableOfAutocompletePointOfInterest setHidden:YES];
        periods = nil;
        [self enableTextFields];
        [self sgmValueChange:sgmDays];
        _pointOfInterest = nil;
        txtHourOpeningMorningOfPoint.text = @"";
        txtHourOpeningEveningOfPoint.text = @"";
        txtHourClosingMorningOfPoint.text = @"";
        txtHourClosingEveningOfPoint.text = @"";
    }
    return YES;
}

#pragma mark - notifications
-(void)autocompletePointOfInterest: (NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    pointsOfInterest = [info valueForKey:@"pointsOfInterest"];
    [tableOfAutocompletePointOfInterest setHidden:NO];
    [tableOfAutocompletePointOfInterest reloadData];
}

-(void)detailsPointOfInterest: (NSNotification*) notification
{
    _pointOfInterest = notification.userInfo;
    periods = [[_pointOfInterest valueForKey:@"opening_hours"] valueForKey:@"periods"];
    
    if (periods) {
        [self disableTextFields];
        [self sgmValueChange:sgmDays];
        [btnAdd setHidden:YES];
    }
    else {
        [btnAdd setHidden:NO];
        periods = [NSMutableArray array];
    }
    
    NSString *website = [_pointOfInterest valueForKey:@"website"];
    if (website) {
        [btnGoWebsite setHidden:NO];
    }
}

#pragma mark - Save
- (IBAction)btnSave:(id)sender {
    if (_pointOfInterest) {
        NSNumber *price = [NSNumber numberWithFloat: [txtPriceOfPoint.text floatValue]];
        
        [coreDataController addEvent: _pointOfInterest withPeriods: periods withPrice:price forTrip:_actualTrip completion:^{
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Added!" message:@"Event added" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        _pointOfInterest = nil;
        [self clearFields];
        [self enableTextFields];
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Unknown place" message:@"Select a place from the table" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UISegment ValueChangeEvent
- (IBAction)sgmValueChange:(id)sender
{
    txtHourOpeningMorningOfPoint.text = @"";
    txtHourClosingMorningOfPoint.text = @"";
    txtHourOpeningEveningOfPoint.text = @"";
    txtHourClosingEveningOfPoint.text = @"";
    NSUInteger index = [sgmDays selectedSegmentIndex];
    NSMutableArray *days = [NSMutableArray array];
    
    for (NSDictionary *day in periods)
    {
        if( (NSUInteger)[[[day valueForKey:@"open"] valueForKey:@"day"] isEqualToNumber:[NSNumber numberWithInteger:index]] )
        {
            [days addObject:day];
        }
    
        if ([days count] > 0) {
            txtHourOpeningMorningOfPoint.text = [[[days objectAtIndex:0] valueForKey:@"open"] valueForKey:@"time"];
            txtHourClosingMorningOfPoint.text = [[[days objectAtIndex:0] valueForKey:@"close"] valueForKey:@"time"];
            txtHourOpeningEveningOfPoint.text = @"";
            txtHourClosingEveningOfPoint.text = @"";
            if ([days count] > 1) {
                txtHourOpeningEveningOfPoint.text = [[[days objectAtIndex:1] valueForKey:@"open"] valueForKey:@"time"];
                txtHourClosingEveningOfPoint.text = [[[days objectAtIndex:1] valueForKey:@"close"] valueForKey:@"time"];
            }
        }
    }
}

- (IBAction)btnAdd:(id)sender
{
    
    NSString *hourOpeningMorningSelected =  txtHourOpeningMorningOfPoint.text;
    NSString *hourClosingMorningSelected =  txtHourClosingMorningOfPoint.text;
    NSString *hourOpeningEveningSelected =  txtHourOpeningEveningOfPoint.text;
    NSString *hourClosingEveningSelected =  txtHourClosingEveningOfPoint.text;
    
    NSUInteger index = [sgmDays selectedSegmentIndex];
    
    NSDictionary *openMorning = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:index],@"day",hourOpeningMorningSelected,@"time", nil];
    NSDictionary *closeMorning = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:index],@"day",hourClosingMorningSelected,@"time", nil];
    NSDictionary *openEvening = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:index],@"day",hourOpeningEveningSelected,@"time", nil];
    NSDictionary *closeEvening = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:index],@"day",hourClosingEveningSelected,@"time", nil];
    
    
    NSDictionary *shiftMorning = [NSDictionary dictionaryWithObjectsAndKeys:openMorning,@"open",closeMorning,@"close",nil];
    NSArray *period;
    
    if (![hourOpeningEveningSelected isEqualToString:@""]) {
        NSDictionary *shiftEvening = [NSDictionary dictionaryWithObjectsAndKeys:openEvening,@"open",closeEvening,@"close",nil];
    
        period = [NSArray arrayWithObjects:shiftMorning,shiftEvening, nil];
    }
    else
    {
        period = [NSArray arrayWithObjects:shiftMorning, nil];
    }
    
    [periods addObjectsFromArray:period];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Added" message:@"added" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Other Methods
-(void) clearFields
{
    [btnGoWebsite setHidden:YES];
    [btnAdd setHidden:YES];
    [btnAdd setEnabled:YES];
    txtNameOfPoint.text = @"";
    txtPriceOfPoint.text = @"";
    txtHourOpeningMorningOfPoint.text = @"";
    txtHourClosingMorningOfPoint.text = @"";
    txtHourOpeningEveningOfPoint.text = @"";
    txtHourClosingEveningOfPoint.text = @"";
}

-(void) disableTextFields
{
    [txtHourOpeningMorningOfPoint setEnabled:NO];
    [txtHourClosingMorningOfPoint setEnabled:NO];
    [txtHourOpeningEveningOfPoint setEnabled:NO];
    [txtHourClosingEveningOfPoint setEnabled:NO];
}
-(void) enableTextFields
{
    [txtHourOpeningMorningOfPoint setEnabled:YES];
    [txtHourClosingMorningOfPoint setEnabled:YES];
    [txtHourOpeningEveningOfPoint setEnabled:YES];
    [txtHourClosingEveningOfPoint setEnabled:YES];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtNameOfPoint resignFirstResponder];
    [txtPriceOfPoint resignFirstResponder];
    [txtHourOpeningMorningOfPoint resignFirstResponder];
    [txtHourClosingMorningOfPoint resignFirstResponder];
    [txtHourOpeningEveningOfPoint resignFirstResponder];
    [txtHourClosingEveningOfPoint resignFirstResponder];
    [tableOfAutocompletePointOfInterest setHidden:YES];
}
@end
