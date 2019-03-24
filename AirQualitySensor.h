/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensor.h"

enum {
    AIR_QUALITY_INDEX_UNKNOWN = -1,
    AIR_QUALITY_INDEX_GOOD = 0,
    AIR_QUALITY_INDEX_AVERAGE = 1,
    AIR_QUALITY_INDEX_LITTLE_BAD = 2,
    AIR_QUALITY_INDEX_BAD = 3,
    AIR_QUALITY_INDEX_VERY_BAD = 4,
    AIR_QUALITY_INDEX_WORST = 5,
};

extern NSString* const AIR_QUALITY_ACCURACY_TEXT[];
extern NSString* const AIR_QUALITY_TEXT[];
extern const uint32_t AIR_QUALITY_COLOR[];
extern const int AIR_QUALITY_RANGE[];


@interface AirQualitySensor : IotSensor

@property int accuracy;
@property float quality;
@property int airQualityIndex;

- (void) calculateAirQualityIndex;

+ (NSString*) LOG_TAG;

@end
