//
//  WMLEDiscovery.m
//  WMCBCentral
//
//  Created by maginawin on 15/6/3.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import "WMLEDiscovery.h"
#import "AppDelegate.h"
#import "WMLEPeripheralService.h"

NSString* kSavedLEIdentifier = @"kSavedLEIdentifier";

@interface WMLEDiscovery()

@property (strong, nonatomic) CBCentralManager* mCentralManager;

@end

@implementation WMLEDiscovery

+ (instancetype)sharedInstance {
    static WMLEDiscovery* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString* identifier = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedLEIdentifier][0];
        _mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@YES, CBCentralManagerOptionRestoreIdentifierKey:identifier}];
        _foundPeripherals = [NSMutableArray array];
        _connectedServices = [NSMutableArray array];
    }
    return self;
}

+ (void)load {
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//        [WMLEDiscovery sharedInstance];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}

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
}

- (void)stopScanning {
    [_mCentralManager stopScan];
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
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:{
            [self clearDevices];
            break;
        }
        case CBCentralManagerStatePoweredOn: {
            [self loadSavedDevices];
            break;
        }
        case CBCentralManagerStateResetting: {
            [self clearDevices];
            break;
        }
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    WMLog(@"Did discover peripheral : %@", peripheral);
    if (![_foundPeripherals containsObject:peripheral]) {
        [_foundPeripherals addObject:peripheral];
    }
    
#warning test
    if ([peripheral.name isEqualToString:@"JYou-W"]) {
        [self connectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    WMLog(@"Did connect peripheral : %@", peripheral);
//    [self removeAllSavedDevice];
    [self addSavedDevice:peripheral];
    WMLEPeripheralService* peripheralService = nil;
    peripheralService = [[WMLEPeripheralService alloc] initWithPeripheral:peripheral];
    [peripheralService start];
    if (![_connectedServices containsObject:peripheralService]) {
        [_connectedServices addObject:peripheralService];
    }
    if (![_foundPeripherals containsObject:peripheral]) {
        [_foundPeripherals addObject:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    WMLog(@"Did disconnect peripheral %@", peripheral);
    WMLEPeripheralService* peripheralService = nil;
    for (peripheralService in _connectedServices) {
        if (peripheralService.servicePeripheral == peripheral) {
            [_connectedServices removeObject:peripheralService];
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    WMLog(@"Did fail to connect peripheral : %@", peripheral);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    WMLog(@"Did retrieve connected peripherals : %@", peripherals);
    for (CBPeripheral* peripheral in peripherals) {
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    WMLog(@"Did retrieve peripherals : %@", peripherals);
    for (CBPeripheral* peripheral in peripherals) {
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    WMLog(@"Will restore state");
}

#pragma mark - private access

- (void)loadSavedDevices {
    NSArray* storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedLEIdentifier];
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        WMLog(@"No stored array to load. \n");
//        return;
    }
    
    for (id deviceIdentifier in storedDevices) {
        if (![deviceIdentifier isKindOfClass:[NSString class]]) {
//            return;
        }
    }
    
    NSMutableArray* storedIdentifiers = [NSMutableArray array];
    for (NSString* aString in storedDevices) {
        WMLog(@"uuid %@", aString);
        NSUUID* aUUID = [[NSUUID alloc] initWithUUIDString:aString];
        [storedIdentifiers addObject:aUUID];
        WMLog(@"uuid2 %@", aUUID);
    }
    WMLog(@"uuid3 %@", storedIdentifiers);
    NSArray* savedPeripherals = [_mCentralManager retrievePeripheralsWithIdentifiers:storedIdentifiers];
}

- (void)addSavedDevice:(CBPeripheral*)peripheral {
    NSArray* storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedLEIdentifier];
    if (![storedDevices isKindOfClass:[NSArray class]]) {
//        return;
    }
    NSMutableArray* newDevices = nil;
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    NSString* identifier = peripheral.identifier.UUIDString;
    if (![newDevices containsObject:identifier]) {
        [newDevices addObject:identifier];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kSavedLEIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeSavedDevice:(CBPeripheral*)peripheral {
    NSArray* storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedLEIdentifier];
    if (![storedDevices isKindOfClass:[NSArray class]]) {
//        return;
    }
    NSMutableArray* newDevices = [NSMutableArray arrayWithArray:storedDevices];
    NSString* identifier = peripheral.identifier.UUIDString;
    if ([newDevices containsObject:identifier]) {
        [newDevices removeObject:identifier];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kSavedLEIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllSavedDevice {
    NSArray* storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedLEIdentifier];
    if (![storedDevices isKindOfClass:[NSArray class]]) {
//        return;
    }
    NSMutableArray* newDevices = [NSMutableArray arrayWithArray:storedDevices];
    [newDevices removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kSavedLEIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearDevices {
    WMLEPeripheralService* service;
    [_foundPeripherals removeAllObjects];
    for (service in _connectedServices) {
        [service reset];
    }
    [_connectedServices removeAllObjects];
}

#pragma mark - Perform data

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
