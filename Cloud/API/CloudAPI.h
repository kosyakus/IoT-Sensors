/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#ifndef CloudAPI_h
#define CloudAPI_h

#import "JSONModel.h"

typedef NS_ENUM(NSInteger, eMgmtEdgeOperations)
{
    eMgmtEdgeOperations_Custom = 0,
    eMgmtEdgeOperations_ThrottlingSet = 1,
    eMgmtEdgeOperations_AssetTrackingConfigSet = 2
};

typedef NS_ENUM(NSInteger, eMgmtServiceOperations)
{
    eMgmtServiceOperations_Custom = 0,
    eMgmtServiceOperations_AssetTrackingConfigGet = 1
};

typedef NS_ENUM(NSInteger, eMgmtAssetTrackingSetTrackedTagsOperations)
{
    eMgmtAssetTrackingSetTrackedTagsOperations_Add = 0,
    eMgmtAssetTrackingSetTrackedTagsOperations_Remove = 1,
    eMgmtAssetTrackingSetTrackedTagsOperations_Overwrite = 2
};


#pragma mark - Edge <-> Service

@interface CloudDataMsg : JSONModel

@property (nonatomic) NSInteger MsgType; // eEventTypes or eActuationTypes (InternalAPI.h)
@property (strong, nonatomic) NSString *Data;

@end

@protocol CloudDataMsg

@end


//******************************************************************************

@interface CloudMgmtMsg : JSONModel

@property (nonatomic) NSInteger OperationType; // eMgmtEdgeOperations or eMgmtServiceOperations
@property (strong, nonatomic) NSString *Payload;

@end

@protocol CloudMgmtMsg

@end

//******************************************************************************

@interface EdgeServiceApiMsg : JSONModel

@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *APPID;
@property (strong, nonatomic) NSString *EKID;
@property (strong, nonatomic) NSString *Timestamp;
@property (strong, nonatomic) NSMutableArray<CloudMgmtMsg, Optional> *MgmtMsgs;
@property (strong, nonatomic) NSMutableArray<CloudDataMsg, Optional> *Events;

@end

@protocol EdgeServiceApiMsg

@end

//******************************************************************************

//******************************************************************************

@interface ServiceEdgeApiMsg : JSONModel

@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString<Optional> *APPID;
@property (strong, nonatomic) NSString<Optional> *EKID;
@property (strong, nonatomic) NSMutableArray<CloudMgmtMsg, Optional> *MgmtMsgs;
@property (strong, nonatomic) NSMutableArray<CloudDataMsg, Optional> *Actuations;

@end

@protocol ServiceEdgeApiMsg

@end

//******************************************************************************
//******************************************************************************
//******************************************************************************


#pragma mark - IoT Apps

typedef NS_ENUM(NSInteger, eAlertingSensorTypes) {
    eAlertingSensors_Temperature = 0,
    eAlertingSensors_Humidity,
    eAlertingSensors_Pressure,
    eAlertingSensors_AirQuality,
    eAlertingSensors_Brightness,
    eAlertingSensors_Count
};

typedef NS_ENUM(NSInteger, eAlertingSetRuleOperationTypes) {
    eAlertingSetRuleOperationTypes_Insert = 0,
    eAlertingSetRuleOperationTypes_Update,
    eAlertingSetRuleOperationTypes_Delete,
    eAlertingSetRuleOperationTypes_Count
};

typedef NS_ENUM(NSInteger, eControlSetRuleOperationTypes) {
    eControlSetRuleOperationTypes_Insert = 0,
    eControlSetRuleOperationTypes_Update,
    eControlSetRuleOperationTypes_Delete,
    eControlSetRuleOperationTypes_Count
};

typedef NS_ENUM(NSInteger, eControlActuators) {
    eControlActuators_Led = 0,
    eControlActuators_Buzzer,
    eControlActuators_Count
};

typedef NS_ENUM(NSInteger, eControlCloudRuleConditions) {
    eControlCloudRuleConditions_Weather = 0,
    eControlCloudRuleConditions_Forex,
    eControlCloudRuleConditions_Count
};

typedef NS_ENUM(NSInteger, eCommonComparisonOperators) {
    eCommonComparisonOperators_Equal = 0,
    eCommonComparisonOperators_Greater,
    eCommonComparisonOperators_GreaterOrEqual,
    eCommonComparisonOperators_Less,
    eCommonComparisonOperators_LessOrEqual,
    eCommonComparisonOperators_Count
};

typedef NS_ENUM(NSInteger, eCommonOperationTypes) {
    eCommonOperationTypes_Insert = 0,
    eCommonOperationTypes_Update,
    eCommonOperationTypes_Delete,
    eCommonOperationTypes_Count
};

typedef NS_ENUM(NSInteger, eAssetTrackingOperationTypes) {
    eAssetTrackingOperationTypes_Insert = 0,
    eAssetTrackingOperationTypes_Update,
    eAssetTrackingOperationTypes_Delete,
    eAssetTrackingOperationTypes_Count
};


