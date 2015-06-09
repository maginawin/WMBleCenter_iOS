//
//  WMBleTemplate.m
//  WMCBCentral
//
//  Created by maginawin on 15/6/5.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import "WMBleTemplate.h"
#import "AppDelegate.h"

// Use for save connected peripheral

NSString* const kBleSavedPeripheralIdentifier = @"kBleSavedPeripheralIdentifier";

// Use for post central manager delegate notification
NSString* const kBleCentralManagerDidUpdateState = @"kBleCentralManagerDidUpdateState";
NSString* const kBleCentralManagerDidDiscoverPeripheral = @"kBleCentralManagerDidDiscoverPeripheral";
NSString* const kBleCentralManagerDidConnectPeripheral = @"kBleCentralManagerDidConnectPeripheral";
NSString* const kBleCentralManagerDidDisconnectPeripheral = @"kBleCentralManagerDidDisconnectPeripheral";
NSString* const kBleCentralManagerDidFailToConnectPeripheral = @"kBleCentralManagerDidFailToConnectPeripheral";

// Use for post peripheral delegate notification
NSString* const kBlePeripheralDidDiscoverServices = @"kBlePeripheralDidDiscoverServices";
NSString* const kBlePeripheralDidDiscoverCharacteristicsForService = @"kBlePeripheralDidDiscoverCharacteristicsForService";
NSString* const kBlePeripheralDidUpdateValueForCharacteristic = @"kBlePeripheralDidUpdateValueForCharacteristic";
NSString* const kBlePeripheralDidWriteValueForCharacteristic = @"kBlePeripheralDidWriteValueForCharacteristic";
NSString* const kBlePeripheralDidUpdateOrReadRSSI = @"kBlePeripheralDidUpdateOrReadRSSI";

// Use for post scanning ble status notification
NSString* const kBleStartScanning = @"kBleStartScanning";
NSString* const kBleStopScanning = @"kBleStopScanning";

@interface WMBleTemplate()

@property (strong, nonatomic) CBCentralManager* mCentralManager;

@end

@implementation WMBleTemplate

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

/**
 *  ============================================================
 *  继承自此类的就请实现这个 load 方法, 用于 App 初始化时初始化 ble 单例
 *  ============================================================
+ (void)load {
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self sharedInstance];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}
 */

#pragma mark - Public Access

- (void)startScanningForUUIDString:(NSString *)uuidString {
    [self stopScanning];
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerOptionRestoreIdentifierKey];
    if (uuidString) {
        NSArray* uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
        
        [_mCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    } else {
        [_mCentralManager scanForPeripheralsWithServices:nil options:options];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleStartScanning object:nil];
}

- (void)stopScanning {
    [_mCentralManager stopScan];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleStopScanning object:nil];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state != CBPeripheralStateConnected) {
        [_mCentralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    [_mCentralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - Central manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleCentralManagerDidUpdateState object:central];
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:{
            WMLog(@"CBCentralManagerStatePoweredOff");
            break;
        }
        case CBCentralManagerStatePoweredOn: {
            WMLog(@"CBCentralManagerStatePoweredOn");
            break;
        }
        case CBCentralManagerStateResetting: {
            WMLog(@"CBCentralManagerStateResetting");
            break;
        }
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSArray* sendObjects = [NSArray arrayWithObjects:peripheral, advertisementData, RSSI, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleCentralManagerDidDiscoverPeripheral object:sendObjects];
    
    WMLog(@"didDiscover \n  Peripheral : %@  RSSI : %d \n", peripheral.name, [RSSI intValue]);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleCentralManagerDidConnectPeripheral object:peripheral];
    
    WMLog(@"didConnectPeripheral : %@", peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleCentralManagerDidDisconnectPeripheral object:peripheral];
    
    WMLog(@"didDisconnectPeripheral : %@", peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBleCentralManagerDidFailToConnectPeripheral object:peripheral];
    
    WMLog(@"didFailToConnectPeripheral : %@", peripheral.name);
}

