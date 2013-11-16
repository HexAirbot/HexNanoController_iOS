//
//  BleSerialManager.h
//  RCTouch
//
//  Created by koupoo on 13-4-17.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kNotificationPeripheralListDidChange @"NPeripheralListDidChange"

@class BleSerialManager;

@protocol BleSerialManagerDelegate <NSObject>

@optional
-(void)bleSerialManager:(BleSerialManager *)manager didUpdateState:(BOOL)isAvailable;
-(void)bleSerialManager:(BleSerialManager *)manager didDiscoverBleSerial:(CBPeripheral *)peripheral;

-(void)bleSerialManager:(BleSerialManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral;
-(void)bleSerialManager:(BleSerialManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral;
-(void)bleSerialManager:(BleSerialManager *)manager didDisconnectPeripheral:(CBPeripheral *)peripheral;

-(void)bleSerialManagerDidFailSendData:(BleSerialManager *)manager error:(NSError *)error;
-(void)bleSerialManagerDidSendData:(BleSerialManager *)manager;
-(void)bleSerialManager:(BleSerialManager *)manager didReceiveData:(NSData *)data;


@end

@interface BleSerialManager : NSObject <CBCentralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic, readonly) BOOL isAvailabel; //ble是否可用
@property(nonatomic, readonly) BOOL isConnected; //连接上Ble
@property(nonatomic, readonly) BOOL isReady;     //当Services和Charactristic都准备就绪，就可以传输数据了
@property(nonatomic, readonly) BOOL isScanning;
@property(nonatomic, readonly) CBCentralManager *centralManager;
@property(nonatomic, readonly) NSArray *bleSerialList;
@property(nonatomic, readonly) CBPeripheral *currentBleSerial;
@property(nonatomic, assign) id<BleSerialManagerDelegate> delegate;

//当isReady为NO时，scan不执行任何操作
-(void)scan;
-(void)stopScan;

-(void)connect:(CBPeripheral *)peripheral;
-(void)disconnect;

-(void)sendData:(NSData *)data;


@end
