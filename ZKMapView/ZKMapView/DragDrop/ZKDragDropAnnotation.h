//
//  ZKDragDropAnnotation.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 06/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKDragDropAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) NSString *title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end
