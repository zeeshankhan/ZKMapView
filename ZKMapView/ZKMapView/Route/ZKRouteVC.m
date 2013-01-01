//
//  ZKRouteVC.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 25/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKRouteVC.h"
#import "ZKNetworkHandler.h"

@interface ZKRouteVC ()
@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) ZKNetworkHandler *routeStore;
@end

@implementation ZKRouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Route";
    
    _routeStore = [ZKNetworkHandler sharedInstance];
    
    [_routeStore getRouteFrom:@"Hays" to:@"Salina" completionHandler:^(id responseObject, NSError *error) {
        if (responseObject != nil) {
            
            MKPolyline *line = [_routeStore getPolyLine:(NSDictionary*)responseObject];
            [self setRouteLine:line];
            [_routeMapView addOverlay:line];
            
            NSString *str = nil;

            MKPointAnnotation* a = [_routeStore sourceLocationOfRoute:(NSDictionary*)responseObject andAddress:&str];
            [_routeMapView addAnnotation:a];
            
            [_routeMapView addAnnotation:[_routeStore destinationLocationOfRoute:(NSDictionary*)responseObject andAddress:&str]];

            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(a.coordinate, 1000000.0/2, 1000000.0/2);
            MKCoordinateRegion adjustedRegion = [_routeMapView regionThatFits:viewRegion];
            [_routeMapView setRegion:adjustedRegion animated:YES];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate
/* Not required, Use only when you want to customize something.
 */
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
		MKPinAnnotationView* pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
		pin.canShowCallout = YES;
//		if (annotation == _source) {
//			pin.pinColor = MKPinAnnotationColorGreen;
//		} else {
//			pin.pinColor = MKPinAnnotationColorRed;
//		}
		return pin;
	}
    else
        return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay {
    if (_routeLine) {
        MKPolylineView* routeLineView = [[MKPolylineView alloc] initWithPolyline:_routeLine];
        routeLineView.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
        routeLineView.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
        routeLineView.lineWidth = 4;
        return routeLineView;
    }
    else
        return nil;
}


- (void)viewDidUnload {
    [self setRouteMapView:nil];
    [super viewDidUnload];
}

@end
