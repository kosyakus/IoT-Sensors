/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "IoT_Sensors-Swift.h"
#import "IotSensorsDevice.h"

@interface BasicSensorViewController : UIViewController {
    BOOL chartAutoScale;
    float delay;
    float chartMin, chartMax;
}

@property IotSensorsDevice* device;
@property IotSensor* sensor;
@property BOOL needsUpdate;

@property (weak, nonatomic) IBOutlet LineChartView *chartView;

- (ChartDataEntryBuffer*) graphData;
- (void) update;
- (void) updateUI;
- (void) updateChart;
- (void) updateChartMinMax:(LineChartData*)data;
- (LineChartDataSet*) generateDataSetFromData:(NSArray*)data;

@end
