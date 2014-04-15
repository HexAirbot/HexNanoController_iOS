//
//  OSDData.m
//  UdpEchoClient
//
//  Created by koupoo on 13-2-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//


#import "OSDData.h"
#include "OSDCommon.h"
#include <vector>
#include <string>

using namespace std;

#define OSD_UPDATE_REQUEST_FREQ 50

#define IDLE         0
#define HEADER_START 1
#define HEADER_M     2
#define HEADER_ARROW 3
#define HEADER_SIZE  4
#define HEADER_CMD   5
#define HEADER_ERR   6


@interface OSDData(){
    int c_state;
    bool err_rcvd;
    byte checksum;
    byte cmd;
    int offset, dataSize;
    byte inBuf[256];
    int p;
    
    
    float mot[8], servo[8];
    long currentTime,mainInfoUpdateTime,attitudeUpdateTime;
}

@end

@implementation OSDData

@synthesize version = _version;

@synthesize multiType = _multiType;

@synthesize gyroX = _gyroX;
@synthesize gyroY = _gyroY;
@synthesize gyroZ = _gyroZ;

@synthesize accX = _accX;
@synthesize accY = _accY;
@synthesize accZ = _accZ;

@synthesize magX = _magX;
@synthesize magY = _magY;
@synthesize magZ = _magZ;

@synthesize altitude = _altitude;
@synthesize head = _head;
@synthesize angleX = _angleX;
@synthesize angleY = _angleY;

@synthesize gpsSatCount = _gpsSatCount;
@synthesize gpsLongitude = _gpsLongitude;
@synthesize gpsLatitude = _gpsLatitude;
@synthesize gpsAltitude = _gpsAltitude;
@synthesize gpsDistanceToHome = _gpsDistanceToHome;
@synthesize gpsDirectionToHome = _gpsDirectionToHome;
@synthesize gpsFix = _gpsFix;
@synthesize gpsUpdate = _gpsUpdate;
@synthesize gpsSpeed = _gpsSpeed;

@synthesize rcThrottle = _rcThrottle;
@synthesize rcYaw = _rcYaw;
@synthesize rcRoll = _rcRoll;
@synthesize rcPitch = _rcPitch;
@synthesize rcAux1 = _rcAux1;
@synthesize rcAux2 = _rcAux2;
@synthesize rcAux3 = _rcAux3;
@synthesize rcAux4 = _rcAux4;

@synthesize pMeterSum = _pMeterSum;
@synthesize vBat = _vBat;

@synthesize cycleTime = _cycleTime;
@synthesize i2cError = _i2cError;

@synthesize mode = _mode;
@synthesize present = _present;

@synthesize debug1 = _debug1;
@synthesize debug2 = _debug2;
@synthesize debug3 = _debug3;
@synthesize debug4 = _debug4;

@synthesize delegate = _delegate;

- (id)init{
    if(self =[super init]){
        _rcThrottle = 1500;
        _rcRoll     = 1500;
        _rcPitch    = 1500;
        _rcYaw      =1500;
        _rcAux1     =1500;
        _rcAux2     =1500;
        _rcAux3     =1500;
        _rcAux4     =1500;

    }
    
    return self;
}

- (id)initWithOSDData:(OSDData *)osdData{
    if(self = [super init]){
        _version = osdData.version;
        
        _multiType = osdData.multiType;
        
        _gyroX = osdData.gyroX;
        _gyroY = osdData.gyroY;
        _gyroZ = osdData.gyroZ;
        
        _accX = osdData.accX;
        _accY = osdData.accY;
        _accZ = osdData.accZ;
        
        _magX = osdData.magX;
        _magY = osdData.magY;
        _magZ = osdData.magZ;
        
        _altitude = osdData.altitude;
        _head     = osdData.head;
        _angleX   = osdData.angleX;
        _angleY   = osdData.angleY;
        
        _gpsSatCount  = osdData.gpsSatCount;
        _gpsLongitude = osdData.gpsLongitude;
        _gpsLatitude  = osdData.gpsLatitude;
        _gpsAltitude  = osdData.gpsAltitude;
        _gpsDistanceToHome = osdData.gpsDistanceToHome;
        _gpsDirectionToHome = osdData.gpsDirectionToHome;
        _gpsFix = osdData.gpsFix;
        _gpsUpdate = osdData.gpsUpdate;
        _gpsSpeed = osdData.gpsSpeed;
        
        _rcThrottle = osdData.rcThrottle;
        _rcYaw      = osdData.rcYaw;
        _rcRoll     = osdData.rcRoll;
        _rcPitch    = osdData.rcPitch;
        _rcAux1     = osdData.rcAux1;
        _rcAux2     = osdData.rcAux2;
        _rcAux3     = osdData.rcAux3;
        _rcAux4     = osdData.rcAux4;
        
        _pMeterSum = osdData.pMeterSum;
        _vBat      = osdData.vBat;
        
        _cycleTime = osdData.cycleTime;
        _i2cError = osdData.i2cError;
        
        _mode = osdData.mode;
        _present = osdData.present;
        
        _debug1 = osdData.debug1;
        _debug2 = osdData.debug2;
        _debug3 = osdData.debug3;
        _debug4 = osdData.debug4;
    }
    
    return self;
}

