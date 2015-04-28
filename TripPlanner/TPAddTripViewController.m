//
//  TPAddTripViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPAddTripViewController.h"
#import "MNCalendarViewController.h"
#import "AppDelegate.h"
#import "WebServiceConnectionsController.h"
#import "CoreDataController.h"

@interface TPAddTripViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    // Controllers
    WebServiceConnectionsController *webServiceController;
    CoreDataController *coreDataController;
    // UIControls
    __weak IBOutlet UITextField *txtDestination;
    __weak IBOutlet UIButton *btnStartDate;
    __weak IBOutlet UIButton *btnEndDate;
    __weak IBOutlet UIButton *btnSave;
    __weak IBOutlet UITableView *tableOfNameOfCities;
    
    NSString *destination;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *codeCountry;
    NSDictionary *placeDestination; // Place that user selects
    NSArray *places; // Show the results of the autocomplete
}
@end

@implementation TPAddTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setConstraints];
    webServiceController = ((AppDelegate*) [UIApplication sharedApplication].delegate).webServiceController;
    coreDataController = ((AppDelegate*) [UIApplication sharedApplication].delegate).coreDataController;
    
    // Style buttons
    [btnStartDate.layer setBorderWidth:1.0];
    [btnStartDate.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnStartDate.layer setCornerRadius:3.0];
    [btnEndDate.layer setBorderWidth:1.0];
    [btnEndDate.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnEndDate.layer setCornerRadius:3.0];
    [btnSave.layer setBorderWidth:1.0];
    [btnSave.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnSave.layer setCornerRadius:3.0];
    
    // Register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autocompleteCities:) name:@"autocompleteCities" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyOfCountry:) name:@"currencyOfCountry" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latlongCountry:) name:@"latlongCountry" object:nil];
    
    
}

