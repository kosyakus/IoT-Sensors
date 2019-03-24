/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensor.h"

@interface ButtonSensor : IotSensor

@property uint32_t ID;
@property BOOL state;

- (BOOL) isPressed:(int)ID;
- (BOOL) isPressed;

+ (NSString*) LOG_TAG;

@end
