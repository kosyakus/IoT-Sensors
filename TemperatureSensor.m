/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "TemperatureSensor.h"

static NSString* const LOG_TAG = @"TMP";
static NSString* const LOG_UNIT_CELSIUS = @" C";
static NSString* const LOG_UNIT_FAHRENHEIT = @" F";

@implementation TemperatureSensor

+ (float) celsiusToFahrenheit:(float)celsius {
    return celsius * 1.8f + 32;
}

+ (float) fahrenheitToCelsius:(float)fahrenheit {
    return (fahrenheit - 32) / 1.8f;
}

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.logUnit = TEMPERATURE_UNIT_CELSIUS;
    self.displayUnit = TEMPERATURE_UNIT_CELSIUS;
    self.graphUnit = TEMPERATURE_UNIT_CELSIUS;
    return self;
}

- (int) getTemperatureUnit {
    return TEMPERATURE_UNIT_CELSIUS;
}

- (float) getTemperature:(int)unit {
    return unit == [self getTemperatureUnit] ? self.temperature : unit == TEMPERATURE_UNIT_FAHRENHEIT ? [TemperatureSensor celsiusToFahrenheit:self.temperature] : [TemperatureSensor fahrenheitToCelsius:self.temperature];
}

- (IotSensorValue*) getValue:(int)unit {
    return unit == [self getTemperatureUnit] ? self.value : [[IotSensorValue alloc] initWithValue:unit == TEMPERATURE_UNIT_FAHRENHEIT ? [TemperatureSensor celsiusToFahrenheit:self.temperature] : [TemperatureSensor fahrenheitToCelsius:self.temperature]];
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT_CELSIUS {
    return LOG_UNIT_CELSIUS;
}

+ (NSString*) LOG_UNIT_FAHRENHEIT {
    return LOG_UNIT_FAHRENHEIT;
}

- (IotSensorValue*) logValue {
    return [self getValue: self.logUnit];
}

- (NSString*) logTag {
    return TemperatureSensor.LOG_TAG;
}

- (NSString*) logValueUnit {
    return self.logUnit == TEMPERATURE_UNIT_CELSIUS ? TemperatureSensor.LOG_UNIT_CELSIUS : TemperatureSensor.LOG_UNIT_FAHRENHEIT;
}

- (float) displayValue {
    return [self getTemperature:self.displayUnit];
}

- (IotSensorValue*) graphValue {
    IotSensorValue* graphValue = super.graphValue; // for GraphValueProcessor
    return self.graphUnit == [self getTemperatureUnit] ? graphValue : [[IotSensorValue alloc] initWithValue:self.graphUnit == TEMPERATURE_UNIT_FAHRENHEIT ? [TemperatureSensor celsiusToFahrenheit:graphValue.get] : [TemperatureSensor fahrenheitToCelsius:graphValue.get]];
}

- (IotSensorValue*) cloudValue {
    return [self getValue:TEMPERATURE_UNIT_CELSIUS];
}

@end
