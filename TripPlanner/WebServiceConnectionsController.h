//
//  WebServiceConnectionsController.h
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kGOOGLE_API_KEY @"AIzaSyDUVL8CoRS2Y2ALgyl9l1IkHD1tYre_THc"
#define kOPENEXCHANGE_API_KEY @"8b4b1b83b20e4c1db40c62caecef35e0"
#import <CoreLocation/CoreLocation.h>

@interface WebServiceConnectionsController : NSObject <NSURLConnectionDataDelegate>

-(void) autocompleteCityName:(NSString*) searchFor;
-(void) autocompletePointOfInterestName:(NSString*) searchFor withLat: (double) lat withLng: (double) lng forCountry: (NSString*) codeCountry;
-(void) getCodeOfCountryWithCityPlaceID:(NSString*) placeID;
-(void) getPointOfInterestForLat: (double) lat withLng: (double) lng;
-(void) getInfoPointOfInterest:(NSString*) placeID;
-(void) getExchanges;
@end
