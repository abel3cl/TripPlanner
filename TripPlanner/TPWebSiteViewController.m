//
//  TPWebSiteViewController.m
//  TripPlanner
//
//  Created by Abel Castro on 21/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "TPWebSiteViewController.h"

@interface TPWebSiteViewController ()
{
    __weak IBOutlet UIWebView *webContent;
}
@end

@implementation TPWebSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:_urlWebsite];
    [webContent loadRequest: [NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
