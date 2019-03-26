//
//  MapViewController.h
//  IoT-Sensors
//
//  Created by Natali on 25/03/2019.
//  Copyright © 2019 Dialog Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YandexMapKit/YMKMapKitFactory.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet YMKMapView *mapView;

@end

NS_ASSUME_NONNULL_END
