//
//  WMBleTemplate.h
//  WMCBCentral
//
//  Created by maginawin on 15/6/5.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString* kBleSavedPeripheralIdentifier;

@interface WMBleTemplate : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (void)startScanningForUUIDString:(NSString*)uuidString;

- (void)stopScanning;

- (void)connectPeripheral:(CBPeripheral*)peripheral;

- (void)disconnectPeripheral:(CBPeripheral*)peripheral;

#pragma mark - Data handler

/** 将十六进制 NSData 转换成十六进制 NSString */
+ (NSString*)hexStringFromHexData:(NSData*)aData;

/** 将十六进制 NSString 转成十六进制 NSData */
+ (NSData*)hexDataFromHexString:(NSString*)hexString;

/** 将十六进制 NSString 转为 NSInteger */
+ (NSInteger)integerFromHexString:(NSString*)hexString;

/** 将十六进制 NSString 转为 NSString */
+ (NSString*)stringFromHexString:(NSString*)hexString;

/** 将十进制 NSString 转为十六进制 NSData */
+ (NSData*)hexDataFromString:(NSString*)aString;

/** 将十进制 NSString 转为十六进制 NSString */
+ (NSString*)hexStringFromString:(NSString*)aString;

/** 将 NSInteger 转为十六进制的 NSString */
+ (NSString*)hexStringFromInteger:(NSInteger)aInteger;

@end
