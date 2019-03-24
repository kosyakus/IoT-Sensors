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

@interface CalibrationSettingsV2 : CalibrationSettings

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
@property uint16_t magAlpha;
@property uint16_t magDeltaThresh;
@property uint16_t muOffset;
@property uint16_t muMatrix;
@property uint16_t errAlpha;
@property uint16_t errThresh;

@end
