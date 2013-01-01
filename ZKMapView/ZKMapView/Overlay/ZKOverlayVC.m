//
//  ZKOverlayVC.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 29/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKOverlayVC.h"
#import "ZKOverlayAnnotation.h"

@interface ZKOverlayVC ()
@end

@implementation ZKOverlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Overlay";
    
    ZKOverlayAnnotation *annontation = [[ZKOverlayAnnotation alloc] init];
    annontation.coordinate = CLLocationCoordinate2DMake(37.0625f, -95.677068f);
    annontation.title = @"Annotation Title";
    [_overlayMap addAnnotation:annontation];

    MKCircle *circle = [MKCircle circleWithCenterCoordinate:annontation.coordinate radius:5000];
    [_overlayMap addOverlay:circle];

    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(annontation.coordinate, 15000.0, 15000.0);
    [_overlayMap setRegion:userLocation animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setOverlayMap:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    if([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor blueColor];
		circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
		return circleView;
	}
	
	return nil;
}

- (IBAction)radiusSlider:(UISlider*)sender {
    
    ZKOverlayAnnotation *annotation = (ZKOverlayAnnotation*)[_overlayMap.annotations objectAtIndex:0];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:sender.value];
    [_overlayMap addOverlay:circle];

//    dispatch_async(dispatch_get_main_queue(), ^{
        while ([[_overlayMap overlays] count] > 1) {
            [_overlayMap removeOverlay:[[_overlayMap overlays] objectAtIndex:0]];
        }
//    });
}


@end
