//
//  WMLEPeripheralService.m
//  WMCBCentral
//
//  Created by maginawin on 15/6/3.
//  Copyright (c) 2015年 wendong wang. All rights reserved.
//

#import "WMLEPeripheralService.h"

NSString* kMymcuServiceUUIDString = @"56FF";
NSString* kMymcuWriteUUIDString = @"33F3";
NSString* kMymcuNotifyUUIDString = @"33F4";

@interface WMLEPeripheralService()

@property (strong, nonatomic) CBUUID* mymcuServiceUUID;
@property (strong, nonatomic) CBUUID* writeUUID;
@property (strong, nonatomic) CBUUID* notifyUUID;
@property (strong, nonatomic) CBService* mymcuService;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic* notifyCharacteristic;

@end

@implementation WMLEPeripheralService

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _servicePeripheral = peripheral;
        _servicePeripheral.delegate = self;
        
        _mymcuServiceUUID = [CBUUID UUIDWithString:kMymcuServiceUUIDString];
        _writeUUID = [CBUUID UUIDWithString:kMymcuWriteUUIDString];
        _notifyUUID = [CBUUID UUIDWithString:kMymcuNotifyUUIDString];
    }
    return self;
}

- (void)reset {
    if (_servicePeripheral) {
        _servicePeripheral = nil;
    }
}

- (void)start {
    CBUUID* serviceUUID = [CBUUID UUIDWithString:kMymcuServiceUUIDString];
    NSArray* serviceArray = [NSArray arrayWithObjects:serviceUUID, nil];
    if (_servicePeripheral) {
        [_servicePeripheral discoverServices:serviceArray];
    }
}

#pragma mark - Peripheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (peripheral != _servicePeripheral) {
        WMLog(@"Wrong peripheral.\n");
        return;
    }
    
    if (error) {
        WMLog(@"Error %@ \n", error);
        return;
    }
    
    NSArray* services = nil;
    
    services = peripheral.services;
    
    if (!services || services.count) {
        return;
    }
    
    _mymcuService = nil;
    
    for (int i = 0; i < services.count; i++) {
        CBService* aService = services[i];
        if ([aService.UUID isEqual:_mymcuServiceUUID]) {
            _mymcuService = aService;
            break;
        }
    }
    
    NSArray* uuids = [NSArray arrayWithObjects:_writeUUID, _notifyUUID, nil];
    
    if (_mymcuService) {
        [peripheral discoverCharacteristics:uuids forService:_mymcuService];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSArray* characteristics = service.characteristics;
    
    if (peripheral != _servicePeripheral) {
        WMLog(@"Wrong peripheral.\n");
        return;
    }
    
    if (service != _mymcuService) {
        WMLog(@"Wrong service.\n");
        return;
    }
    
    if (error) {
        WMLog(@"Error %@.\n", error);
        return;
    }
    
    for (CBCharacteristic* characteristic in characteristics) {
        WMLog(@"discovered characteristic %@", characteristic.UUID.UUIDString);
        
        if ([characteristic.UUID isEqual:_writeUUID]) {
            WMLog(@"discovered write characteristic");
            _writeCharacteristic = characteristic;
        } else if ([characteristic.UUID isEqual:_notifyUUID]) {
            WMLog(@"discovered notify characteristic");
            _notifyCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)didReadPeripheral:(CBPeripheral*)peripheral RSSI:(NSNumber*)RSSI error:(NSError*)error {

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSNumber* rssi = peripheral.RSSI;
    [self didReadPeripheral:peripheral RSSI:rssi error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    [self didReadPeripheral:peripheral RSSI:RSSI error:error];
}

@end
