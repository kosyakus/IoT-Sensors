/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>

@interface DisclaimerViewController : UIViewController

- (IBAction)showMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
