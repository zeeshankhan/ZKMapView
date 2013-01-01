//
//  ZKDragDropVC.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 06/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKDragDropVC.h"
#import "ZKDragDropAnnotation.h"

@interface ZKDragDropVC ()

@end

@implementation ZKDragDropVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Drag & Drop Annotation";
    
    ZKDragDropAnnotation *annontation = [[ZKDragDropAnnotation alloc] init];
    annontation.coordinate = CLLocationCoordinate2DMake(37.0625f, -95.677068f);
    annontation.title = @"Annotation Title";
    [_dragDropAnnotationMapView addAnnotation:annontation];
    
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(annontation.coordinate, 15000.0, 15000.0);
    [_dragDropAnnotationMapView setRegion:userLocation animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDragDropAnnotationMapView:nil];
    [super viewDidUnload];
}

#pragma mark - MapView delegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

    if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
        ZKDragDropAnnotation *annotation = (ZKDragDropAnnotation *)annotationView.annotation;
        annotation.title = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKPinAnnotationView *draggablePinView = (MKPinAnnotationView*)[_dragDropAnnotationMapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView == nil) {
		draggablePinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
        draggablePinView.draggable = YES;
        draggablePinView.animatesDrop = YES; // only in MKPinAnnotationView
        draggablePinView.canShowCallout = YES;
    }
    else
		draggablePinView.annotation = annotation;
	
	return draggablePinView;
}

@end
