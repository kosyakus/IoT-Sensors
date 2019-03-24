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

@interface CalibrationSettingsV1 : CalibrationSettings

@property NSData* raw;
@property uint8_t sensor;
@property uint16_t controlFlags;
@property BOOL apply;
@property BOOL matrixApply;
@property BOOL update;
@property BOOL matrixUpdate;
@property BOOL initFromStatic;
@property uint16_t refMag;
@property uint16_t magRange;
@property int16_t mu;

@end
