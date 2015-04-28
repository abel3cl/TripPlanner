//
//  TPOverviewViewController.h
//  TripPlanner
//
//  Created by Abel Castro on 20/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface TPOverviewViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) Trip *actualTrip;

@end
