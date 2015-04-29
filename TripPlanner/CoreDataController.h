//
//  CoreDataController.h
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Trip;

@interface CoreDataController : NSObject

-(void) addTripDestination: (NSString*) destination
                 startDate:(NSDate*) startDate
                   endDate:(NSDate*) endDate
                  currency: (NSString*) currency
              withLatitude: (NSNumber*) latitude
             withLongitude: (NSNumber*)  longitude
           withCodeCountry: (NSString*) codeCountry;
-(NSArray*) getAllTrips;
-(void) addEvent: (NSDictionary*) event withPeriods: (NSMutableArray*) periods withPrice: (NSNumber*) price forTrip:(Trip*) trip completion: (void(^)(void)) callback;
-(void) updateTrip: (Trip*) trip withPriceOfFligth: (NSNumber*) priceFligth withCurrency: (NSString*) currencyOfFligth priceOfAcommodation: (NSNumber*) priceAcommodation withCurrency: (NSString*) currencyOfAcommodation completion: (void(^)(void)) callback;
-(void) deleteTrip: (Trip*) trip;
@end
