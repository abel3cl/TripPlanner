//
//  TPPointOfInteresViewController.h
//  TripPlanner
//
//  Created by Abel Castro on 17/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface TPPointOfInteresViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) Trip *actualTrip;

@end
