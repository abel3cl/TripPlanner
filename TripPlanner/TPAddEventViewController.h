//
//  TPAddEventViewController.h
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface TPAddEventViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) Trip *actualTrip;
@property (strong,nonatomic) NSDictionary *pointOfInterest;
@property (weak,nonatomic) NSString *price;

@end
