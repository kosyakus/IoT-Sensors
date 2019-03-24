/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CloudAPI.h"


NSString *const BASEURL = @"https://service.dialog-cloud.com/dialog/";

NSString *const MGMT = @"mgmt/";
NSString *const IOTAPPS = @"iotapps/";

NSString *const EDGE = @"edge/";
NSString *const CLOUD = @"cloud/";

NSString *const GetUserIdByTokenReq = @"g_useridbytoken";
NSString *const GetEKIDReq = @"g_ekid";
NSString *const GetIftttApiKey = @"g_iftttapikey";
NSString *const SetIftttApiKey = @"p_iftttapikey";
NSString *const SetDevice = @"p_setdevice";
NSString *const SetWebAppLinkReq = @"p_webapplink";
NSString *const SetAmazonAccountInfo = @"p_amazoninfo";
NSString *const SetEndpoint = @"p_setendpoint";


NSString *const IOTAPPHISTORICAL = @"historical/";
NSString *const GetTemperatureReq = @"g_temperature";
NSString *const GetHumidityReq = @"g_humidity";
NSString *const GetPressureReq = @"g_pressure";
NSString *const GetAirQualityReq = @"g_airquality";
NSString *const GetProximityReq = @"g_proximity";
NSString *const GetBrightnessReq = @"g_brightness";

NSString *const IOTAPPALERTING = @"alerting/";
NSString *const SetAlertingRule = @"p_setrule";
NSString *const GetAlertingRules = @"g_getrules";

NSString *const IOTAPPCONTROL = @"control/";
NSString *const SetControlRule = @"p_setrule";
NSString *const GetControlRules = @"g_getrules";

NSString *const IOTAPPASSETTRACKING = @"tracking/";
NSString *const SetAssetTrackingTag = @"p_setassettag";
NSString *const SetAssetTrackingGateway = @"p_setgateway";
NSString *const SetAssetTrackingLocation = @"p_setlocation";
NSString *const SetAssetTrackingSupervisor = @"p_setsupervisor";

NSString *const IOTAPPFUSIONGAME = @"fusiongame/";


#pragma mark - IoT Apps
@implementation IoTAppsApi

+ (NSString *) constructGetTemperatureReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetTemperatureReq];

    return route;
}

+ (NSString *) constructGetHumidityReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetHumidityReq];

    return route;
}

+ (NSString *) constructGetPressureReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetPressureReq];

    return route;
}

+ (NSString *) constructGetAirQualityReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetAirQualityReq];

    return route;
}

+ (NSString *) constructGetProximityReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetProximityReq];

    return route;
}

+ (NSString *) constructGetBrightnessReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPHISTORICAL];
    [route appendString:GetBrightnessReq];

    return route;
}

+ (NSString *) constructUrlParams:(HistoricalGetEnvironmentalReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"UserId="]; [params appendString:req.UserId]; [params appendString:@"&"];
    [params appendString:@"EKID="]; [params appendString:req.EKID]; [params appendString:@"&"];
    [params appendString:@"APPID="]; [params appendString:req.APPID]; [params appendString:@"&"];
    [params appendString:@"StartDate="]; [params appendString:req.StartDate]; [params appendString:@"&"];
    [params appendString:@"EndDate="]; [params appendString:req.EndDate];

    return params;
}

@end

//******************************************************************************
//******************************************************************************

@implementation HistoricalGetEnvironmentalReq

@end

@implementation HistoricalGetEnvironmentalRsp

@end

//******************************************************************************
//******************************************************************************

@implementation AlertingRule

@end

//******************************************************************************

@implementation AlertingSetRuleReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPALERTING];
    [route appendString:SetAlertingRule];

    return route;
}

@end

//******************************************************************************

@implementation AlertingGetRulesReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPALERTING];
    [route appendString:GetAlertingRules];

    return route;
}

