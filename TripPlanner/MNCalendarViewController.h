//
//  MNCalendarViewController.h
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNCalendarViewController : UIViewController

@property (weak, nonatomic) NSDate *startDate;
@property (weak, nonatomic) NSDate *endDate;
@property (weak, nonatomic) id sender;

@end
