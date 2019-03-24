/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSensorViewController.h"

@interface BasicImageSensorViewController : BasicSensorViewController

@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@property IBOutlet UIImage *fullLevelImage;

- (UIImage*) drawRectOnImage:(UIImage*)image withRect:(CGRect)rect;
- (void) setImageLevel:(int)percentage;

@end
