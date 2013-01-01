//
//  ZKCustomAnnotation.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKCustomAnnotationVC.h"
#import "PinAnnotation.h"
#import "CalloutAnnotation.h"
#import "CalloutAnnotationView.h"

@interface ZKCustomAnnotationVC ()
@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
- (UIImage *)getPinImageWithTag:(NSString*)strTag;
@end

@implementation ZKCustomAnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Custom Annotation";
    
    // Pin annotation.
    NSMutableArray *locationArray = [NSMutableArray arrayWithCapacity:0];
    [locationArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"1",@"tag",
                              @"1. ABC", @"title",
                              @"Indore, MP, India",@"address",
                              @"$59",@"price",
                              [NSNumber numberWithFloat:34.255146f],  @"lat",
                              [NSNumber numberWithFloat:133.519502f], @"lon", nil]];
    [locationArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"2",@"tag",
                              @"2. PQR", @"title",
                              @"Pune, MH, India",@"address",
                              @"$69",@"price",
                              [NSNumber numberWithFloat:34.355146f],  @"lat",
                              [NSNumber numberWithFloat:133.619502f], @"lon", nil]];
    [locationArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"3",@"tag",
                              @"3. MNO", @"title",
                              @"New Jursy, USA",@"address",
                              @"$79",@"price",
                              [NSNumber numberWithFloat:34.555146f],  @"lat",
                              [NSNumber numberWithFloat:133.919502f], @"lon", nil]];
    [locationArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"4",@"tag",
                              @"4. XYZ", @"title",
                              @"Sydney, Austrailia",@"address",
                              @"$89",@"price",
                              [NSNumber numberWithFloat:34.755146f],  @"lat",
                              [NSNumber numberWithFloat:133.819502f], @"lon", nil]];
    [locationArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"5",@"tag",
                              @"5. QWE", @"title",
                              @"London, Great Britain",@"address",
                              @"$99",@"price",
                              [NSNumber numberWithFloat:34.955146f],  @"lat",
                              [NSNumber numberWithFloat:133.719502f], @"lon", nil]];
    
    // Add annotations on the MapView.
    PinAnnotation *pinAnnotation;
    CLLocationCoordinate2D coordinate;
    for (NSDictionary *location in locationArray) {
        coordinate.latitude  = [[location objectForKey:@"lat"] floatValue];
        coordinate.longitude = [[location objectForKey:@"lon"] floatValue];
        
        pinAnnotation = [[PinAnnotation alloc] init];
        pinAnnotation.title      = (NSString *)[location objectForKey:@"title"];
        pinAnnotation.dicData      = (NSDictionary *)location;
        pinAnnotation.coordinate = coordinate;
        [[self zkMapView] addAnnotation:pinAnnotation];
    }
    
    [self zkMapView].region = MKCoordinateRegionMakeWithDistance(coordinate, 100000, 100000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setZkMapView:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapViewDelegate
#pragma mark - MapView delegate.

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView;
    NSString *identifier;
    
    if ([annotation isKindOfClass:[PinAnnotation class]]) {
        
        // Pin annotation.
        identifier = @"Pin";
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            PinAnnotation *pinAnnotation = (PinAnnotation *)annotation;
            annotationView.image = [self getPinImageWithTag:[pinAnnotation.dicData objectForKey:@"tag"]];
        }
        
    } else if ([annotation isKindOfClass:[CalloutAnnotation class]]) {
        
        // Callout annotation.
        identifier = CalloutReuseIdentifier;
        annotationView = (CalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[CalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        CalloutAnnotation *calloutAnnotation = (CalloutAnnotation *)annotation;
        ((CalloutAnnotationView *)annotationView).title = calloutAnnotation.title;
        ((CalloutAnnotationView *)annotationView).dicViewData = calloutAnnotation.dicData;
        ((CalloutAnnotationView *)annotationView).parentAnnotationView = self.selectedAnnotationView;
        ((CalloutAnnotationView *)annotationView).mapView = mapView;
        
        [annotationView setNeedsDisplay];
        
        mapView.centerCoordinate = calloutAnnotation.coordinate;
    }
    
    annotationView.annotation = annotation;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        
        // Selected the pin annotation.
        CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] init];
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        calloutAnnotation.title      = pinAnnotation.title;
        calloutAnnotation.dicData = pinAnnotation.dicData;
        calloutAnnotation.coordinate = pinAnnotation.coordinate;
        pinAnnotation.calloutAnnotation = calloutAnnotation;
        
        [mapView addAnnotation:calloutAnnotation];
        self.selectedAnnotationView = view;
        [mapView setCenterCoordinate:pinAnnotation.coordinate animated:YES];
    }
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        
        // Deselected the pin annotation.
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        [mapView removeAnnotation:pinAnnotation.calloutAnnotation];
        pinAnnotation.calloutAnnotation = nil;
    }
}

#pragma mark - Annotation Pin Image

- (UIImage *)getPinImageWithTag:(NSString*)strTag {
	
	int smallFontSize=12;
	
    CGRect aFrame = CGRectMake(0.0f, 0.0f, 21.0f, 34.0f);
	CGSize mySize = aFrame.size;
	
	UIGraphicsBeginImageContext(mySize);
	UIImage *backgroundImage = [UIImage imageNamed:@"mapTree.png"];
	CGRect elementSymbolRectangle = CGRectMake(0.0f ,0.0f, aFrame.size.width, aFrame.size.height);
	[backgroundImage drawInRect:elementSymbolRectangle];
	
	// draw the element name
	[[UIColor blackColor] set];
	
	// draw the element number
	UIFont *font = [UIFont boldSystemFontOfSize:(smallFontSize)];
    
    CGPoint point;
    if ([strTag length] == 1)
        point = CGPointMake(6,2);
    else
        point = CGPointMake(6,2);
    
	[strTag drawAtPoint:point withFont:font];
	
	//get image
	UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return (theImage);
}


@end
