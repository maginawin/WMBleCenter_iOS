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

extern NSString* const kBleSavedPeripheralIdentifier;

#pragma mark - NSString const for post central manager delegate notification

/** (CBCentralManager*)central, 可以取其状态 central.state */
extern NSString* const kBleCentralManagerDidUpdateState;
/** (NSArray*)sendObjectsm, index0 -> (CBPeripheral*)peripheral, index1 -> <NSDictionary*)advertisementData, index2 -> (NSNumber*)RSSI */
extern NSString* const kBleCentralManagerDidDiscoverPeripheral;
/** (CBPeripheral*)peripheral */
extern NSString* const kBleCentralManagerDidConnectPeripheral;
/** (CBPeripheral*)peripheral */
extern NSString* const kBleCentralManagerDidDisconnectPeripheral;
/** (CBPeripheral*)peripheral */
extern NSString* const kBleCentralManagerDidFailToConnectPeripheral;

#pragma mark - NSString const for post peripheral delegate notificaiton

/** (CBPeripheral*)peripheral */
extern NSString* const kBlePeripheralDidDiscoverServices;
/** (NSArray*)sendObjects, index0 -> (CBPeripheral*)peripheral, index1 -> (CBService*)service */
extern NSString* const kBlePeripheralDidDiscoverCharacteristicsForService;
/** (NSArray*)sendObjects, index0 -> (CBPeripheral*)peripheral, index1 -> (CBCharacteristic*)characteristic */
extern NSString* const kBlePeripheralDidUpdateValueForCharacteristic;
/** (NSArray*)sendObjects, index0 -> (CBPeripheral*)peripheral, index1 -> (CBCharacteristic*)characteristic */
extern NSString* const kBlePeripheralDidWriteValueForCharacteristic;
/** (NSArray*)sendObjects, index0 -> (CBPeripheral*)peripheral, index1 -> (NSNumber*)RSSI */
extern NSString* const kBlePeripheralDidUpdateOrReadRSSI;

@interface WMBleTemplate : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

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
