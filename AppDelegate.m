/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AppDelegate.h"
#import "TemperatureSensor.h"
#import <LoginWithAmazon/LoginWithAmazon.h>
#import <YandexMapKit/YMKMapKitFactory.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIButton appearance] setBackgroundImage:[self imageFromColor:[UIColor grayColor]] forState:UIControlStateHighlighted];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"ShowCalibrationOverlay"])
        [defaults setBool:YES forKey:@"ShowCalibrationOverlay"];
    if (![defaults objectForKey:@"TemperatureUnit"])
        [defaults setInteger:TEMPERATURE_UNIT_CELSIUS forKey:@"TemperatureUnit"];
    if (![defaults objectForKey:@"ShowCloudMenuOnScanScreen"])
        [defaults setBool:NO forKey:@"ShowCloudMenuOnScanScreen"];
    
    //Natali added for Yandex map
    [YMKMapKit setApiKey: @"4ea80c68-a61a-4c33-a1b1-d8e4581725cf"];

    return YES;
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [AMZNAuthorizationManager handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsAnnotationKey]];
}
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [AIMobileLib handleOpenURL:url sourceApplication:sourceApplication];
}*/

@end
