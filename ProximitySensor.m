/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ProximitySensor.h"

static NSString* const LOG_TAG = @"PRX";

@implementation ProximitySensor

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

- (NSString*) logTag {
    return ProximitySensor.LOG_TAG;
}

- (NSString*) logEntry {
    return self.objectNearby ? @"ON" : @"OFF";
}

- (NSString*) cloudData {
    return self.objectNearby ? @"true" : @"false";
}

@end
