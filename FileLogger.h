/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>

@interface FileLogger : NSObject {
    NSFileHandle *logFile;
}

+ (FileLogger*) instance;
- (void) log:(NSString*)format, ...;

@end

#define FLog(fmt, ...) [FileLogger.instance log:fmt, ##__VA_ARGS__]