+ (NSString *) constructUrlParams:(AlertingGetRulesReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"UserId="]; [params appendString:req.UserId];

    return params;
}

@end

//******************************************************************************

@implementation AlertingGetRulesRsp

@end

//******************************************************************************
//******************************************************************************

@implementation ControlRule

@end

//******************************************************************************

@implementation ControlSetRuleReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPCONTROL];
    [route appendString:SetControlRule];

    return route;
}

@end

//******************************************************************************

@implementation ControlGetRulesReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPCONTROL];
    [route appendString:GetControlRules];

    return route;
}

+ (NSString *) constructUrlParams:(ControlGetRulesReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"UserId="]; [params appendString:req.UserId];

    return params;
}

@end

//******************************************************************************

@implementation ControlGetRulesRsp

@end

//******************************************************************************
//******************************************************************************

@implementation AssetTrackingAdvertiseMsg

@end

//******************************************************************************

@implementation AssetTrackingTag

@end

//******************************************************************************

@implementation AssetTrackingSetTagReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:IOTAPPS];
    [route appendString:IOTAPPASSETTRACKING];
    [route appendString:SetAssetTrackingTag];

    return route;
}

@end

//******************************************************************************
//******************************************************************************
//******************************************************************************


#pragma mark - Edge <-> Service

@implementation EdgeServiceApiMsg

@end

//******************************************************************************

@implementation ServiceEdgeApiMsg

@end

//******************************************************************************

@implementation CloudDataMsg

@end

//******************************************************************************

@implementation CloudMgmtMsg

@end


//******************************************************************************
//******************************************************************************
//******************************************************************************


#pragma mark - Management

@implementation EKDevice

@end

@implementation MgmtSetDeviceReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:SetDevice];

    return route;
}

@end

//******************************************************************************

@implementation MgmtGetEKIDRsp

@end

//******************************************************************************

@implementation MgmtGetEKIDReq

+ (NSString *) constructGetEKIDReqRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:GetEKIDReq];

    return route;
}

+ (NSString *) constructUrlParams:(MgmtGetEKIDReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"UserId="]; [params appendString:req.UserId];

    return params;
}

@end

//******************************************************************************

@implementation MgmtWebAppLinkInfo

+(NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:SetWebAppLinkReq];

    return route;
}

@end

//******************************************************************************

@implementation IftttMsg

@end

//******************************************************************************

@implementation MgmtIftttInfo

@end

//******************************************************************************

@implementation MgmtGetIftttInfoReq

+(NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:GetIftttApiKey];

    return route;
}

+ (NSString *) constructUrlParams:(MgmtGetIftttInfoReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"UserId="]; [params appendString:req.UserId];
    return params;
}

@end

//******************************************************************************

@implementation MgmtSetIftttInfoReq

+(NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:SetIftttApiKey];

    return route;
}

@end

//******************************************************************************

@implementation MgmtGetUserIdByTokenReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:GetUserIdByTokenReq];

    return route;
}

+ (NSString *) constructUrlParams:(MgmtGetUserIdByTokenReq *)req {
    NSMutableString *params = [NSMutableString stringWithString:@"/?"];
    [params appendString:@"APPID="]; [params appendString:req.APPID];
    if (req.Token != nil) {
        [params appendString:@"&"];
        [params appendString:@"Token="]; [params appendString:req.Token];
    }
    return params;
}

@end

//******************************************************************************

@implementation MgmtGetUserIdByTokenRsp

@end

//******************************************************************************

@implementation MgmtAmazonAccountInfoReq

+ (NSString *) constructRoute {
    NSMutableString *route = [NSMutableString stringWithString:BASEURL];
    [route appendString:EDGE];
    [route appendString:MGMT];
    [route appendString:SetAmazonAccountInfo];

    return route;
}

@end

//******************************************************************************

@implementation MgmtThrottlingSet

@end

//******************************************************************************

@implementation MgmtAssetTrackingConfigMsg

@end

//******************************************************************************
