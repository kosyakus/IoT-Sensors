/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDeviceSpec.h"
#import "BME680.h"
#import "ICM40605.h"
#import "AK09915C.h"
#import "VCNL4010.h"

@interface IotPlus585 : IotDeviceSpec

@property BME680* environmental;
@property ICM40605* imu;
@property AK09915C* magneto;
@property VCNL4010* light;

@end
