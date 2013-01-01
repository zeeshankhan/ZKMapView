//
//  ZKViewController.m
//  ZKMapView
//
//  Created by Zeeshan Khan on 24/10/12.
//  Copyright (c) 2012 Zeeshan Khan. All rights reserved.
//

#import "ZKViewController.h"

#import "ZKRouteVC.h"
#import "ZKOverlayVC.h"
#import "ZKAnnotationVC.h"
#import "ZKDragDropVC.h"
#import "ZKCurrentLocationVC.h"
#import "ZKCustomAnnotationVC.h"

@interface ZKViewController ()
@property (nonatomic, strong) NSArray *arrMapItems;
@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"Map Items";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MapItemList" ofType:@"plist"];
    _arrMapItems = [[NSArray alloc] initWithContentsOfFile:filePath];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrMapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *strIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [_arrMapItems objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    switch (indexPath.row) {
        case 0: {
            ZKOverlayVC *overlayObj = [[ZKOverlayVC alloc] initWithNibName:@"ZKOverlayVC" bundle:nil];
            [self.navigationController pushViewController:overlayObj animated:YES];
        }
            break;
        case 1: {
            ZKRouteVC *routeObj = [[ZKRouteVC alloc] initWithNibName:@"ZKRouteVC" bundle:nil];
            [self.navigationController pushViewController:routeObj animated:YES];
        }
            break;
        case 2: {
            ZKAnnotationVC *obj = [[ZKAnnotationVC alloc] initWithNibName:@"ZKAnnotationVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
            break;
        case 3: {
            ZKDragDropVC *obj = [[ZKDragDropVC alloc] initWithNibName:@"ZKDragDropVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
            break;
        case 4: {
            ZKCurrentLocationVC *obj = [[ZKCurrentLocationVC alloc] initWithNibName:@"ZKCurrentLocationVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
            break;
        case 5: {
            ZKCustomAnnotationVC *obj = [[ZKCustomAnnotationVC alloc] initWithNibName:@"ZKCustomAnnotationVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
            break;
    }
}

@end
