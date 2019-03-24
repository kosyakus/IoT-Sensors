/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CalibrationSettingsV2.h"
#import "IotSensorsDevice.h"
#import "BluetoothDefines.h"

@implementation CalibrationSettingsV2

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 19;
    return self;
}

- (void) unpackControlFlags {
    self.apply = (self.controlFlags & 0x04) != 0;
    self.matrixApply = (self.controlFlags & 0x08) != 0;
    self.update = (self.controlFlags & 0x10) != 0;
    self.matrixUpdate = (self.controlFlags & 0x20) != 0;
    self.initFromStatic = (self.controlFlags & 0x40) != 0;
}

- (void) packControlFlags {
    uint16_t controlFlags = self.controlFlags & ~0x7C;
    controlFlags |= (self.apply ? 0x04 : 0) |
                    (self.matrixApply ? 0x08 : 0) |
                    (self.update ? 0x10 : 0) |
                    (self.matrixUpdate ? 0x20 : 0) |
                    (self.initFromStatic ? 0x40 : 0);
    self.controlFlags = controlFlags;
}

- (void) process:(NSData*)data offset:(int)offset {
    self.raw = [data subdataWithRange:NSMakeRange(offset, self.length)];
    const uint8_t* raw = self.raw.bytes;

    self.sensor = raw[0];
    uint16_t* raw16 = (uint16_t*) (raw + 1);
    self.controlFlags = CFSwapInt16LittleToHost(raw16[0]);
    self.refMag = CFSwapInt16LittleToHost(raw16[1]);
    self.magRange = CFSwapInt16LittleToHost(raw16[2]);
    self.magAlpha = CFSwapInt16LittleToHost(raw16[3]);
    self.magDeltaThresh = CFSwapInt16LittleToHost(raw16[4]);
    self.muOffset = CFSwapInt16LittleToHost(raw16[5]);
    self.muMatrix = CFSwapInt16LittleToHost(raw16[6]);
    self.errAlpha = CFSwapInt16LittleToHost(raw16[7]);
    self.errThresh = CFSwapInt16LittleToHost(raw16[8]);
    [self unpackControlFlags];
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    [self unpackControlFlags];
    uint8_t raw[self.length];
    raw[0] = self.sensor;
    uint16_t* raw16 = (uint16_t*) (raw + 1);
    raw16[0] = CFSwapInt16HostToLittle(self.controlFlags);
    raw16[1] = CFSwapInt16HostToLittle(self.refMag);
    raw16[2] = CFSwapInt16HostToLittle(self.magRange);
    raw16[3] = CFSwapInt16HostToLittle(self.magAlpha);
    raw16[4] = CFSwapInt16HostToLittle(self.magDeltaThresh);
    raw16[5] = CFSwapInt16HostToLittle(self.muOffset);
    raw16[6] = CFSwapInt16HostToLittle(self.muMatrix);
    raw16[7] = CFSwapInt16HostToLittle(self.errAlpha);
    raw16[8] = CFSwapInt16HostToLittle(self.errThresh);

    self.modified = memcmp(self.raw.bytes, raw, self.length) != 0;
    return [NSData dataWithBytes:raw length:self.length];
}

- (void) save:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"Apply"];
    i.value = @(self.apply);
    i = spec[@"MatrixApply"];
    i.value = @(self.matrixApply);
    i = spec[@"Update"];
    i.value = @(self.update);
    i = spec[@"MatrixUpdate"];
    i.value = @(self.matrixUpdate);
    i = spec[@"InitializeFromStaticCoeffs"];
    i.value = @(self.initFromStatic);
    i = spec[@"ReferenceMagnitude"];
    i.value = @(self.refMag);
    i = spec[@"MagnitudeRange"];
    i.value = @(self.magRange);
    i = spec[@"MagnitudeAlpha"];
    i.value = @(self.magAlpha);
    i = spec[@"MagnitudeGradientThreshold"];
    i.value = @(self.magDeltaThresh);
    i = spec[@"OffsetMu"];
    i.value = @(self.muOffset);
    i = spec[@"MatrixMu"];
    i.value = @(self.muMatrix);
    i = spec[@"ErrorAlpha"];
    i.value = @(self.errAlpha);
    i = spec[@"ErrorThreshold"];
    i.value = @(self.errThresh);
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"Apply"];
    self.apply = i.value.boolValue;
    i = spec[@"MatrixApply"];
    self.matrixApply = i.value.boolValue;
    i = spec[@"Update"];
    self.update = i.value.boolValue;
    i = spec[@"MatrixUpdate"];
    self.matrixUpdate = i.value.boolValue;
    i = spec[@"InitializeFromStaticCoeffs"];
    self.initFromStatic = i.value.boolValue;
    i = spec[@"ReferenceMagnitude"];
    self.refMag = i.value.unsignedShortValue;
    i = spec[@"MagnitudeRange"];
    self.magRange = i.value.unsignedShortValue;
    i = spec[@"MagnitudeAlpha"];
    self.magAlpha = i.value.unsignedShortValue;
    i = spec[@"MagnitudeGradientThreshold"];
    self.magDeltaThresh = i.value.unsignedShortValue;
    i = spec[@"OffsetMu"];
    self.muOffset = i.value.unsignedShortValue;
    i = spec[@"MatrixMu"];
    self.muMatrix = i.value.unsignedShortValue;
    i = spec[@"ErrorAlpha"];
    self.errAlpha = i.value.unsignedShortValue;
    i = spec[@"ErrorThreshold"];
    self.errThresh = i.value.unsignedShortValue;
    [self packControlFlags];
}

- (void) enableSettingsForCalibrationMode:(NSDictionary*)spec {
    IotSettingsItem* i;
    for (i in spec.allValues) {
        i.enabled = false;
    }

    if (self.calMode == CALIBRATION_MODE_NONE)
        return;
    if (self.calMode >= CALIBRATION_MODE_STATIC) {
        i = spec[@"Apply"]; i.enabled = true;
        i = spec[@"MatrixApply"]; i.enabled = true;
    }
    if (self.calMode >= CALIBRATION_MODE_CONTINUOUS_AUTO) {
        i = spec[@"Update"]; i.enabled = true;
        i = spec[@"MatrixUpdate"]; i.enabled = true;
        i = spec[@"InitializeFromStaticCoeffs"]; i.enabled = true;
        i = spec[@"ReferenceMagnitude"]; i.enabled = true;
        i = spec[@"MagnitudeRange"]; i.enabled = true;
        i = spec[@"MagnitudeAlpha"]; i.enabled = true;
        i = spec[@"MagnitudeGradientThreshold"]; i.enabled = true;
        if (self.calAutoMode == CALIBRATION_AUTO_MODE_SMART) {
            i = spec[@"OffsetMu"]; i.enabled = true;
            i = spec[@"MatrixMu"]; i.enabled = true;
            i = spec[@"ErrorAlpha"]; i.enabled = true;
            i = spec[@"ErrorThreshold"]; i.enabled = true;
        }
    }
}

@end
