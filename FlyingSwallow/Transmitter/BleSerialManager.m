//
//  BleSerialManager.m
//  RCTouch
//
//  Created by koupoo on 13-4-17.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "BleSerialManager.h"
#import "BasicInfoManager.h"

#define kSerialService           0xFFE0
#define kSerialCharacteristic    0xFFE1
#define kRequestCharacteristic   0xFFE2
#define kOsdCharacteristic       0xFFE4

@interface BleSerialManager(){
    BOOL isTryingConnect;
    CBCharacteristic  *controlCharacteristic;
    CBCharacteristic  *requestCharacteristic;
    CBCharacteristic  *osdCharacteristic;
}

@end

@implementation BleSerialManager

- (id)init{
    if(self = [super init]){
       _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
       _bleSerialList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isConnected{
    return [_currentBleSerial isConnected];
}

- (void)scan{
    if (_isAvailabel == YES && _isScanning == NO) {
        _isScanning = YES;
        
        [(NSMutableArray *)_bleSerialList removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeripheralListDidChange object:self userInfo:nil];
        
        if ([_delegate respondsToSelector:@selector(bleSerialManager:didDiscoverBleSerial:)]) {
            [_delegate bleSerialManager:self didDiscoverBleSerial:nil];
        }
        
        CBUUID *serialServiceUUID = [self getSerialServiceUUID];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:CBCentralManagerScanOptionAllowDuplicatesKey, @"YES", nil];
        
       // [_centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:serialServiceUUID]
                                                    //options:options];
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        
//        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        NSLog(@"Scanning started");
    }
}

-(void)stopScan{
    if (_centralManager != nil) {
        [_centralManager stopScan];
    }
    _isScanning = NO;
}

-(void)connect:(CBPeripheral *)peripheral{
    if (peripheral == _currentBleSerial) {
        if ([self isConnected]) {
            return;
        }
        if (isTryingConnect) {
            return;
        }
        
        isTryingConnect = YES;
        [_centralManager connectPeripheral:peripheral options:nil];
    }
    else{        
        [self disconnect];
        isTryingConnect = YES;
        _currentBleSerial = [peripheral retain];
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

-(void)disconnect{
    if (_currentBleSerial != nil) {
        [_centralManager cancelPeripheralConnection:_currentBleSerial];
        [_currentBleSerial release];
        _currentBleSerial = nil;
        [controlCharacteristic release];
        controlCharacteristic = nil;
        
        [requestCharacteristic release];
        requestCharacteristic = nil;
        
        [osdCharacteristic release];
        osdCharacteristic = nil;
    }
}

-(void)sendControlData:(NSData *)data{
    if(controlCharacteristic == nil){
        if ([_delegate respondsToSelector:@selector(bleSerialManagerDidFailSendData:error:)]) {
            [_delegate bleSerialManagerDidFailSendData:self error:nil];
        }
    }
    else{
        [_currentBleSerial writeValue:data forCharacteristic:controlCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

-(void)sendRequestData:(NSData *)data{
    if(requestCharacteristic == nil){
        if ([_delegate respondsToSelector:@selector(bleSerialManagerDidFailSendData:error:)]) {
            [_delegate bleSerialManagerDidFailSendData:self error:nil];
        }
    }
    else{
        [_currentBleSerial writeValue:data forCharacteristic:requestCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

#pragma mark CBPeripheralDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        _isAvailabel = YES;
    }
    else{
        _isAvailabel = NO;
    }
    
    if([_delegate respondsToSelector:@selector(bleSerialManager:didUpdateState:)]){
        [_delegate bleSerialManager:self didUpdateState:_isAvailabel];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    // Reject any where the value is above reasonable range
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
//    if (RSSI.integerValue > -15) {
//        return;
//    }
//    
//    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//    if (RSSI.integerValue < -35) {
//        return;
//    }
    
//    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    
    if (![_bleSerialList containsObject:peripheral] && ([peripheral.name isEqualToString:@"AnyFlite"] || [peripheral.name isEqualToString:@"Hex Mini"] || [peripheral.name isEqualToString:@"HMSoft"] || [peripheral.name isEqualToString:@"Hex Nano"] || [peripheral.name isEqualToString:@"Any Flite"] || [peripheral.name isEqualToString:@"Flexbot"])) {
        [(NSMutableArray *)_bleSerialList addObject:peripheral];

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeripheralListDidChange object:self userInfo:nil];
        
        if ([_delegate respondsToSelector:@selector(bleSerialManager:didDiscoverBleSerial:)]) {
            [_delegate bleSerialManager:self didDiscoverBleSerial:nil];
        }
	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if (peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }
    
    isTryingConnect = NO;
    
    _currentBleSerial = [peripheral retain];
    
//    if(_delegate != nil){
//        if ([_delegate respondsToSelector:@selector(bleSerialManager:didConnectPeripheral:)]) {
//            [_delegate bleSerialManager:self didConnectPeripheral:peripheral];
//        }
//    }
    
    [_centralManager stopScan];
    _isScanning = NO;
    
    NSLog(@"Peripheral Connected");;
    NSLog(@"Scanning stopped");
    peripheral.delegate = self;
    
    CBUUID *serialServiceUUID = [self getSerialServiceUUID];

    [peripheral discoverServices:[NSArray arrayWithObject:serialServiceUUID]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }
    
    isTryingConnect = NO;

    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    
    [_currentBleSerial release];
    _currentBleSerial = nil;
}

//当非正常断开（cancelPeripheralConnection）时，error为断开的原因，
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{    
    if (_currentBleSerial != nil && peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }
    
    isTryingConnect = NO;
    if (error != nil) {
        NSLog(@"disconnect error:%@. (%@)", peripheral, [error localizedDescription]);
    }
    
    [_currentBleSerial release];
    _currentBleSerial = nil;
    
    if(_delegate != nil){
        if ([_delegate respondsToSelector:@selector(bleSerialManager:didDisconnectPeripheral:)]) {
            [_delegate bleSerialManager:self didDisconnectPeripheral:peripheral];
        }
    }
}
#pragma mark CBPeripheralDelegate Methods end


- (void)cleanup
{
//    // Don't do anything if we're not connected
//    if (!_currentBleSerial.isConnected) {
//        return;
//    }
//    
//    // See if we are subscribed to a characteristic on the peripheral
//    if (_currentBleSerial.services != nil) {
//        for (CBService *service in _currentBleSerial.services) {
//            if (service.characteristics != nil) {
//                for (CBCharacteristic *characteristic in service.characteristics) {
//                    
//                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
//                        if (characteristic.isNotifying) {
//                            // It is notifying, so unsubscribe
//                            [_currentBleSerial setNotifyValue:NO forCharacteristic:characteristic];
//                            
//                            // And we're done.
//                            return;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
//    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}


#pragma mark CBPeripheralDelegate Methods
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }
    
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    NSArray *characteristicList = [NSArray arrayWithObjects:[self getControlCharacteristicUUID], [self getRequestCharacteristicUUID], [self getOsdCharacteristicUUID], nil];
    
    // Discover the characteristic we want...
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:characteristicList forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }

    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    int characteristicCnt = 0;
    
    #define kCharacteristicCnt 3
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[self getControlCharacteristicUUID]]) {
            [controlCharacteristic release];
            controlCharacteristic = [characteristic retain];
            
            characteristicCnt++;
        }
        else if ([characteristic.UUID isEqual:[self getRequestCharacteristicUUID]]) {
            [requestCharacteristic release];
            requestCharacteristic = [characteristic retain];
            
            characteristicCnt++;
        }
        
        else if([characteristic.UUID isEqual:[self getOsdCharacteristicUUID]]) {
            [osdCharacteristic release];
            osdCharacteristic = [characteristic retain];
            
            characteristicCnt++;
            
            [peripheral setNotifyValue:YES forCharacteristic:osdCharacteristic];
        }
        
        if (characteristicCnt == kCharacteristicCnt) {
            break;
        }
    }
    if (characteristicCnt == kCharacteristicCnt) {
        NSLog(@"***success found all characteritics");
        
        if(_delegate != nil){
            if ([_delegate respondsToSelector:@selector(bleSerialManager:didConnectPeripheral:)]) {
                [_delegate bleSerialManager:self didConnectPeripheral:peripheral];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (peripheral != _currentBleSerial) {  //old peripheral just do nothing
        return;
    }

    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error: %@", [error localizedDescription]);
        return;
    }
    
    
    
    NSData *data = characteristic.value;
    char what[200];
    [data  getBytes:what length:[data length]];
    what[[data length]] = '\0';
    
    NSLog(@"Received data len:%d, data:%s", [data length], what);
    
    
    NSString *NSMutableString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if (NSMutableString != nil) {
        [[[BasicInfoManager sharedManager] debugStr] setString:NSMutableString];
    }
    
    NSLog(@"Received: %@", NSMutableString);
    
    if ([_delegate respondsToSelector:@selector(bleSerialManager:didReceiveData:)]) {
        [_delegate bleSerialManager:self didReceiveData:characteristic.value];
    }
    
//    // Have we got everything we need?
//    if ([stringFromData isEqualToString:@"EOM"]) {
//        
//        // We have, so show the data,
//        [self.textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
//        
//        // Cancel our subscription to the characteristic
//        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
//        
//        // and disconnect from the peripehral
//        [self.centralManager cancelPeripheralConnection:peripheral];
//    }
//    
//    // Otherwise, just add the data on to what we already have
//    [self.data appendData:characteristic.value];
//    
//    // Log it
}

//Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (peripheral != _currentBleSerial || characteristic != osdCharacteristic) {  //old, just do nothing
        return;
    }
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self disconnect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (peripheral != _currentBleSerial || characteristic != controlCharacteristic  || characteristic != requestCharacteristic) { //old do nothing
        return;
    }

    if (error != nil) {
        if ([_delegate respondsToSelector:@selector(bleSerialManagerDidFailSendData:error:)]) {
            [_delegate bleSerialManagerDidFailSendData:self error:error];
        }
    }
    else{
        if ([_delegate respondsToSelector:@selector(bleSerialManagerDidSendData:)]) {
            [_delegate bleSerialManagerDidSendData:self];
        }
    }
}

#pragma mark CBPeripheralDelegate Methods end

/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (CBUUID *)getSerialServiceUUID{
    UInt16 serialService = [self swap:kSerialService];
    
    NSData *serialServiceData = [[[NSData alloc] initWithBytes:(char *)&serialService length:2] autorelease];
    return [CBUUID UUIDWithData:serialServiceData];
}

- (CBUUID *)getControlCharacteristicUUID{
    UInt16 serialCharacteristic_ = [self swap:kSerialCharacteristic];
    
    NSData *serialCharacteristicData = [[[NSData alloc] initWithBytes:(char *)&serialCharacteristic_ length:2] autorelease];
    
    return [CBUUID UUIDWithData:serialCharacteristicData];
}

- (CBUUID *)getOsdCharacteristicUUID{
    UInt16 osdCharacteristic_ = [self swap:kOsdCharacteristic];
    
    NSData *osdCharacteristicData = [[[NSData alloc] initWithBytes:(char *)&osdCharacteristic_ length:2] autorelease];
    
    return [CBUUID UUIDWithData:osdCharacteristicData];
}

- (CBUUID *)getRequestCharacteristicUUID{
    UInt16 requestCharacteristic_ = [self swap:kRequestCharacteristic];
    
    NSData *requestCharacteristicData = [[[NSData alloc] initWithBytes:(char *)&requestCharacteristic_ length:2] autorelease];
    
    return [CBUUID UUIDWithData:requestCharacteristicData];
}


- (void)dealloc{
    [self disconnect];
    [_centralManager release];
    [_bleSerialList release];
    [controlCharacteristic release];
    [osdCharacteristic release];
    [requestCharacteristic release];
    [super dealloc];
}

@end
