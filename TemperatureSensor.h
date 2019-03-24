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
    TEMPERATURE_UNIT_CELSIUS    = 0,
    TEMPERATURE_UNIT_FAHRENHEIT = 1
};

@interface TemperatureSensor : IotSensor

+ (float) celsiusToFahrenheit:(float) celsius;
+ (float) fahrenheitToCelsius:(float) fahrenheit;

@property float temperature;
@property int logUnit;
@property int displayUnit;
@property int graphUnit;

- (int) getTemperatureUnit;
- (float) getTemperature:(int)unit;
- (IotSensorValue*) getValue:(int)unit;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT_CELSIUS;
+ (NSString*) LOG_UNIT_FAHRENHEIT;

@end
