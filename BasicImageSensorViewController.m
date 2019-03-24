/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicImageSensorViewController.h"

@implementation BasicImageSensorViewController

- (UIImage*) drawRectOnImage:(UIImage*)image withRect:(CGRect)rect {
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointZero]; // draw original image into the context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect); // crop the image
    UIImage* retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

- (void) setImageLevel:(int)percentage {
    percentage = MAX(0, MIN(100, percentage));
    // Crop top of image to represent percentage.
    UIImage* image = self.fullLevelImage;
    self.imageView.image = [self drawRectOnImage:image withRect:CGRectMake(0, 0, image.size.width, image.size.height * (100 - percentage) / 100.f)];
}

@end
