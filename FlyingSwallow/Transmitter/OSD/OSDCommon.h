//
//  OSDCommon.h
//  UdpEchoClient
//
//  Created by koupoo on 13-3-1.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef UdpEchoClient_OSDCommon_h
#define UdpEchoClient_OSDCommon_h

typedef unsigned char byte;

#define MSP_HEADER  "$M<"

#define MSP_IDENT                100
#define MSP_STATUS               101
#define MSP_RAW_IMU              102
#define MSP_SERVO                103
#define MSP_MOTOR                104
#define MSP_RC                   105
#define MSP_RAW_GPS              106
#define MSP_COMP_GPS             107
#define MSP_ATTITUDE             108
#define MSP_ALTITUDE             109
#define MSP_BAT                  110
#define MSP_RC_TUNING            111
#define MSP_PID                  112
#define MSP_BOX                  113
#define MSP_MISC                 114
#define MSP_MOTOR_PINS           115
#define MSP_BOXNAMES             116
#define MSP_PIDNAMES             117

#define MSP_SET_RAW_RC_TINY      150
#define MSP_ARM                  151
#define MSP_DISARM               152
#define MSP_TRIM_UP              153
#define MSP_TRIM_DOWN            154
#define MSP_TRIM_LEFT            155
#define MSP_TRIM_RIGHT           156

#define MSP_READ_TEST_PARAM      189
#define MSP_SET_TEST_PARAM       190

#define MSP_SET_RAW_RC           200
#define MSP_SET_RAW_GPS          201
#define MSP_SET_PID              202
#define MSP_SET_BOX              203
#define MSP_SET_RC_TUNING        204
#define MSP_ACC_CALIBRATION      205
#define MSP_MAG_CALIBRATION      206
#define MSP_SET_MISC             207
#define MSP_RESET_CONF           208

#define MSP_EEPROM_WRITE         250

#define MSP_DEBUG                254

#ifdef __cplusplus
extern "C"{
#endif

NSData *getDefaultOSDDataRequest();
NSData *getSimpleCommand(unsigned char commandName);

#ifdef __cplusplus
}
#endif

#endif
