/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "DeviceRangeView.h"

static const int RSSI_RANGE[] = {
        -105,
        -95,
        -85,
        -70,
        -60,
};

@implementation DeviceRangeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.range = 3;
        [self setNeedsDisplay];
    }
    return self;
}

- (void) setRange:(int)range {
    _range = range;
    
    [self setNeedsDisplay];
}

- (void) setRssi:(int)rssi {
    int range = 0;
    while (range < 5) {
        if (rssi >= RSSI_RANGE[range])
            ++range;
        else
            break;
    }
    self.range = range;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = rect.size.width/10;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

    CGContextSetLineWidth(context, lineWidth* 1.5);
   
    CGFloat components[] = {0.22, 0.44, 0.69, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);

    for (int n=0; n < MIN(5, self.range); n++) {
        CGContextMoveToPoint(context, n * 2 * lineWidth + (lineWidth/2), (4-n)/5.0f * self.frame.size.height);
        CGContextAddLineToPoint(context, n * 2 * lineWidth + (lineWidth/2), self.frame.size.height);
        CGContextStrokePath(context);
    }
    
    CGFloat components_gray[] = {0.0, 0.0, 0.0, 0.15};
    CGColorRef color_gray = CGColorCreate(colorspace, components_gray);
    CGContextSetStrokeColorWithColor(context, color_gray);
    
    for (int n=MIN(5, self.range); n < 5; n++) {
        CGContextMoveToPoint(context, n * 2 * lineWidth + (lineWidth/2), (4-n)/5.0f * self.frame.size.height);
        CGContextAddLineToPoint(context, n * 2 * lineWidth + (lineWidth/2), self.frame.size.height);
        CGContextStrokePath(context);
    }
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    CGColorRelease(color_gray);
}

@end
