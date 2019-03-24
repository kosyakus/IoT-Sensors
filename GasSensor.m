/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "GasSensor.h"

static NSString* const LOG_TAG = @"GAS";
static NSString* const LOG_UNIT = @" Ohm";

@implementation GasSensor

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return GasSensor.LOG_TAG;
}

- (NSString*) logValueUnit {
    return GasSensor.LOG_UNIT;
}

@end
