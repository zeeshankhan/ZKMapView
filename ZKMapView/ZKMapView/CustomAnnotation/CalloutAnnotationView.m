//
//  CalloutAnnotationView.m
//  CustomCalloutSample
//
//  Created by Zeeshan Khan on 09/01/2011.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "CalloutAnnotationView.h"
#import "PinAnnotation.h"

NSString* const CalloutReuseIdentifier = @"CalloutReuse";

@interface CalloutAnnotationView ()

@property (nonatomic,strong) UILabel *lblTitle;
@property (nonatomic,strong) UILabel *lblAddress;
@property (nonatomic,strong) UILabel *lblPrice;

@property (nonatomic,assign) CGFloat cellInsetX;
@property (nonatomic,assign) CGFloat cellOffsetY;

@property (nonatomic,assign) CGPoint offsetFromParent;
@property (nonatomic,readonly) CGFloat yShadowOffset;

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic,strong) UIView *contentView;

- (void)prepareFrameSize;
- (void)prepareOffset;
- (void)enableSibling:(MKAnnotationView *)sibling;
- (void)preventParentSelectionChange;
- (void)allowParentSelectionChange;

- (UIView*)getView;

// Abstract Class Vars and Methods
@property (nonatomic,readonly) CGSize actualSize; // content Size + buffers
@property (nonatomic,assign) BOOL animateOnNextDrawRect;
@property (nonatomic,assign) CGRect endFrame;
- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;
- (CGFloat)relativeParentXPosition;
- (void)adjustMapRegionIfNeeded;
@end


@implementation CalloutAnnotationView

@synthesize cellInsetX = _cellInsetX;
@synthesize cellOffsetY = _cellOffsetY;
@synthesize parentAnnotationView = _parentAnnotationView;
@synthesize mapView = _mapView;
@synthesize animateOnNextDrawRect = _animateOnNextDrawRect;
@synthesize endFrame = _endFrame;
@synthesize yShadowOffset = _yShadowOffset;
@synthesize offsetFromParent = _offsetFromParent;

@synthesize contentView = _contentView;
@synthesize contentSize = _contentSize;

@synthesize title = title_;
@synthesize dicViewData;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];

    if (self) {
        _yShadowOffset = 6;
        self.offsetFromParent = CGPointMake(8, -14); //this works for MKPinAnnotationView
        self.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.cellInsetX = 15;
        self.cellOffsetY = 10;
        
        [[NSBundle mainBundle] loadNibNamed:@"CalloutAnnotationView" owner:self options:nil];
        
        UIView *customView = [self calloutView]; // [self getView]; //
        
        [self.contentView addSubview:customView];
        self.contentSize = customView.frame.size;
        
        self.frame = customView.frame; // CGRectMake(0.0f, 0.0f, 100.0f, 200.0f); //
    }

    return self;
}


- (UIView*)getView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 160, 20)];
    [_lblTitle setBackgroundColor:[UIColor clearColor]];
    [_lblTitle setTextColor:[UIColor whiteColor]];
    [_lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [view addSubview:_lblTitle];

    _lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 34, 160, 40)];
    [_lblAddress setBackgroundColor:[UIColor clearColor]];
    [_lblAddress setTextColor:[UIColor whiteColor]];
    [_lblAddress setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [_lblAddress setNumberOfLines:2];
    [view addSubview:_lblAddress];

    UIButton *btnSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSelect setFrame:CGRectMake(10, 82, 72, 30)];
    [btnSelect addTarget:self action:@selector(selectClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnSelect setTitle:@"Select" forState:UIControlStateNormal];
    [view addSubview:btnSelect];

    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 121, 170, 1)];
    [line setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:line];

    UILabel *_lblPriceTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, 80, 20)];
    [_lblPriceTitle setBackgroundColor:[UIColor clearColor]];
    [_lblPriceTitle setTextColor:[UIColor whiteColor]];
    [_lblPriceTitle setText:@"Total Price:"];
    [_lblPriceTitle setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [view addSubview:_lblPriceTitle];

    _lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(85, 126, 75, 28)];
    [_lblPrice setBackgroundColor:[UIColor clearColor]];
    [_lblPrice setTextColor:[UIColor whiteColor]];
    [_lblPrice setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [_lblPrice setTextAlignment:UITextAlignmentLeft];
    [view addSubview:_lblPrice];
    
    return  view;
}

- (void)selectClicked {
    NSLog(@"Select clicked...");
}

#pragma mark - Setters and Accessors

- (void)setAnnotation:(id <MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    if (!annotation)
        return;
    [self prepareFrameSize];
    [self prepareOffset];
    self.contentView.frame = CGRectMake(self.bounds.origin.x + 10, self.bounds.origin.y + 3, self.contentSize.width, self.contentSize.height);
    [self setNeedsDisplay];
}

