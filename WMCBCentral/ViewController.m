//
//  ViewController.m
//  WMCBCentral
//
//  Created by maginawin on 15/6/3.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import "ViewController.h"
#import "WMLEDiscovery.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scanBleDevices:(id)sender {
    [[WMLEDiscovery sharedInstance] startScanningForUUIDString:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