#pragma mark - Peripheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlePeripheralDidDiscoverServices object:peripheral];
    
    WMLog(@"peripheral : %@  didDiscoverServices : \n", peripheral.name);
    
    for (CBService* service in peripheral.services) {
        WMLog(@"    service : %@ \n", service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSArray* sendObjects = [NSArray arrayWithObjects:peripheral, service, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlePeripheralDidDiscoverCharacteristicsForService object:sendObjects];
    
    WMLog(@"peripheral : %@  didDiscoverCharacteristicsForService : \n", peripheral.name);
    
    for (CBCharacteristic* characteristic in service.characteristics) {
        NSString* characteristicUUIDString = characteristic.UUID.UUIDString;
        WMLog(@"    characteristic : %@ \n", characteristicUUIDString);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSArray* sendObjects = [NSArray arrayWithObjects:peripheral, characteristic, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlePeripheralDidUpdateValueForCharacteristic object:sendObjects];
    
    WMLog(@"peripheral : %@ didUpdateValue : %@", peripheral.name, [WMBleTemplate hexStringFromHexData:characteristic.value]);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSArray* sendObjects = [NSArray arrayWithObjects:peripheral, characteristic, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlePeripheralDidWriteValueForCharacteristic object:sendObjects];
    
    WMLog(@"peripheral : %@ didWriteValue : %@", peripheral.name, [WMBleTemplate hexStringFromHexData:characteristic.value]);
}

- (void)peripheral:(CBPeripheral*)peripheral RSSI:(NSNumber*)RSSI error:(NSError*)error {
    
    NSArray* sendObjects = [NSArray arrayWithObjects:peripheral, RSSI, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlePeripheralDidUpdateOrReadRSSI object:sendObjects];
    
    WMLog(@"peripheral : %@ RSSI : %d", peripheral.name, [RSSI intValue]);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSNumber* rssi = peripheral.RSSI;
    [self peripheral:peripheral RSSI:rssi error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    [self peripheral:peripheral RSSI:RSSI error:error];
}

#pragma mark - Data handler

+ (NSString*)hexStringFromHexData:(NSData *)aData {
    //    NSString* hexString;
    const unsigned char* dataBuffer = (const unsigned char*)[aData bytes];
    if (!dataBuffer) {
        return nil;
    }
    NSUInteger dataLength = [aData length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    return [hexString uppercaseString];
}

+ (NSData*)hexDataFromHexString:(NSString *)hexString {
    NSMutableData* hexData = [NSMutableData data];
    int idx;
    for (idx = 0; (idx + 2) <= hexString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* itemString = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:itemString];
        unsigned int hexInt;
        [scanner scanHexInt:&hexInt];
        [hexData appendBytes:&hexInt length:1];
    }
    return hexData;
}

+ (NSInteger)integerFromHexString:(NSString *)hexString {
    unsigned int hexInt = 0;
    // Create scanner
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

+ (NSString*)stringFromHexString:(NSString *)hexString {
    long int value = [self integerFromHexString:hexString];
    return [NSString stringWithFormat:@"%ld", value];
}

+ (NSData*)hexDataFromString:(NSString *)aString {
    NSMutableData* hexData = [NSMutableData data];
    int idx;
    for (idx = 0; (idx + 2) <= aString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* item = [aString substringWithRange:range];
        NSString* hexItem = [NSString stringWithFormat:@"%02x", [item intValue]];
        NSScanner* scannner = [NSScanner scannerWithString:hexItem];
        unsigned int hexInt;
        [scannner scanHexInt:&hexInt];
        [hexData appendBytes:&hexInt length:1];
    }
    return hexData;
}

+ (NSString*)hexStringFromString:(NSString *)aString {
    NSString* hexString = [NSString stringWithFormat:@"%02lx", (long)[aString integerValue]];
    if (hexString.length % 2 != 0) {
        hexString = [NSString stringWithFormat:@"0%@", hexString];
    }
    return hexString;
}

+ (NSString*)hexStringFromInteger:(NSInteger)aInteger {
    NSString* hexString = [NSString stringWithFormat:@"%lx", (long)aInteger];
    if (hexString.length % 2 != 0) {
        hexString = [NSString stringWithFormat:@"0%@", hexString];
    }
    return hexString;
}

@end