#pragma mark - Selection/Deselection

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    //If the accessory is hit, the map view may want to select an annotation sitting below it, so we must disable the other annotations ... But not the parent because that will screw up the selection
    if ([hitView isKindOfClass:[UIButton class]]) {
        [self preventParentSelectionChange];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(allowParentSelectionChange) object:nil];
        [self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:1.0];
        for (UIView *aView in self.superview.subviews) {
            if ([aView isKindOfClass:[MKAnnotationView class]] && aView != self.parentAnnotationView) {
                MKAnnotationView *sibling = (MKAnnotationView *)aView;
                sibling.enabled = NO;
                [self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:1.0];
            }
        }
    }
    return hitView;
}

- (void)enableSibling:(MKAnnotationView *)sibling {
    sibling.enabled = YES;
}

- (void)preventParentSelectionChange {
    if (_parentAnnotationView && [_parentAnnotationView respondsToSelector:@selector(setPreventSelectionChange:)]) {
        PinAnnotation *parentView = (PinAnnotation *)self.parentAnnotationView;
        parentView.preventSelectionChange = YES;
    }
}

- (void)allowParentSelectionChange {
    if (!_mapView || !_parentAnnotationView)
        return;
    //The MapView may think it has deselected the pin, so we should re-select it
    [self.mapView selectAnnotation:self.parentAnnotationView.annotation animated:NO];
    if ([_parentAnnotationView respondsToSelector:@selector(setPreventSelectionChange:)]) {
        PinAnnotation *parentView = (PinAnnotation *)_parentAnnotationView;
        parentView.preventSelectionChange = NO;
    }
}

#pragma mark - Abstract Class Methods

#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 2.0f

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!_mapView)
        return;
    [self adjustMapRegionIfNeeded];
    [self animateIn];
    [self setNeedsLayout];
}

- (CGSize)actualSize {
    return CGSizeMake(self.contentSize.width + 20, self.contentSize.height + CalloutMapAnnotationViewContentHeightBuffer + CalloutMapAnnotationViewBottomShadowBufferSize - self.offsetFromParent.y);
}

- (void)prepareFrameSize {
    CGRect frame = self.frame;
    frame.size = [self actualSize];
    self.frame = frame;
}

