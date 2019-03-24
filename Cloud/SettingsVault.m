/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SettingsVault.h"

@interface SettingsVault ()

@property (strong, nonatomic) NSUserDefaults *settings;

@end


@implementation SettingsVault

+(id)sharedSettingsVault {
    static SettingsVault *internalSharedSettingsVault = nil;
    static dispatch_once_t once_token;

    dispatch_once(&once_token, ^{
        internalSharedSettingsVault =[[self alloc] init];
    });

    return internalSharedSettingsVault;
}

-(instancetype)init {
    if (self = [super init]) {
        _settings = [NSUserDefaults standardUserDefaults];
    }

    return self;
}


///*****************************************************************************
///*****************************************************************************


#pragma mark - Public methods

-(NSString *)getAPPID {
    if ([self.settings stringForKey:@"APPID"] == nil) {
        [self setAPPID:[[NSUUID UUID] UUIDString]];
    }
    return [self.settings stringForKey:@"APPID"];
}

-(void)setUSERID:(NSString *)userId {
    [self.settings setObject:userId forKey:@"USERID"];
}

-(NSString *)getUSERID {
    return [self.settings stringForKey:@"USERID"];
}

-(void)setConfigCloudEnable:(BOOL)status {
    [self.settings setBool:status forKey:@"CLOUDENABLE"];
}

-(BOOL)getConfigCloudEnable {
    return [self.settings boolForKey:@"CLOUDENABLE"];
}

-(void)setConfigCloudLink:(NSString *)userId {
    NSString *url = [[@"https://app.dialog-cloud.com?UserId="
                      stringByAppendingString:userId]
                     stringByAppendingString:@"#/"];
    [self.settings setObject:url forKey:@"CLOUDLINK"];
}

-(NSString *)getConfigCloudLink {
    return [self.settings stringForKey:@"CLOUDLINK"];
}

-(BOOL)getConfigIsCloudLinkGenerated {
    return [self getConfigCloudLink] != nil;
}

-(void)setConfigHistoricalEnable:(BOOL)status {

}

-(BOOL)getConfigHistoricalEnable {
    return NO;
}

-(void)setConfigAlertingEnable:(BOOL)status {

}

-(BOOL)getConfigAlertingEnable {
    return NO;
}

-(void)setConfigControlEnable:(BOOL)status {

}

-(BOOL)getConfigControlEnable {
    return NO;
}

-(void)setConfig3DGameEnable:(BOOL)status {
    [self.settings setBool:status forKey:@"3DGAMEENABLE"];
}

-(BOOL)getConfig3DGameEnable {
    return [self.settings boolForKey:@"3DGAMEENABLE"];
}

-(void)setConfigAssetTrackingEnable:(BOOL)status {
    [self.settings setBool:status forKey:@"ASSETTRACKINGENABLE"];
}

-(BOOL)getConfigAssetTrackingEnable {
    return [self.settings boolForKey:@"ASSETTRACKINGENABLE"];
}

-(void)setConfigCloudLinkTargetEmail:(NSString *)email {
    [self.settings setObject:email forKey:@"TARGETEMAIL"];
}

-(NSString *)getConfigCloudLinkTargetEmail {
    NSString *email = [self.settings stringForKey:@"TARGETEMAIL"];

    if(email != nil) {
        return email;
    }
    else {
        return @"";
    }
}

-(void)setConfigHasEnabledCloudAtLeastOnce:(BOOL)status {
    [self.settings setBool:status forKey:@"HASENABLEDCLOUDATLEASTONCE"];
}

-(BOOL)getConfigHasEnabledCloudAtLeastOnce {
    return [self.settings boolForKey:@"HASENABLEDCLOUDATLEASTONCE"];
}

-(void)setConfigIftttEnable:(BOOL)status {
    [self.settings setBool:status forKey:@"IFTTTENABLE"];
}

-(BOOL)getConfigIftttEnable {
    return [self.settings boolForKey:@"IFTTTENABLE"];
}

-(void)setConfigIftttApiKey:(NSString *)key {
    [self.settings setObject:key forKey:@"IFTTTAPIKEY"];
}

-(NSString *)getConfigIftttApiKey {
    return [self.settings stringForKey:@"IFTTTAPIKEY"];
}

-(void)setConfigIftttEventPeriod:(NSNumber *)period {
    [self.settings setObject:period forKey:@"IFTTTPERIOD"];
}

-(NSNumber *)getConfigIftttEventPeriod {
    if ((NSNumber *)[self.settings objectForKey:@"IFTTTPERIOD"] == nil) {
        return [NSNumber numberWithInt:60]; // Default
    }
    else {
        return (NSNumber *)[self.settings objectForKey:@"IFTTTPERIOD"];
    }
}

-(NSString *)getAmazonScopes {
    return @"{\"alexa:all\":{\"productID\":\"com_yodiwo_apps_yodifinder\",""\"productInstanceAttributes\":{\"deviceSerialNumber\":\"1000-6666-7777-9999\"}}}";
}

///*****************************************************************************
///*****************************************************************************


#pragma mark - Private methods

-(void)setAPPID:(NSString *)appId {
    [self.settings setObject:appId forKey:@"APPID"];
}

///*****************************************************************************

@end
