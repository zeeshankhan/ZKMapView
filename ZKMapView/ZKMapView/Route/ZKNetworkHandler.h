//
//  ZKNetworkHandler.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 24/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ComplitionBlock) (id responseObject, NSError *error);

@interface ZKNetworkHandler : NSObject

+ (ZKNetworkHandler*)sharedInstance;

- (void)getRouteFrom:(NSString*)strFrom to:(NSString*)strTo completionHandler:(ComplitionBlock)block;

- (MKPolyline*)getPolyLine:(NSDictionary*)dicRoute;

- (id<MKAnnotation>)sourceLocationOfRoute:(NSDictionary*)dicRoute andAddress:(NSString**)sourceAddress;
- (id<MKAnnotation>)destinationLocationOfRoute:(NSDictionary*)dicRoute andAddress:(NSString**)destinationAddress;

@end
