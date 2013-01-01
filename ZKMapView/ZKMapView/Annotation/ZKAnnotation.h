//
//  ZKAnnotation.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKAnnotation : NSObject <MKAnnotation>
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end
