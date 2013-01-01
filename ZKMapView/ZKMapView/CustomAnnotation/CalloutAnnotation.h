//
//  CalloutAnnotation.h
//  CustomCalloutSample
//
//  Created by Zeeshan Khan on 09/01/2011.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CalloutAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *dicData;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
