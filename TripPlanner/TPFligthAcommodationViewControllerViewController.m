//
//  TPFligthAcommodationViewControllerViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 20/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPFligthAcommodationViewControllerViewController.h"
#import "AppDelegate.h" 
#import "CoreDataController.h"
#import "Acommodation.h"
#import "Fligth.h"

@interface TPFligthAcommodationViewControllerViewController ()
{
    __weak IBOutlet UITextField *txtPriceFligth;
    __weak IBOutlet UITextField *txtPriceAcommodation;
    __weak IBOutlet UISegmentedControl *sgmPriceFligth;
    __weak IBOutlet UISegmentedControl *sgmPriceAcommodation;
    __weak IBOutlet UIButton *btnSave;
    CoreDataController *coreDataController;
    
}
@end

@implementation TPFligthAcommodationViewControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    coreDataController = ((AppDelegate*) [UIApplication sharedApplication].delegate).coreDataController;

    // Do any additional setup after loading the view.
    [sgmPriceAcommodation removeAllSegments];
    [sgmPriceAcommodation insertSegmentWithTitle:[[NSUserDefaults standardUserDefaults]  valueForKey:@"mycurrency_preference"] atIndex:0 animated:NO];
    [sgmPriceAcommodation insertSegmentWithTitle:_actualTrip.currency atIndex:1 animated:NO];
    [sgmPriceAcommodation setSelectedSegmentIndex:0];
    
    [sgmPriceFligth removeAllSegments];
    [sgmPriceFligth insertSegmentWithTitle:[[NSUserDefaults standardUserDefaults]  valueForKey:@"mycurrency_preference"] atIndex:0 animated:NO];
    [sgmPriceFligth insertSegmentWithTitle:_actualTrip.currency atIndex:1 animated:NO];
    [sgmPriceFligth setSelectedSegmentIndex:0];
    
    [btnSave.layer setBorderWidth:1.0];
    [btnSave.layer setBorderColor: [[UIColor blueColor] CGColor]];
    [btnSave.layer setCornerRadius:3.0];
    
    if(_actualTrip.acommodation.price != nil)
    {
        txtPriceAcommodation.text = [NSString stringWithFormat:@"%@",_actualTrip.acommodation.price];
        if([[sgmPriceAcommodation titleForSegmentAtIndex:0] isEqualToString:_actualTrip.acommodation.currency])
            [sgmPriceAcommodation setSelectedSegmentIndex:0];
        else [sgmPriceAcommodation setSelectedSegmentIndex:1];
    }
    if(_actualTrip.fligth.price != nil) {
        txtPriceFligth.text = [NSString stringWithFormat:@"%@",_actualTrip.fligth.price];
        if([[sgmPriceFligth titleForSegmentAtIndex:0] isEqualToString:_actualTrip.fligth.currency])
            [sgmPriceFligth setSelectedSegmentIndex:0];
        else [sgmPriceFligth setSelectedSegmentIndex:1];
    }
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSave:(id)sender
{
    NSString *currencyOfFligth = (sgmPriceFligth.selectedSegmentIndex) ? _actualTrip.currency : [[NSUserDefaults standardUserDefaults] valueForKey:@"mycurrency_preference"];
    NSString *currencyOfAcommodation = (sgmPriceAcommodation.selectedSegmentIndex) ? _actualTrip.currency : [[NSUserDefaults standardUserDefaults] valueForKey:@"mycurrency_preference"];
    
    NSNumber *priceFligth = [NSNumber numberWithFloat: [txtPriceFligth.text doubleValue]];
    NSNumber *priceAcommodation = [NSNumber numberWithFloat: [txtPriceAcommodation.text doubleValue]];
    
    [coreDataController updateTrip: _actualTrip withPriceOfFligth: priceFligth withCurrency: currencyOfFligth priceOfAcommodation: priceAcommodation withCurrency: currencyOfAcommodation];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtPriceFligth resignFirstResponder];
    [txtPriceAcommodation resignFirstResponder];
}
@end
