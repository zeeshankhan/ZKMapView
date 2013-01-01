//
//  CalloutAnnotationView.h
//  CustomCalloutSample
//
//  Created by Zeeshan Khan on 09/01/2011.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CalloutAnnotationView : MKAnnotationView

@property (nonatomic, weak) IBOutlet UIView *calloutView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *dicViewData;
@property (nonatomic,strong) MKAnnotationView *parentAnnotationView;
@property (nonatomic,strong) MKMapView *mapView;

@end

extern NSString* const CalloutReuseIdentifier;