@interface HistoricalGetEnvironmentalReq : JSONModel

@property (strong, nonatomic) NSString *StartDate;
@property (strong, nonatomic) NSString *EndDate;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *EKID;
@property (strong, nonatomic) NSString *APPID;

@end

@protocol HistoricalGetEnvironmentalReq

@end


//******************************************************************************

@interface HistoricalGetEnvironmentalRsp : JSONModel

@property (strong, nonatomic) NSArray *Values;
@property (strong, nonatomic) NSArray *Timestamps;

@end

@protocol HistoricalGetEnvironmentalRsp

@end


//******************************************************************************
//******************************************************************************

@interface AlertingRule : JSONModel

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *EKID;
@property (strong, nonatomic) NSString<Optional> *Name;
@property (strong, nonatomic) NSString<Optional> *FriendlyDescription;
@property (nonatomic) NSInteger SensorType;     // eAlertingSensorTypes
@property (strong, nonatomic) NSString *Email;
@property (nonatomic) NSInteger OperatorType; // eComparisonOperators
@property (strong, nonatomic) NSNumber *Value;
@property (strong, nonatomic) NSString *LastUpdated;
@property (nonatomic) BOOL IsEnabled;

@end

@protocol AlertingRule

@end

//******************************************************************************

@interface AlertingSetRuleReq : JSONModel

@property (strong, nonatomic) NSString *APPID;
@property (nonatomic) NSInteger OperationType; //eAlertingSetRuleOperationTypes
@property (strong, nonatomic) AlertingRule *Rule;

+ (NSString *) constructRoute;

@end

@protocol AlertingSetRuleReq

@end


//******************************************************************************

@interface AlertingGetRulesReq : JSONModel

@property (strong, nonatomic) NSString *UserId;

+ (NSString *) constructRoute;
+ (NSString *) constructUrlParams:(AlertingGetRulesReq *)req;

@end

@protocol AlertingGetRulesReq

@end


//******************************************************************************

@interface AlertingGetRulesRsp : JSONModel

@property (strong, nonatomic) NSArray<AlertingRule, Optional> *Rules;

@end

@protocol AlertingSetRulesRsp

@end

//******************************************************************************
//******************************************************************************

@interface ControlRule : JSONModel

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *EKID;
@property (strong, nonatomic) NSString<Optional> *Name;
@property (strong, nonatomic) NSString<Optional> *FriendlyDescription;
@property (nonatomic) NSInteger OperatorType; // eComparisonOperators
@property (strong, nonatomic) NSNumber *Value;
@property (nonatomic) NSInteger Condition;     // eControlCloudRuleCondition
@property (strong, nonatomic) NSString *SubCondition; // Temperature, FOREX symbol
@property (strong, nonatomic) NSString<Optional> *City;
@property (nonatomic) NSInteger ActuatorType; // eControlActuators
@property (nonatomic) BOOL ActuatorValue;
@property (strong, nonatomic) NSString *LastUpdated;
@property (nonatomic) BOOL IsEnabled;

@end

@protocol ControlRule

@end

//******************************************************************************

@interface ControlSetRuleReq : JSONModel

@property (strong, nonatomic) NSString *APPID;
@property (nonatomic) NSInteger OperationType; //eControlSetRuleOperationTypes
@property (strong, nonatomic) ControlRule *Rule;

+ (NSString *) constructRoute;

@end

@protocol ControlSetRuleReq

@end


//******************************************************************************

@interface ControlGetRulesReq : JSONModel

@property (strong, nonatomic) NSString *UserId;

+ (NSString *) constructRoute;
+ (NSString *) constructUrlParams:(ControlGetRulesReq *)req;

@end

@protocol ControlGetRulesReq

@end


//******************************************************************************

@interface ControlGetRulesRsp : JSONModel

@property (strong, nonatomic) NSArray<ControlRule, Optional> *ControlRules;

@end

@protocol ControlGetRulesRsp

@end

//******************************************************************************
//******************************************************************************

@interface AssetTrackingAdvertiseMsg : JSONModel

@property (strong, nonatomic) NSString *Mac;
@property (strong, nonatomic) NSString *Uuid;
@property (nonatomic) NSInteger Major;
@property (nonatomic) NSInteger Minor;
@property (nonatomic) NSInteger Rssi;

@end

@protocol AssetTrackingAdvertiseMsg

@end

//******************************************************************************

@interface AssetTrackingTag : JSONModel

@property (strong, nonatomic) NSString<Optional> *Id;
@property (strong, nonatomic) NSString *FriendlyName;
@property (strong, nonatomic) NSString<Optional> *Description;
@property (strong, nonatomic) NSString<Optional> *SupervisorId;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *TagId;

@end

@protocol AssetTrackingTag

@end

//******************************************************************************

@interface AssetTrackingSetTagReq : JSONModel

@property (nonatomic) NSInteger OperationType; // eAssetTrackingOperationTypes
@property (strong, nonatomic) AssetTrackingTag *Tag;

