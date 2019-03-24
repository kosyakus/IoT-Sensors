/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AmbientLightSensor.h"

static NSString* const LOG_TAG = @"AMB";
static NSString* const LOG_UNIT = @" lux";

@implementation AmbientLightSensor

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return AmbientLightSensor.LOG_TAG;
}

- (NSString*) logValueUnit {
    return AmbientLightSensor.LOG_UNIT;
}

@end
