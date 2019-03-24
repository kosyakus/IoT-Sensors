/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#ifndef InternalAPI_h
#define InternalAPI_h

#import "JSONModel.h"


extern NSString *const NotificationBLELayerEvent;
extern NSString *const NotificationBLELayerActuation;
extern NSString *const NotificationCloudCapableEKWillConnect;
extern NSString *const NotificationBLELayerConfiguration;

//******************************************************************************


typedef NS_ENUM(NSInteger, eEventTypes)
{
    eEventTypes_Custom = 0,
    eEventTypes_Temperature = 1,
    eEventTypes_Humidity = 2,
    eEventTypes_Pressure = 3,
    eEventTypes_Gas = 4,
    eEventTypes_Brightness = 5,
    eEventTypes_Proximity = 6,
    eEventTypes_Accelerometer = 7,
    eEventTypes_Fusion = 8,
    eEventTypes_Button = 9,
    eEventTypes_Advertise = 10,
    eEventTypes_Gyroscope = 11,
    eEventTypes_Magnetometer = 12,
    eEventTypes_AirQuality = 13
};

typedef NS_ENUM(NSInteger, eActuationTypes)
{
    eActuationTypes_Custom = 0,
    eActuationTypes_Leds = 1,
    eActuationTypes_Buzzer = 2
};



@interface DataEvent : JSONModel

@property (strong, nonatomic) NSString<Optional> *Data;

@property (nonatomic) NSInteger EventType; // eEventTypes

- (id) initWithType:(NSInteger)type data:(NSString*)data;

@end

@protocol DataEvent

@end

//******************************************************************************


@interface DataMsg : JSONModel

@property (strong, nonatomic) NSString *EKID;

@property (strong, nonatomic) NSMutableArray<DataEvent,Optional> *Events; // of DataEvent

- (id) initWithEKID:(NSString*)EKID;

@end

@protocol DataMsg

@end


//******************************************************************************

@interface ConfigurationMsg : JSONModel

@property (strong, nonatomic) NSArray *StopFw; // eEventTypes

@end

@protocol ConfigurationMsg

@end


//******************************************************************************


#endif /* InternalAPI_h */
