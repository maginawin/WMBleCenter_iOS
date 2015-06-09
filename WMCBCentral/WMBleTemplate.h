//
//  WMBleTemplate.h
//  WMCBCentral
//
//  Created by maginawin on 15/6/5.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark - NSString const for save connected peripheral

/**
 * @return 用于保存已经连接 peripheral 的 NSString* const, 可扩展存至 UserDefaults
 */
extern NSString* const kBleSavedPeripheralIdentifier;

#pragma mark - NSString const for post central manager delegate notification

/**
 * @return (CBCentralManager*)central : 蓝牙状态改变, 取其状态 central.state
 */
extern NSString* const kBleCentralManagerDidUpdateState;

/**
 * @return (NSArray*)sendObjects : 发现 peripheral
 * @return - index0 : (CBPeripheral*)peripheral
 * @return - index1 : (NSDictionary*)advertisementData
 * @return - index2 : (NSNubmer*)RSSI
 */
extern NSString* const kBleCentralManagerDidDiscoverPeripheral;

/**
 * @return (CBPeripheral*)peripheral : 连接 peripheral
 */
extern NSString* const kBleCentralManagerDidConnectPeripheral;

/**
 * @return (CBPeripheral*)peripheral : 断开 peripheral 的连接
 */
extern NSString* const kBleCentralManagerDidDisconnectPeripheral;

/**
 * @return (CBPeripheral*)peripheral : 连接 peripheral 失败
 */
extern NSString* const kBleCentralManagerDidFailToConnectPeripheral;

#pragma mark - NSString const for post peripheral delegate notificaiton

/** 
 *  @return (CBPeripheral*)peripheral : 发现 peripheral.services
 */
extern NSString* const kBlePeripheralDidDiscoverServices;

/**
 * @return (NSArray*)sendObjects : 发现 service.characteristics
 * @return - index0 : (CBPeripheral*)peripheral
 * @return - index1 : (CBService*)service
 */
extern NSString* const kBlePeripheralDidDiscoverCharacteristicsForService;

/**
 * @return (NSArray*)sendObjects : 读或接收到 characteristic.value
 * @return - index0 : (CBperipheral*)peripheral
 * @return - index1 : (CBCharacteristic*)characteristic
 */
extern NSString* const kBlePeripheralDidUpdateValueForCharacteristic;

/** 
 * @return (NSArray*)sendObjects : 向 characteristic 中写入数据时调用
 * @return - index0 : (CBPeripheral*)peripheral
 * @return - index1 : (CBCharacteristic*)characteritsic
 */
extern NSString* const kBlePeripheralDidWriteValueForCharacteristic;

/**
 * @return (NSArray*)sendObjects : 更新或者读取 peripheral.RSSI
 * @return - index0 : (CBPeripheral*)peripheral
 * @return - index1 : (NSNumber*)RSSI
 */
extern NSString* const kBlePeripheralDidUpdateOrReadRSSI;

@interface WMBleTemplate : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 * @return static instancetype about self
 */
+ (instancetype)sharedInstance;

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
