//
//  ZKNetworkHandler.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 24/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKNetworkHandler.h"

ComplitionBlock routeBlock;
NSMutableData *responseData;

@implementation ZKNetworkHandler

+ (ZKNetworkHandler*)sharedInstance {

    static ZKNetworkHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZKNetworkHandler alloc] init];
    });
    return instance;
}

- (void)getRouteFrom:(NSString*)strFrom to:(NSString*)strTo completionHandler:(ComplitionBlock)block {
    routeBlock = block;
  
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false",strFrom,strTo];

    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma mark - NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *responseStatus = (NSHTTPURLResponse*)response;
    if (responseStatus.statusCode == 200)
        responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    routeBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    NSError *error;
    NSDictionary *jsonObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    routeBlock(jsonObj,nil);
}

#pragma mark - Route parsing

- (MKPolyline*)getPolyLine:(NSDictionary*)dicRoute {
    
    NSArray *routes = [dicRoute objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    if (route) {
        NSString *overviewPolyline = [[route objectForKey: @"overview_polyline"] objectForKey:@"points"];
        NSMutableArray *_path = [self decodePolyLine:overviewPolyline];
        
        NSInteger numberOfSteps = _path.count;
        
        CLLocationCoordinate2D coordinates[numberOfSteps];
        for (NSInteger index = 0; index < numberOfSteps; index++) {
            CLLocation *location = [_path objectAtIndex:index];
            CLLocationCoordinate2D coordinate = location.coordinate;
            
            coordinates[index] = coordinate;
        }
        
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
        return polyLine;
    }
    else
        return nil;
}

/*
 Blog: http://icodeapps.blogspot.in/2011/04/google-map-directions-api-objective-c.html
 Google:
 http://code.google.com/apis/maps/documentation/directions/
 http://code.google.com/apis/maps/documentation/utilities/polylinealgorithm.html

 */
- (NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
//    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    
    return array;
}

- (id<MKAnnotation>)sourceLocationOfRoute:(NSDictionary*)dicRoute andAddress:(NSString**)sourceAddress {

    NSArray *arrRoutes = [dicRoute objectForKey:@"routes"];
    if ( arrRoutes && arrRoutes.count > 0 )
    {
        NSDictionary *dicRoute = [arrRoutes objectAtIndex:0];
        NSArray *arrLegs = [dicRoute objectForKey:@"legs"];
        if ( arrLegs && arrLegs.count > 0 )
        {
            NSDictionary *dicLeg = [arrLegs objectAtIndex:0];
            *sourceAddress = [dicLeg objectForKey:@"start_address"];
            NSDictionary *dicSourceLoc = [dicLeg objectForKey:@"start_location"];
            
            MKPointAnnotation* a = [[MKPointAnnotation alloc] init];
            a.title = *sourceAddress;
            a.subtitle = [NSString stringWithFormat:@"Source - %f %f", [[dicSourceLoc objectForKey:@"lat"] floatValue], [[dicSourceLoc objectForKey:@"lng"]floatValue]];
            a.coordinate = CLLocationCoordinate2DMake([[dicSourceLoc objectForKey:@"lat"] floatValue], [[dicSourceLoc objectForKey:@"lng"]floatValue]);

            return a;
        }
    }
    return nil;
}

- (id<MKAnnotation>)destinationLocationOfRoute:(NSDictionary*)dicRoute andAddress:(NSString**)destinationAddress {
    
    NSArray *arrRoutes = [dicRoute objectForKey:@"routes"];
    if ( arrRoutes && arrRoutes.count > 0 )
    {
        NSDictionary *dicRoute = [arrRoutes objectAtIndex:0];
        NSArray *arrLegs = [dicRoute objectForKey:@"legs"];
        if ( arrLegs && arrLegs.count > 0 )
        {
            NSDictionary *dicLeg = [arrLegs objectAtIndex:0];
            *destinationAddress = [dicLeg objectForKey:@"end_address"];
            NSDictionary *dicSourceLoc = [dicLeg objectForKey:@"end_location"];
            
            MKPointAnnotation* a = [[MKPointAnnotation alloc] init];
            a.title = *destinationAddress;
            a.subtitle = [NSString stringWithFormat:@"Destination - %f %f", [[dicSourceLoc objectForKey:@"lat"] floatValue], [[dicSourceLoc objectForKey:@"lng"]floatValue]];
            a.coordinate = CLLocationCoordinate2DMake([[dicSourceLoc objectForKey:@"lat"] floatValue], [[dicSourceLoc objectForKey:@"lng"]floatValue]);
            
            return a;
        }
    }
    return nil;

}

@end
