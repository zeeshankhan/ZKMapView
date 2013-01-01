//
//  ZKOverlayAnnotation.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 29/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKOverlayAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;

@end
