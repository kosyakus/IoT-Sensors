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

@implementation IotDeviceSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super init];
    if (!self)
        return nil;
    self.device = device;
    return self;
}

- (void) process:(NSData*)data offset:(int)offset {
}

- (NSData*) pack {
    return nil;
}

- (void) save:(NSDictionary*)spec {
}

- (void) load:(NSDictionary*)spec {
}

@end