// Change titles of the buttons when Select a date
-(void)viewWillAppear:(BOOL)animated
{
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [_dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    if (_startDate) {
        [btnStartDate setTintColor:[UIColor blueColor]];
        [btnStartDate.layer setBorderColor: [[UIColor blueColor] CGColor]];
        NSString *dateString = [_dateFormatter stringFromDate:_startDate];
        [btnStartDate setTitle:dateString forState:UIControlStateNormal];
    }
    if (_endDate) {
        [btnEndDate setTintColor:[UIColor blueColor]];
        [btnEndDate.layer setBorderColor: [[UIColor blueColor] CGColor]];
        NSString *dateString = [_dateFormatter stringFromDate:_endDate];
        [btnEndDate setTitle:dateString forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MNCalendarViewController *calendarVC = [segue destinationViewController];
    calendarVC.startDate = _startDate;
    calendarVC.endDate = _endDate;
    calendarVC.sender = sender;
}

#pragma mark - UITextField
// Start a looking for a new place
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    placeDestination = nil;
    places = nil;
    [txtDestination setBackgroundColor:[UIColor whiteColor]];
    // Starts autocompletition after 3 chars
    if ([textField.text length] > 2) {
        NSString *searchFor = [textField.text stringByAppendingString:string];
        [webServiceController autocompleteCityName:searchFor];
    }
    else {
        [tableOfNameOfCities setHidden:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [tableOfNameOfCities setHidden:YES];
    placeDestination = nil;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableView DataSource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [places count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellAutocompleteNameCity"];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CellAutocompleteNameCity"];
    }
    
    cell.textLabel.text = [[places objectAtIndex:indexPath.row] valueForKey:@"description"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableOfNameOfCities setHidden:YES];
    placeDestination = [places objectAtIndex:indexPath.row];
    txtDestination.text = [placeDestination valueForKey:@"description"];
}

#pragma mark - Save
- (IBAction)btnSave:(id)sender {
    // Place from the table selected
    if (placeDestination) {
        NSString *placeID = [placeDestination valueForKey:@"place_id"];

        if ([self checkDates])
        {
            [webServiceController getCodeOfCountryWithCityPlaceID: placeID];
        }
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Unknow destination" message:@"Select a destination from the table" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [txtDestination.layer setBorderColor:[[UIColor redColor] CGColor]];
        [txtDestination setBackgroundColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0]];
    }
}

#pragma mark - Notifications
-(void)autocompleteCities: (NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    places = [info valueForKey:@"places"];
    if(places != nil) {
        [tableOfNameOfCities setHidden:NO];
        [tableOfNameOfCities reloadData];
    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Network Problem" message:@"Check your internet conection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// Get info about destination (lat, long, and code alpha3)
-(void)latlongCountry: (NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    if(info != nil) {
        latitude = [info valueForKey:@"latitude"];
        longitude = [info valueForKey:@"longitude"];
        codeCountry = [info valueForKey:@"codeCountry"];
    }
    else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Network Problem" message:@"Check your internet conection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// Get the currency of the destination's country
// Save it in CoreData
-(void)currencyOfCountry: (NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    if(info != nil) {
        NSString *currency = [info valueForKey:@"currency"];
    
        [coreDataController addTripDestination: [placeDestination valueForKey:@"description"] startDate:_startDate endDate: _endDate currency: currency withLatitude: latitude withLongitude: longitude withCodeCountry: codeCountry];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Network Problem" message:@"Check your internet conection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Check inputs
-(BOOL) checkDates
{
    BOOL validStartDate = (_startDate) ? YES : NO;
    BOOL validEndDate = (_endDate) ? YES : NO;
    

    if (!validStartDate) {
        [btnStartDate.layer setBorderColor: [[UIColor redColor] CGColor]];
        [btnStartDate setTintColor:[UIColor redColor]];
    }
    if (!validEndDate) {
        [btnEndDate.layer setBorderColor: [[UIColor redColor] CGColor]];
        [btnEndDate setTintColor:[UIColor redColor]];
    }
    return (validStartDate && validEndDate);
}

#pragma mark -
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtDestination resignFirstResponder];
    [tableOfNameOfCities setHidden:YES];
}

#pragma mark - Autolayout constraints
-(void) setConstraints
{
    
    [self.view removeConstraints:self.view.constraints];
    
    NSArray *constraints_POS_V;
    NSArray *constraints_POS_H;
    NSArray *constraints_SIZE_V;
    NSArray *constraints_SIZE_H;
    [txtDestination setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableOfNameOfCities setTranslatesAutoresizingMaskIntoConstraints:NO];
    [btnStartDate setTranslatesAutoresizingMaskIntoConstraints:NO];
    [btnEndDate setTranslatesAutoresizingMaskIntoConstraints:NO];
    [btnSave setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *uiControls = NSDictionaryOfVariableBindings(txtDestination,tableOfNameOfCities,btnStartDate,btnEndDate,btnSave);
    
    // TextField Destination Size and Pos
    constraints_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[txtDestination]" options:0 metrics:nil views:uiControls];
    constraints_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[txtDestination]-16-|" options:0 metrics:nil views:uiControls];
    constraints_SIZE_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[txtDestination(30)]" options:0 metrics:nil views:uiControls];
    
    [self.view addConstraints:constraints_POS_H];
    [self.view addConstraints:constraints_POS_V];
    [self.view addConstraints:constraints_SIZE_V];
    
    // UITableView Destination Size and Pos
    NSLayoutConstraint *constraints_SAME_SIZE_W = [NSLayoutConstraint constraintWithItem:tableOfNameOfCities
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:txtDestination
                                                      attribute:NSLayoutAttributeWidth
                                                     multiplier:1.0 constant:0];
    [self.view addConstraint:constraints_SAME_SIZE_W];
    
    constraints_SIZE_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableOfNameOfCities(295)]" options:0 metrics:nil views:uiControls];
    
    [self.view addConstraints:constraints_SIZE_V];
    
    // Pin tableOfNameOfCities to txtDestination
    constraints_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[txtDestination][tableOfNameOfCities]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:uiControls];
    [self.view addConstraints:constraints_POS_V];
    
    
    // UIButtons Dates Pos
    constraints_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[txtDestination]-40-[btnStartDate]"
                                                                options:0
                                                                metrics:nil
                                                                  views:uiControls];
    [self.view addConstraints:constraints_POS_V];
    
    constraints_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[txtDestination]-40-[btnEndDate]"
                                                                options:0
                                                                metrics:nil
                                                                  views:uiControls];
    
    [self.view addConstraints:constraints_POS_V];
    
    // UIButtons Dates Size
    constraints_SIZE_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[btnStartDate(35)]" options:0 metrics:nil views:uiControls];
    [self.view addConstraints:constraints_SIZE_H];
    
    NSLayoutConstraint *constraints_SAME_SIZE_H = [NSLayoutConstraint constraintWithItem:btnStartDate
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:btnEndDate
                                                                               attribute:NSLayoutAttributeHeight
                                                                              multiplier:1.0 constant:0];
    [self.view addConstraint:constraints_SAME_SIZE_H];
    constraints_SAME_SIZE_W = [NSLayoutConstraint constraintWithItem:btnStartDate
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:btnEndDate
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:1.0 constant:0];
    [self.view addConstraint:constraints_SAME_SIZE_W];
    
    // Pin the buttons in horizontal
    constraints_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[btnStartDate]-23-[btnEndDate]-16-|" options:0
                                                                metrics:nil
                                                                  views:uiControls];
    [self.view addConstraints:constraints_POS_H];
    
    // UIButton Save
    constraints_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[btnStartDate]-30-[btnSave]"
                                                                options:0
                                                                metrics:nil
                                                                  views:uiControls];
    [self.view addConstraints:constraints_POS_V];
    
    constraints_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[btnSave]-100-|" options:0 metrics:nil views:uiControls];
    [self.view addConstraints:constraints_POS_H];
    constraints_SAME_SIZE_H = [NSLayoutConstraint constraintWithItem:btnSave
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:btnStartDate
                                                                               attribute:NSLayoutAttributeHeight
                                                                              multiplier:1.0 constant:0];
    [self.view addConstraint:constraints_SAME_SIZE_H];
}


@end