- (void)prepareOffset {
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    CGFloat xOffset =    (self.actualSize.width / 2) - (parentOrigin.x + self.offsetFromParent.x);
    //Add half our height plus half of the height of the annotation we are tied to so that our bottom lines up to its top
    //Then take into account its offset and the extra space needed for our drop shadow
    CGFloat yOffset = -(self.frame.size.height / 2 + self.parentAnnotationView.frame.size.height / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    self.centerOffset = CGPointMake(xOffset, yOffset);
}

//if the pin is too close to the edge of the map view we need to shift the map view so the callout will fit.
- (void)adjustMapRegionIfNeeded {
    if (!_mapView)
        return;
    
    //Longitude
    CGFloat xPixelShift = 0;
    if ([self relativeParentXPosition] < 38) {
        xPixelShift = 38 - [self relativeParentXPosition];
    } else if ([self relativeParentXPosition] > self.frame.size.width - 38) {
        xPixelShift = (self.frame.size.width - 38) - [self relativeParentXPosition];
    }
    
    //Latitude
    CGPoint mapViewOriginRelativeToParent = [self.mapView convertPoint:self.mapView.frame.origin toView:self.parentAnnotationView];
    CGFloat yPixelShift = 0;
    CGFloat pixelsFromTopOfMapView = -(mapViewOriginRelativeToParent.y + self.frame.size.height - CalloutMapAnnotationViewBottomShadowBufferSize);
    CGFloat pixelsFromBottomOfMapView = self.mapView.frame.size.height + mapViewOriginRelativeToParent.y - self.parentAnnotationView.frame.size.height;
    if (pixelsFromTopOfMapView < 7) {
        yPixelShift = 7 - pixelsFromTopOfMapView;
    } else if (pixelsFromBottomOfMapView < 10) {
        yPixelShift = -(10 - pixelsFromBottomOfMapView);
    }
    
    //Calculate new center point, if needed
    if (xPixelShift || yPixelShift) {
        CGFloat pixelsPerDegreeLongitude = self.mapView.frame.size.width / self.mapView.region.span.longitudeDelta;
        CGFloat pixelsPerDegreeLatitude = self.mapView.frame.size.height / self.mapView.region.span.latitudeDelta;
        
        CLLocationDegrees longitudinalShift = -(xPixelShift / pixelsPerDegreeLongitude);
        CLLocationDegrees latitudinalShift = yPixelShift / pixelsPerDegreeLatitude;
        
        CLLocationCoordinate2D newCenterCoordinate = {self.mapView.region.center.latitude + latitudinalShift, self.mapView.region.center.longitude + longitudinalShift};
        
        [self.mapView setCenterCoordinate:newCenterCoordinate animated:YES];
        
        //fix for now
        self.frame = CGRectMake(self.frame.origin.x - xPixelShift, self.frame.origin.y - yPixelShift, self.frame.size.width, self.frame.size.height);
        //fix for later (after zoom or other action that resets the frame)
        self.centerOffset = CGPointMake(self.centerOffset.x - xPixelShift, self.centerOffset.y);
    }
}

- (CGFloat)xTransformForScale:(CGFloat)scale {
    CGFloat xDistanceFromCenterToParent = self.endFrame.size.width / 2 - [self relativeParentXPosition];
    return (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent;
}

- (CGFloat)yTransformForScale:(CGFloat)scale {
    CGFloat yDistanceFromCenterToParent = (((self.endFrame.size.height) / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize + CalloutMapAnnotationViewHeightAboveParent);
    return yDistanceFromCenterToParent - yDistanceFromCenterToParent * scale;
}

- (void)animateIn {
    self.endFrame = self.frame;
    CGFloat scale = 0.001f;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView beginAnimations:@"animateIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.075];
    [UIView setAnimationDidStopSelector:@selector(animateInStepTwo)];
    [UIView setAnimationDelegate:self];
    scale = 1.1;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)animateInStepTwo {
    [UIView beginAnimations:@"animateInStepTwo" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDidStopSelector:@selector(animateInStepThree)];
    [UIView setAnimationDelegate:self];
    CGFloat scale = 0.95;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)animateInStepThree {
    [UIView beginAnimations:@"animateInStepThree" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.075];
    CGFloat scale = 1.0;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    _lblTitle.text = [self.dicViewData objectForKey:@"title"];
    _lblAddress.text = [self.dicViewData objectForKey:@"address"];
    _lblPrice.text = [self.dicViewData objectForKey:@"price"];
    
    CGFloat stroke = 1.0;
    CGFloat radius = 7.0;
    CGMutablePathRef path = CGPathCreateMutable();
    UIColor *color;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat parentX = [self relativeParentXPosition];
    //Determine Size
    rect = self.bounds;
    rect.size.width -= stroke + 14;
    rect.size.height -= stroke + CalloutMapAnnotationViewHeightAboveParent - self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    rect.origin.x += stroke / 2.0 + 7;
    rect.origin.y += stroke / 2.0;
    
    //Create Path For Callout Bubble
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, parentX - 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 15);
    CGPathAddLineToPoint(path, NULL, parentX + 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(path);
    
    //Fill Callout Bubble & Add Shadow
    color = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake (0, self.yShadowOffset), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    //Stroke Callout Bubble
    color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
    [color setStroke];
    CGContextSetLineWidth(context, stroke);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    //Determine Size for Gloss
    CGRect glossRect = self.bounds;
    glossRect.size.width = rect.size.width - stroke;
    glossRect.size.height = (rect.size.height - stroke) / 2;
    glossRect.origin.x = rect.origin.x + stroke / 2;
    glossRect.origin.y += rect.origin.y + stroke / 2;
    
    CGFloat glossTopRadius = radius - stroke / 2;
    CGFloat glossBottomRadius = radius / 1.5;
    
    //Create Path For Gloss
	CGMutablePathRef glossPath = CGPathCreateMutable();
	CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, -M_PI / 2, M_PI, 1);
	CGPathCloseSubpath(glossPath);
    
    //Fill Gloss Path    
    CGContextAddPath(context, glossPath);
    CGContextClip(context);
    CGFloat colors[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
    };
    CGFloat locations[] = { 0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
    CGPoint startPoint = glossRect.origin;
    CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    //Gradient Stroke Gloss Path    
    CGContextAddPath(context, glossPath);
    CGContextSetLineWidth(context, 2);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    CGFloat colors2[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
        1, 1, 1, .0,
    };
    CGFloat locations2[] = { 0, .1, 1.0 };
    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
    CGPoint startPoint2 = glossRect.origin;
    CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
    
    //Cleanup
    CGPathRelease(path);
    CGPathRelease(glossPath);
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    CGGradientRelease(gradient2);
}

- (CGFloat)relativeParentXPosition {
    if (!_mapView || !_parentAnnotationView)
        return 0;
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    return parentOrigin.x + self.offsetFromParent.x;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
    }
    return _contentView;
}

@end