- (Float32)read32{
//    uint32_t part1 = (inBuf[p++]&0xff);
//    uint32_t part2 = ((inBuf[p++]&0xff)<<8);
//    uint32_t part3 = ((inBuf[p++]&0xff)<<16);
//    uint32_t part4 = ((inBuf[p++]&0xff)<<24);
//    
//    uint32_t num = part1 + part2 + part3 + part4;
//    
//    float num2 = 10;
//    
//    
//    memcpy(&num2, &num, 4);
//    
//    
//    return num2;
    
    return (inBuf[p++]&0xff) + ((inBuf[p++]&0xff)<<8) + ((inBuf[p++]&0xff)<<16) + ((inBuf[p++]&0xff)<<24);
}

- (float)int32ToFloat:(int)intNum{
    float floatNum;
    
    memcpy((void *)(&floatNum), (void *)(&intNum), 4);
    
    return floatNum;
}

- (int16_t)read16{
    return (inBuf[p++]&0xff) + ((inBuf[p++])<<8); 
}

- (int)read8 {
    return inBuf[p++]&0xff;
}

- (void)parseRawData:(NSData *)data{
//    if ((currentTime - mainInfoUpdateTime) >(double)(1000 / updateFreq)* CLOCKS_PER_SEC / 1000.0) {  
//        printf("\n***time durantion:%lfms", (currentTime - mainInfoUpdateTime) / (float)CLOCKS_PER_SEC * 1000);
//        
//        mainInfoUpdateTime = currentTime;
//        
//        printf("\nrequest \n");
//        
//        //vector<byte> requestList = requestMSPList(mainInfoRequest, 12);
//        
//        if(_delegate != nil){
//           // NSData *request = [NSData dataWithBytes:requestList.data() length:requestList.size()];
//           // [_delegate sendOsdDataUpdateRequest:request];
//        }
//    }
    
    int byteCount = data.length;
    
    byte * dataPtr = (byte *)data.bytes;
    
    int idx;
    byte c;
    
    for (int byteIdx = 0; byteIdx < byteCount; byteIdx++) {
        c = dataPtr[byteIdx];
        
        if (c_state == IDLE) {
            c_state = (c=='$') ? HEADER_START : IDLE;
        } else if (c_state == HEADER_START) {
            c_state = (c=='M') ? HEADER_M : IDLE;
        } else if (c_state == HEADER_M) {
            if (c == '>') {
                c_state = HEADER_ARROW;
            } else if (c == '!') {
                c_state = HEADER_ERR;
            } else {
                c_state = IDLE;
            }
        } else if (c_state == HEADER_ARROW || c_state == HEADER_ERR) {
            /* is this an error message? */
            err_rcvd = (c_state == HEADER_ERR);        /* now we are expecting the payload size */
            dataSize = (c&0xFF);
            /* reset index variables */
            p = 0;
            offset = 0;
            checksum = 0;
            checksum ^= (c&0xFF);
            /* the command is to follow */
            c_state = HEADER_SIZE;
        } else if (c_state == HEADER_SIZE) {
            cmd = (byte)(c&0xFF);
            checksum ^= (c&0xFF);
            c_state = HEADER_CMD;
        } else if (c_state == HEADER_CMD && offset < dataSize) {
            checksum ^= (c&0xFF);
            inBuf[offset++] = (byte)(c&0xFF);
        } else if (c_state == HEADER_CMD && offset >= dataSize) {
            /* compare calculated and transferred checksum */
            if ((checksum&0xFF) == (c&0xFF)) {
                if (err_rcvd) {
                    //printf("Copter did not understand request type %d\n", c);
                     c_state = IDLE;
                    
                } else {
                    /* we got a valid response packet, evaluate it */
                    [self evaluateCommand:cmd dataSize:dataSize];
                }
            } else {
                printf("invalid checksum for command %d: %d expected, got %d\n", ((int)(cmd&0xFF)), (checksum&0xFF), (int)(c&0xFF));
                printf("<%d %d> {",(cmd&0xFF), (dataSize&0xFF));
                
                for (idx = 0; idx < dataSize; idx++) {
                    if (idx != 0) { 
                        printf(" ");   
                    }
                    printf("%d",(inBuf[idx] & 0xFF));
                }
                
                printf("} [%d]\n", c);
                
                string data((char *)inBuf, dataSize);
                
                printf("%s\n", data.c_str());
                
            }
            c_state = IDLE;
        }

    }
}

