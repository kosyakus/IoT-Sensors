/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "HumiditySensor.h"

static NSString* const LOG_TAG = @"HMD";
static NSString* const LOG_UNIT = @"%";

@implementation HumiditySensor

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return HumiditySensor.LOG_TAG;
}

- (NSString*) logValueUnit {
    return HumiditySensor.LOG_UNIT;
}

@end
