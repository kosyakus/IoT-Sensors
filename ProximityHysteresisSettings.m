/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ProximityHysteresisSettings.h"
#import "IotSensorsDevice.h"

@implementation ProximityHysteresisSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 4;
    return self;
}

- (void) process:(NSData*)data offset:(int)offset {
    self.raw = [data subdataWithRange:NSMakeRange(offset, self.length)];
    const uint16_t* raw = self.raw.bytes;

    self.lowLimit = CFSwapInt16LittleToHost(raw[0]);
    self.highLimit = CFSwapInt16LittleToHost(raw[1]);
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    uint16_t raw[] = {
        CFSwapInt16HostToLittle(self.lowLimit),
        CFSwapInt16HostToLittle(self.highLimit),
    };

    self.modified = memcmp(self.raw.bytes, raw, self.length) != 0;
    return [NSData dataWithBytes:raw length:self.length];
}

- (void) save:(NSDictionary*)spec {
    IotSettingsItem* i = spec[@"ProximityHysteresis"];
    i.values = @[ @(self.lowLimit), @(self.highLimit) ];
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i = spec[@"ProximityHysteresis"];
    self.lowLimit = [i.values[0] intValue];
    self.highLimit = [i.values[1] intValue];
}

@end
