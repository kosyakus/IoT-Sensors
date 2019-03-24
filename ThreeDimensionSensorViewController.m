/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ThreeDimensionSensorViewController.h"

@implementation ThreeDimensionSensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    delay = 0.1;

    self.modelView.backgroundColor = [UIColor clearColor];
    self.modelView.texture = nil;
    self.modelView.blendColor = [UIColor whiteColor];
}

- (ChartDataEntryBuffer3D*) graphData3D {
    return nil;
}

- (void) updateChart {
    if (self.graphData3D.isEmpty)
        return;

    LineChartDataSet *setX = [self generateDataSetFromData:self.graphData3D.X.data];
    LineChartDataSet *setY = [self generateDataSetFromData:self.graphData3D.Y.data];
    LineChartDataSet *setZ = [self generateDataSetFromData:self.graphData3D.Z.data];
    LineChartData *data = [[LineChartData alloc] initWithDataSets:@[setX, setY, setZ]];
    data.drawValues = NO;

    self.chartView.xAxis.axisMinimum = self.graphData3D.lastIndex - (int) self.graphData3D.capacity;
    self.chartView.autoScaleMinMaxEnabled = chartAutoScale;
    if (!chartAutoScale) {
        [self.chartView getAxis:AxisDependencyLeft].axisMinimum = chartMin;
        [self.chartView getAxis:AxisDependencyLeft].axisMaximum = chartMax;
    }
    
    self.chartView.data = data;
}

@end
