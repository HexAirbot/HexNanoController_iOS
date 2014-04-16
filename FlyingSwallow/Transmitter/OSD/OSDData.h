//
//  OSDData.h
//  UdpEchoClient
//
//  Created by koupoo on 13-2-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class OSDData;

@protocol OSDDataDelegate <NSObject>

//- (void)OSDDataDidUpdateTimeOut:(OSDData *)osdData;

- (void)osdDataDidUpdateOneFrame:(OSDData *)osdData;

@end


@interface OSDData : NSObject{
    int present;
}

@property(nonatomic, readonly) int version;

@property(nonatomic, readonly) int multiType;

@property(nonatomic, readonly) float gyroX;
@property(nonatomic, readonly) float gyroY;
@property(nonatomic, readonly) float gyroZ;

@property(nonatomic, readonly) float accX;
@property(nonatomic, readonly) float accY;
@property(nonatomic, readonly) float accZ;

@property(nonatomic, readonly) float magX;
@property(nonatomic, readonly) float magY;
@property(nonatomic, readonly) float magZ;

@property(nonatomic, readonly) float altitude;
@property(nonatomic, readonly) float head;
@property(nonatomic, readonly) float angleX;
@property(nonatomic, readonly) float angleY;

@property(nonatomic, readonly) int gpsSatCount;
@property(nonatomic, readonly) int gpsLongitude;
@property(nonatomic, readonly) int gpsLatitude;
@property(nonatomic, readonly) int gpsAltitude;
@property(nonatomic, readonly) int gpsDistanceToHome;
@property(nonatomic, readonly) int gpsDirectionToHome;
@property(nonatomic, readonly) int gpsFix;
@property(nonatomic, readonly) int gpsUpdate;
@property(nonatomic, readonly) int gpsSpeed;

@property(nonatomic, readonly) float rcThrottle;
@property(nonatomic, readonly) float rcYaw;
@property(nonatomic, readonly) float rcRoll;
@property(nonatomic, readonly) float rcPitch;
@property(nonatomic, readonly) float rcAux1;
@property(nonatomic, readonly) float rcAux2;
@property(nonatomic, readonly) float rcAux3;
@property(nonatomic, readonly) float rcAux4;

@property(nonatomic, readonly) float debug1;
@property(nonatomic, readonly) float debug2;
@property(nonatomic, readonly) float debug3;
@property(nonatomic, readonly) float debug4;


@property(nonatomic, readonly) int pMeterSum;
@property(nonatomic, readonly) float vBat;

@property(nonatomic, readonly) int cycleTime;
@property(nonatomic, readonly) int i2cError;

@property(nonatomic, readonly) int mode;
@property(nonatomic, readonly) int present;

@property(nonatomic, readonly) int absolutedAccZ;

@property(nonatomic, readonly) float param1;
@property(nonatomic, readonly) float param2;
@property(nonatomic, readonly) float param3;
@property(nonatomic, readonly) float param4;
@property(nonatomic, readonly) float param5;
@property(nonatomic, readonly) float param6;
@property(nonatomic, readonly) float param7;
@property(nonatomic, readonly) float param8;
@property(nonatomic, readonly) float param9;
@property(nonatomic, readonly) float param10;
@property(nonatomic, readonly) float param11;
@property(nonatomic, readonly) float param12;



@property(nonatomic, assign) id<OSDDataDelegate> delegate;

- (id)initWithOSDData:(OSDData *)osdData;
- (void)parseRawData:(NSData *)data;


@end