- (void)evaluateCommand:(byte)cmd_ dataSize:(int)dataSize{    
    int i;
    int icmd = (int)(cmd_ & 0xFF);
    switch(icmd) {
        case MSP_IDENT:
            _version = [self read8];
            _multiType = [self read8];
            [self read8]; // MSP version
            [self read32];// capability
            break;
        case MSP_STATUS:
            _cycleTime = [self read16];
            _i2cError  = [self read16];
            _present   = [self read16];
            _mode      = [self read32];
            break;
        case MSP_RAW_IMU:
            _accX = [self read16];
            _accY = [self read16];
            _accZ = [self read16];
            _gyroX = [self read16] / 8;
            _gyroY = [self read16] / 8;
            _gyroZ = [self read16] / 8;
            _magX = [self read16] / 3;
            _magY = [self read16] / 3;
            _magZ = [self read16] / 3;             
            break;
        case MSP_SERVO:
            for(i=0;i<8;i++) 
                servo[i] = [self read16]; 
            break;
        case MSP_MOTOR:
            for(i=0;i<8;i++) 
                mot[i] = [self read16]; 
            break;
        case MSP_RC:
            _rcRoll     = [self read16];
            _rcPitch    = [self read16];
            _rcYaw      = [self read16];
            _rcThrottle = [self read16];    
            _rcAux1 = [self read16];
            _rcAux2 = [self read16];
            _rcAux3 = [self read16];
            _rcAux4 = [self read16];
            break;
        case MSP_RAW_GPS:
            _gpsFix = [self read8];
            _gpsSatCount = [self read8];
            _gpsLatitude = [self read32];
            _gpsLongitude = [self read32];
            _gpsAltitude = [self read16];
            _gpsSpeed = [self read16]; 
            break;
        case MSP_COMP_GPS:
            _gpsDistanceToHome = [self read16];
            _gpsDirectionToHome = [self read16];
            _gpsUpdate = [self read8]; 
            break;
        case MSP_ATTITUDE:
            _angleX = [self read16]/10;  //[-180,180]，往右roll时，为正数
            _angleY = [self read16]/10;  //[-180,180]，头往上仰时，为负
            _head = [self read16]; 
            
            if(_delegate != nil) {
                [_delegate osdDataDidUpdateOneFrame:self];
            }
            break;
        case MSP_ALTITUDE:
            _altitude = (float) [self read32]; //[self int32ToFloat:[self read32]];
            break;
        case MSP_BAT:
            _vBat = [self read8] / 256.0f * 5;
            _pMeterSum = [self read16]; 
            break;
        case MSP_RC_TUNING:
            break;
        case MSP_ACC_CALIBRATION:
            break;
        case MSP_MAG_CALIBRATION:
            break;
        case MSP_PID:
            break;
        case MSP_BOX:
            break;
        case MSP_BOXNAMES:
            break;
        case MSP_PIDNAMES:
            break;
        case MSP_MISC:
            break;
        case MSP_MOTOR_PINS:
            break;
        case MSP_SET_RAW_RC_TINY:
            NSLog(@"set rc: %d, %d, %d, %d", [self read16], [self read16], [self read16], [self read16]);
            break;
        case MSP_SET_TEST_PARAM:
            
            break;
        case MSP_READ_TEST_PARAM:
            _param1  = [self read8];
            _param2  = [self read8];
            _param3  = [self read8];
            _param4  = [self read8];
            _param5  = [self read8];
            _param6  = [self read8];
            _param7  = [self read8];
            _param8  = [self read8];
            _param9  = [self read8];
            _param10 = [self read8];
            _param11 = [self read8];
            _param12 = [self read8];
            
            NSLog(@"***get p5:%f", _param5);
            NSLog(@"***get p6:%f", _param6);
            break;
        case MSP_DEBUG:
            _debug1 = [self read16];
            _debug2 = [self read16];
            _debug3 = [self read16];
            _debug4 = [self read16];
            break;
        default:
            printf("\n***error: Don't know how to handle reply:%d\n datasize:%d", icmd, dataSize);
            break;
           
    }
}


@end
