/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>
@class IotSensorsDevice;

@interface IotDeviceFeatures : NSObject

@property (weak) IotSensorsDevice* device;
@property NSData* rawFeatures;
@property NSSet* features;
@property BOOL hasTemperature;
@property BOOL hasHumidity;
@property BOOL hasPressure;
@property BOOL hasAccelerometer;
@property BOOL hasGyroscope;
@property BOOL hasMagnetometer;
@property BOOL hasAmbientLight;
@property BOOL hasProximity;
@property BOOL hasProximityCalibration;
@property BOOL hasRawGas;
@property BOOL hasAirQuality;
@property BOOL hasGasSensor;
@property BOOL hasButton;
@property BOOL hasSensorFusion;
@property BOOL hasIntegrationEngine;
@property BOOL valid;

- (id) initWithDevice:(IotSensorsDevice*)device;
- (void) processFeaturesReport:(NSData*)data offset:(int)offset;
- (void) processFeaturesCharacteristic:(NSData*)data;
- (BOOL) hasFeature:(int)feature;

@end
