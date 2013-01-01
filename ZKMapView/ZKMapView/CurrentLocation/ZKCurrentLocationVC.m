//
//  ZKCurrentLocationVC.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKCurrentLocationVC.h"

@interface ZKCurrentLocationVC ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ZKCurrentLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Current Location";
    
    _locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		// Stop significant location updates and start normal location updates again since the app is in the forefront.
		[_locationManager stopMonitoringSignificantLocationChanges];
		[_locationManager startUpdatingLocation];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
    
    _currentLocationMapView.showsUserLocation = YES;
    
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, 15000.0, 15000.0);
    [_currentLocationMapView setRegion:userLocation animated:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
	if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		// Stop normal location updates and start significant location change updates for battery efficiency.
		[_locationManager stopUpdatingLocation];
		[_locationManager startMonitoringSignificantLocationChanges];
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCurrentLocationMapView:nil];
    [super viewDidUnload];
}


#pragma mark - CLLocationManagerDelegate

- (void)_locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)_locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
	
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[_currentLocationMapView setRegion:userLocation animated:YES];
	}
}


- (void)_locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
    //	NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
}


- (void)_locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
}


- (void)_locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    //	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
}


@end
