//
//  MapViewController.m
//  IoT-Sensors
//
//  Created by Natali on 25/03/2019.
//  Copyright © 2019 Dialog Semiconductor. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    YMKPoint *target = [YMKPoint pointWithLatitude:55.677688 longitude:37.632798];
    [self.mapView.mapWindow.map moveWithCameraPosition:[YMKCameraPosition cameraPositionWithTarget:target
                                                                                              zoom:30
                                                                                           azimuth:0
                                                                                              tilt:0]];
    
    
    YMKPlacemarkMapObject *placemark = [self.mapView.mapWindow.map.mapObjects addPlacemarkWithPoint: target];
    placemark.opacity = 0.5;
    placemark.draggable = true;
    [placemark setIconWithImage:[UIImage imageNamed: @"icon-button-pressed"]];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
