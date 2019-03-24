/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSensorViewController.h"

@implementation BasicSensorViewController {
    NSTimer* updateTimer;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    delay = 0.1;
    chartAutoScale = TRUE;

    [self.chartView setViewPortOffsetsWithLeft:0.f top:20.f right:0.f bottom:0.f];
    self.chartView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    self.chartView.descriptionText = @"";
    self.chartView.noDataText = @"";

    self.chartView.dragEnabled = NO;
    self.chartView.scaleEnabled = NO;
    self.chartView.pinchZoomEnabled = NO;
    self.chartView.drawGridBackgroundEnabled = NO;

    self.chartView.xAxis.enabled = NO;
    
    ChartYAxis *yAxis = self.chartView.leftAxis;
    yAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    [yAxis setLabelCount:6 force:NO];
    yAxis.labelTextColor = UIColor.whiteColor;
    yAxis.labelPosition = YAxisLabelPositionOutsideChart;
    yAxis.drawGridLinesEnabled = NO;
    yAxis.axisLineColor = UIColor.whiteColor;

    self.chartView.rightAxis.enabled = NO;
    self.chartView.legend.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.needsUpdate = true;
    [self update];
    if (!updateTimer)
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (ChartDataEntryBuffer*) graphData {
    return nil;
}

- (void) update {
    if (!self.needsUpdate)
        return;
    self.needsUpdate = false;

    [self updateChart];
    [self updateUI];
}

- (void) updateUI {
}

- (void) updateChart {
    if (self.graphData.isEmpty)
        return;

    LineChartDataSet *set = [self generateDataSetFromData:self.graphData.data];
    LineChartData *data = [[LineChartData alloc] initWithDataSet:set];
    [self updateChartMinMax:data];
    data.drawValues = NO;

    self.chartView.xAxis.axisMinimum = self.graphData.lastIndex - (int) self.graphData.capacity;
    self.chartView.autoScaleMinMaxEnabled = chartAutoScale;
    if (!chartAutoScale) {
        [self.chartView getAxis:AxisDependencyLeft].axisMinimum = chartMin;
        [self.chartView getAxis:AxisDependencyLeft].axisMaximum = chartMax;
    }
    
    self.chartView.data = data;
}

- (void) updateChartMinMax:(LineChartData*)data {
}

- (LineChartDataSet*) generateDataSetFromData:(NSArray*)data {
    LineChartDataSet* set = [[LineChartDataSet alloc] initWithValues:data label:@""];
    set.drawCubicEnabled = NO;
    set.cubicIntensity = 0.2;
    set.drawCirclesEnabled = NO;
    set.lineWidth = 0;
    set.circleRadius = 4.0;
    set.circleColor = UIColor.blackColor;
    set.highlightEnabled = NO;
    set.color = [UIColor colorWithWhite:0 alpha:0.05];
    set.fillColor = UIColor.blackColor;
    set.fillAlpha = 0.05f;
    set.drawHorizontalHighlightIndicatorEnabled = NO;
    set.drawFilledEnabled = YES;
    return set;
}

@end
