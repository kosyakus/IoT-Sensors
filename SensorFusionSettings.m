/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorFusionSettings.h"
#import "IotSensorsDevice.h"

@implementation SensorFusionSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 8;
    return self;
}

- (void) process:(NSData*)data offset:(int)offset {
    self.raw = [data subdataWithRange:NSMakeRange(offset, self.length)];
    const uint16_t* raw = self.raw.bytes;

    self.sflBetaA = CFSwapInt16LittleToHost(raw[0]);
    self.sflBetaM = CFSwapInt16LittleToHost(raw[1]);
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    uint16_t raw[] = {
        CFSwapInt16HostToLittle(self.sflBetaA),
        CFSwapInt16HostToLittle(self.sflBetaM),
        0, 0 // reserved
    };

    self.modified = memcmp(self.raw.bytes, raw, self.length) != 0;
    return [NSData dataWithBytes:raw length:self.length];
}

- (void) save:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"BetaA"];
    i.value = @(self.sflBetaA);
    i = spec[@"BetaM"];
    i.value = @(self.sflBetaM);
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"BetaA"];
    self.sflBetaA = i.value.unsignedShortValue;
    i = spec[@"BetaM"];
    self.sflBetaM = i.value.unsignedShortValue;
}

@end
