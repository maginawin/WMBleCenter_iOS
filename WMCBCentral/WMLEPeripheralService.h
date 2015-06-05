//
//  WMLEPeripheralService.h
//  WMCBCentral
//
//  Created by maginawin on 15/6/3.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// 需要在 implement 中改变这些值
extern NSString* kMymcuServiceUUIDString;
extern NSString* kMymcuWriteUUIDString;
extern NSString* kMymcuNotifyUUIDString;

@interface WMLEPeripheralService : NSObject <CBPeripheralDelegate>

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral;

- (void)reset;

- (void)start;

@property (strong, nonatomic) CBPeripheral* servicePeripheral;

@end
