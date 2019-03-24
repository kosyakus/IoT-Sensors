/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#include <math.h>
#import "Magnetometer.h"

static NSString* const LOG_TAG = @"MAG";
static NSString* const LOG_UNIT = @"uT";

static NSString* const COMPASS_HEADING[] = {
        @"N",
        @"NE",
        @"E",
        @"SE",
        @"S",
        @"SW",
        @"W",
        @"NW",
        @"N",
};

@implementation Magnetometer

- (void) calculateHeading {
    self.rad = atan2(y, x);
    self.degrees = self.rad * 180 / M_PI;
    self.heading = self.degrees >= 0 ? self.degrees : 360.f + self.degrees;
}

+ (NSString*) getCompassHeading:(float)degrees {
    while (degrees < 0)
        degrees += 360;
    while (degrees > 360)
        degrees -= 360;
    return COMPASS_HEADING[lround(degrees / 45)];
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return Magnetometer.LOG_TAG;
}

- (NSString*) logValueUnit {
    return Magnetometer.LOG_UNIT;
}

- (NSString*) logEntry {
    return [NSString stringWithFormat:@"%@\t%.0fdeg", super.logEntry, self.heading];
}

- (float) displayValue {
    return self.heading;
}

@end
