//
//  WebServiceConnectionsController.m
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import "WebServiceConnectionsController.h"

@interface WebServiceConnectionsController ()
{
    NSMutableData *receivedData;
    BOOL autocompletingPointOfInterest;
    BOOL detailsPointOfInterest;
}
@end

@implementation WebServiceConnectionsController

#pragma mark - Requests
-(void) autocompleteCityName:(NSString*) searchFor
{
    autocompletingPointOfInterest = NO;
    detailsPointOfInterest = NO;
    NSString *url = [searchFor stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlGoogle = [NSString stringWithFormat:@"https:maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&language=en&key=%@",url ,kGOOGLE_API_KEY];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:urlGoogle];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void) autocompletePointOfInterestName:(NSString*) searchFor withLat: (double) lat withLng: (double) lng forCountry: (NSString*) codeCountry
{
    autocompletingPointOfInterest = YES;
    NSString *url = [searchFor stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlGoogle = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&point_of_interest&location=%f,%f&radius=1000&components=country:%@&language=en&sensor=true&key=%@", url, lat, lng, codeCountry, kGOOGLE_API_KEY];

    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:urlGoogle];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void) getCodeOfCountryWithCityPlaceID:(NSString*) placeID
{
    detailsPointOfInterest = NO;
    NSString *urlGoogle = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&language=en&sensor=true&key=%@",placeID,kGOOGLE_API_KEY];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:urlGoogle];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void) getCurrencyOfCountry: (NSString*) codeCountry
{
    NSString *url = [NSString stringWithFormat: @"https://restcountries.eu/rest/v1/alpha/%@",codeCountry];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void) getPointOfInterestForLat: (double) lat withLng: (double) lng
{
    NSString *url = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=2000&point_of_interest&language=en&sensor=true&key=%@",lat, lng,kGOOGLE_API_KEY];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }

}

-(void) getInfoPointOfInterest:(NSString*) placeID
{
    detailsPointOfInterest = YES;
    NSString *urlGoogle = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&language=en&sensor=true&key=%@",placeID,kGOOGLE_API_KEY];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:urlGoogle];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void) getExchanges
{
    NSString *url = [NSString stringWithFormat:@"https://openexchangerates.org/api/latest.json?app_id=8b4b1b83b20e4c1db40c62caecef35e0"];
    
    // Formulate the string as a URL object.
    NSURL *urlRequest=[NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

#pragma mark - URLConnectionDelegate Methods
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *host = connection.originalRequest.URL.host;
    NSString *path = connection.originalRequest.URL.path;
    
    //GoogleAPI
    if([host isEqualToString:@"maps.googleapis.com"])
    {   // Details of place
        if([path isEqualToString:@"/maps/api/place/details/json"])
        {
            if (detailsPointOfInterest) {
                [self getDetailsPointOfInterest];
            } else {
                [self getCodeLatLong];
            }
        }
        if([path isEqualToString:@"/maps/api/place/search/json"])
        {
            [self getPointOfInterest];
        }
        // Autocomplete poin
        if([path isEqualToString:@"/maps/api/place/autocomplete/json"])
        {
            [self getAutocompletePointOfInterestName];
        }
    }
    else {
        if ([host isEqualToString:@"restcountries.eu"]) {
            [self getCurrency];
        } else if([host isEqualToString:@"openexchangerates.org"]) {
            [self getRates];
        }
        
        else { // when I call to /maps/api/place/autocomplete/json for city, I don't have host and path
                [self getAutocompleteCityNames];
        }
    }
    NSLog(@"error %@ %@",error,[error localizedDescription]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *host = connection.originalRequest.URL.host;
    NSString *path = connection.originalRequest.URL.path;
    
    //GoogleAPI
    if([host isEqualToString:@"maps.googleapis.com"])
    {
        if([path isEqualToString:@"/maps/api/place/details/json"])
        {
            if (detailsPointOfInterest) {
                [self getDetailsPointOfInterest];
            } else {
                [self getCodeLatLong];
            }
        }
        if([path isEqualToString:@"/maps/api/place/search/json"])
        {
            [self getPointOfInterest];
        }
        if([path isEqualToString:@"/maps/api/place/autocomplete/json"])
        {
            [self getAutocompletePointOfInterestName];
        }
    }
    else {
        if ([host isEqualToString:@"restcountries.eu"]) {
            [self getCurrency];
        } else if([host isEqualToString:@"openexchangerates.org"]) {
            [self getRates];
        }
    
        else { // when I call to /maps/api/place/autocomplete/json for city, I don't have host and path
               [self getAutocompleteCityNames];
            }
    }
}

#pragma mark - Responses
-(void) getAutocompleteCityNames
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if(json) {
            NSArray *places = [json objectForKey:@"predictions"];
            NSDictionary *info = [NSDictionary dictionaryWithObject:places forKey:@"places"];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autocompleteCities" object:nil userInfo:info];
        }
    }
}

-(void) getAutocompletePointOfInterestName
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if(json) {
            NSArray *places = [json objectForKey:@"predictions"];
            NSDictionary *info = [NSDictionary dictionaryWithObject:places forKey:@"pointsOfInterest"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autocompletePointOfInterest" object:nil userInfo:info];
        }
    }
}

-(void) getCodeLatLong
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if (json) {
            // Check the response of google. Normally it's last object, if its concrete is before that one
            NSArray *addressComponents = [[json valueForKey:@"result"] valueForKey:@"address_components"];
            NSString *codeCountry;
            // Code of country is in the last position
            if ([[[addressComponents objectAtIndex:[addressComponents count] - 1] valueForKey:@"types"] containsObject:@"country"]) {

                codeCountry = [[addressComponents objectAtIndex: [addressComponents count] - 1] valueForKey:@"short_name"];
            }
            // Code of country is before the last position
            else {
                codeCountry = [[addressComponents objectAtIndex:[addressComponents count] - 2] valueForKey:@"short_name"];
            }
            
            NSNumber *latitude = [[[[json valueForKey:@"result"] valueForKey:@"geometry"]  valueForKey:@"location"] valueForKey:@"lat"];
            NSNumber *longitude = [[[[json valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude",longitude,@"longitude",codeCountry,@"codeCountry", nil];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"latlongCountry" object:nil userInfo:info];
            [self getCurrencyOfCountry: codeCountry];
        }
    }
}

-(void) getCurrency
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if (json) {
            if([[json allKeys] containsObject:@"currencies"]) {
                NSString *currency = [[json valueForKey:@"currencies"] lastObject];
            
                NSDictionary *info = [NSDictionary dictionaryWithObject:currency forKey:@"currency"];
        
                [[NSNotificationCenter defaultCenter] postNotificationName:@"currencyOfCountry" object:nil userInfo:info];
            }
        }
    }
}
-(void) getPointOfInterest
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                            error:&error];
        if (json) {
            NSArray *pointsOfInterest = [json valueForKey:@"results"];
            NSDictionary *info = [NSDictionary dictionaryWithObject:pointsOfInterest forKey:@"pointsOfInterest"];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pointsOfInterest" object:nil userInfo:info];
        }
        
    }
}

-(void) getDetailsPointOfInterest
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if (json) {
            NSDictionary *pointOfInterest = [json valueForKey:@"result"];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"detailsPointOfInterest" object:nil userInfo:pointOfInterest];
        }
    }
}

-(void) getRates
{
    if(receivedData != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions
                                                               error:&error];
        if (json) {
            NSDictionary *rates = [json valueForKey:@"rates"];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getExchanges" object:nil userInfo:rates];
        }
    }
}
@end
