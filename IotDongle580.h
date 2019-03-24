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
#import "BME280.h"
#import "BMI160.h"
#import "BMM150.h"

@interface IotDongle580 : IotDeviceSpec

@property BME280* environmental;
@property BMI160* imu;
@property BMM150* magneto;

@end
