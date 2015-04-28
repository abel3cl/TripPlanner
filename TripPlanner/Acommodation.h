//
//  Acommodation.h
//  TripPlanner
//
//  Created by Abel Castro on 20/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Acommodation : NSManagedObject

@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) Trip *trip;

@end
