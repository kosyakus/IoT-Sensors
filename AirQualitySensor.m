/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AirQualitySensor.h"


NSString* const AIR_QUALITY_ACCURACY_TEXT[] = {
    @"Unreliable",
    @"Low Accuracy",
    @"Medium Accuracy",
    @"High Accuracy",
};

NSString* const AIR_QUALITY_TEXT[] = {
    @"Good",
    @"Moderate",
    @"Unhealthy (sensitive)",
    @"Unhealthy",
    @"Highly Unhealthy",
    @"Hazardous",
};

const uint32_t AIR_QUALITY_COLOR[] = {
    0x388E3C, // green
    0xFBC02D, // yellow
    0xF57C00, // orange
    0xD32F2F, // red
    0x7B1FA2, // purple
    0x000000, // black
};

const int AIR_QUALITY_RANGE[] = {
    50,
    100,
    150,
    200,
    300
};


static NSString* const LOG_TAG = @"AQI";


@implementation AirQualitySensor

- (void) calculateAirQualityIndex {
    self.airQualityIndex = AIR_QUALITY_INDEX_GOOD;
    while (self.airQualityIndex < AIR_QUALITY_INDEX_WORST && self.quality > AIR_QUALITY_RANGE[self.airQualityIndex])
        ++self.airQualityIndex;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

- (NSString*) logTag {
    return AirQualitySensor.LOG_TAG;
}

- (NSString*) logEntry {
    return [NSString stringWithFormat:@"%@ (%d)", super.logEntry, self.accuracy];
}

@end
