/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDeviceSettings.h"

@interface BasicSettingsIotPlus : IotDeviceSettings

@property NSData* raw;
@property uint8_t sensorCombination;
@property int sflCombination;
@property int imuCombination;
@property BOOL envEnabled;
@property BOOL gasEnabled;
@property BOOL amblEnabled;
@property BOOL proxEnabled;
@property uint8_t accRange;
@property uint8_t accRate;
@property uint8_t gyroRange;
@property uint8_t gyroRate;
@property uint8_t magnetoRate;
@property uint8_t envRate;
@property uint8_t sflRate;
@property BOOL sflEnabled;
@property uint8_t sflMode;
@property BOOL sflRawEnabled;
@property uint8_t rawDataType;
@property int operationMode;
@property uint8_t gasRate;
@property uint8_t proxAmblMode;
@property int proxMode;
@property int amblMode;
@property uint8_t proxAmblRate;

@end
