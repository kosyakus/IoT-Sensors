/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CalibrationSettings.h"

@implementation CalibrationSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    return self;
}

- (void) enableSettingsForCalibrationMode:(NSDictionary*)spec {
}

@end
