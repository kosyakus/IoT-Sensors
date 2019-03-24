/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSettingsManager.h"
#import "CalibrationSettings.h"

@interface CalibrationSettingsManager : IotSettingsManager

@property CalibrationSettings* settings;

- (void) saveCoefficients;
- (BOOL) loadCoefficients:(NSString*)filePath;

@end
