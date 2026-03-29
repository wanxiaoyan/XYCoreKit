//
//  NOViewController.m
//  XYCoreKit
//
//  Created by wanxiaodi3 on 03/29/2026.
//  Copyright (c) 2026 wanxiaodi3. All rights reserved.
//

#import "NOViewController.h"
#import <XYCoreKit/XYCoreKit.h>

@interface NOViewController ()

@end

@implementation NOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [XYNetWorkConfig shareConfig].env = XYNetworkEnvironmentDev;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
