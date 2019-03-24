/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "PressureSensor.h"

static NSString* const LOG_TAG = @"PRS";
static NSString* const LOG_UNIT = @" Pa";

@implementation PressureSensor

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return PressureSensor.LOG_TAG;
}

- (NSString*) logValueUnit {
    return PressureSensor.LOG_UNIT;
}

@end
