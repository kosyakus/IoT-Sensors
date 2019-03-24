/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "FileLogger.h"

@implementation FileLogger

- (id) init {
    if (self == [super init]) {
        logFile = nil;
    }
    return self;
}

- (void) openLogFile {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sensor_data_%@.log", iso8601String]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
        [fileManager createFileAtPath:filePath
                             contents:nil
                           attributes:nil];
    logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [logFile seekToEndOfFile];
}

- (void) log:(NSString*)format, ... {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LoggingEnabled"])
        return;

    if (!logFile)
        [self openLogFile];

    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];

    NSString *entry = [NSString stringWithFormat:@"%@\t%@\n", iso8601String, message];
    NSLog(@"%@", entry);
    [logFile writeData:[entry dataUsingEncoding:NSUTF8StringEncoding]];
    //[logFile synchronizeFile];
}

+ (FileLogger*) instance {
    static FileLogger *instance = nil;
    if (!instance)
        instance = [[FileLogger alloc] init];
    return instance;
}

@end
