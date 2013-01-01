//
//  ZKAnnotationVC.h
//  ZKMapView
//
//  Created by Zeeshan Khan on 17/11/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKAnnotationVC : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *annotationMapView;

@end