+ (NSString *) constructRoute;

@end

@protocol AssetTrackingSetTagReq

@end

//******************************************************************************

@interface IoTAppsApi : NSObject

+(NSString *) constructGetTemperatureReqRoute;
+(NSString *) constructGetHumidityReqRoute;
+(NSString *) constructGetPressureReqRoute;
+(NSString *) constructGetAirQualityReqRoute;
+(NSString *) constructGetBrightnessReqRoute;
+(NSString *) constructGetProximityReqRoute;
+ (NSString *) constructUrlParams:(HistoricalGetEnvironmentalReq *)req;

@end

//******************************************************************************


#pragma mark - Management

@interface EKDevice : JSONModel

@property (strong, nonatomic) NSString<Optional> *Id;
@property (strong, nonatomic) NSString *EKID;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString<Optional> *Description;
@property (strong, nonatomic) NSString<Optional> *FriendlyName;

@end

@protocol EKDevice

@end

//******************************************************************************

@interface MgmtSetDeviceReq : JSONModel

@property (nonatomic) NSInteger OperationType;
@property (strong, nonatomic) EKDevice *DeviceInfo;

+ (NSString *) constructRoute;

@end

@protocol MgmtSetDeviceReq

@end


//******************************************************************************

@interface MgmtGetEKIDRsp : JSONModel

@property (strong, nonatomic) NSMutableArray<EKDevice, Optional> *Devices;

@end

@protocol MgmtGetEKIDRsp

@end


//******************************************************************************

@interface MgmtGetEKIDReq : JSONModel

@property (strong, nonatomic) NSString *UserId;

+(NSString *) constructGetEKIDReqRoute;
+ (NSString *) constructUrlParams:(MgmtGetEKIDReq *)req;

@end

@protocol MgmtGetEKIDReq

@end


//******************************************************************************

@interface MgmtWebAppLinkInfo : JSONModel

@property (strong, nonatomic) NSString *Email;
@property (strong, nonatomic) NSString *Url;

+(NSString *) constructRoute;

@end

@protocol MgmtWebAppLinkInfo

@end

//******************************************************************************

@interface IftttMsg : JSONModel

@property (strong, nonatomic) NSString *value1;

@end

@protocol IftttMsg

@end

//******************************************************************************

@interface MgmtIftttInfo : JSONModel

@property (strong, nonatomic) NSString *IftttApiKey;
@property (strong, nonatomic) NSString *UserId;

@end

@protocol MgmtIftttInfo

@end


//******************************************************************************

@interface MgmtGetIftttInfoReq : JSONModel

@property (strong, nonatomic) NSString *UserId;

+(NSString *) constructRoute;
+ (NSString *) constructUrlParams:(MgmtGetIftttInfoReq *)req;

@end

@protocol MgmtGetIftttInfoReq

@end

//******************************************************************************

@interface MgmtSetIftttInfoReq : JSONModel

@property (strong, nonatomic) MgmtIftttInfo *IftttInfo;

+(NSString *) constructRoute;

@end

@protocol MgmtSetIftttInfoReq

@end

//******************************************************************************

@interface MgmtGetUserIdByTokenReq : JSONModel

@property (strong, nonatomic) NSString *APPID;
@property (strong, nonatomic) NSString *Token;

+ (NSString *) constructRoute;
+ (NSString *) constructUrlParams:(MgmtGetUserIdByTokenReq *)req;

@end

@protocol MgmtGetUserIdByTokenReq

@end


//******************************************************************************

@interface MgmtGetUserIdByTokenRsp : JSONModel

@property (strong, nonatomic) NSString *UserId;

@end

@protocol MgmtGetUserIdByTokenRsp

@end


//******************************************************************************

@interface MgmtAmazonAccountInfoReq : JSONModel

@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString *AmazonUserId;
@property (strong, nonatomic) NSString *AmazonAccessToken;
@property (strong, nonatomic) NSString *AmazonEmail;

+ (NSString *) constructRoute;

@end

@protocol MgmtAmazonAccountInfoReq

@end

//******************************************************************************

@interface MgmtThrottlingSet : JSONModel

@property (strong, nonatomic) NSArray *EventTypes;
@property (strong, nonatomic) NSArray *SubsamplingFactors;

@end

@protocol MgmtThrottlingSet

@end

//******************************************************************************

@interface MgmtAssetTrackingConfigMsg : JSONModel

@property (strong, nonatomic) NSArray *TrackedTags; // of NSString
@property (nonatomic) NSInteger RssiDelta;
@property (nonatomic) NSInteger ForceSendAfterSecs;
@property (nonatomic) NSInteger TrackedTagsUpdatePeriod;
@property (nonatomic) NSInteger Operation; // eMgmtAssetTrackingSetTrackedTagsOperations

@end

@protocol MgmtAssetTrackingConfigMsg

@end

//******************************************************************************

#endif /* CloudAPI_h */
