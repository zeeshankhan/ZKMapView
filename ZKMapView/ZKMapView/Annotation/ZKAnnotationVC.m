//
//  ZKAnnotationVC.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKAnnotationVC.h"
#import "ZKAnnotation.h"

@interface ZKAnnotationVC ()
@end

@implementation ZKAnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Drag & Drop Annotation";
    
    ZKAnnotation *annontation = [[ZKAnnotation alloc] init];
    annontation.coordinate = CLLocationCoordinate2DMake(37.0625f, -95.677068f);
    annontation.title = @"Annotation Title";
    annontation.subtitle = @"Detail Sub Title";
    [_annotationMapView addAnnotation:annontation];
    
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(annontation.coordinate, 15000.0, 15000.0);
    [_annotationMapView setRegion:userLocation animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAnnotationMapView:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[_annotationMapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (pinView == nil) {
        
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;

        //pinView.draggable = YES;
        
        UIButton *btnDetail = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = btnDetail;
        
        UIButton *btnThumb = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnThumb setFrame:CGRectMake(0, 0, 30, 30)];
        [btnThumb setImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
        pinView.leftCalloutAccessoryView = btnThumb;
    }
    else
		pinView.annotation = annotation;
	
	return pinView;
}


@end
