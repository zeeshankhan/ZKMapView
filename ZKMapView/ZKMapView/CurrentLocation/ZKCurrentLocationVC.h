//
//  ZKCurrentLocationVC.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ZKCurrentLocationVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *currentLocationMapView;
@end
