//
//  OSDCommon.c
//  UdpEchoClient
//
//  Created by koupoo on 13-3-1.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#include "OSDCommon.h"
#include <vector>
#include <string>

#define kOsdInfoRequestListLen 3

using namespace std;


/*MSP_ATTITUDE
*/

//int mainInfoRequest[kOsdInfoRequestListLen]  = {MSP_IDENT, MSP_MOTOR_PINS, MSP_STATUS, MSP_RAW_IMU, MSP_SERVO, MSP_MOTOR, MSP_RC, MSP_RAW_GPS, MSP_COMP_GPS, MSP_ALTITUDE,MSP_ATTITUDE, MSP_BAT, MSP_DEBUG};
//int mainInfoRequest[kOsdInfoRequestListLen] = {MSP_RAW_GPS, MSP_COMP_GPS, MSP_ALTITUDE,MSP_BAT,MSP_ATTITUDE};

int mainInfoRequest[kOsdInfoRequestListLen] = {MSP_ATTITUDE, MSP_ALTITUDE, MSP_BAT};


#ifdef __cplusplus
extern "C"{
#endif

/*创建出特定的带参数的请求
 *@param msp 请求的命令
 *@param payload 请求命令的参数
 *@returns 返回创建的请求
 */
vector<byte> requestMSPWithPayload (int msp, const string & payload) {
    vector<byte> bf;
    
    if(msp < 0) {
        return bf;
    }
    
    bf.insert(bf.begin(), MSP_HEADER, MSP_HEADER + strlen(MSP_HEADER));
    
    byte checksum=0;
    
    int payloadLength = payload.length();
    
    byte pl_size = payloadLength != 0 ? (byte)payloadLength : 0;
    
    bf.push_back(pl_size);
    
    checksum ^= (pl_size&0xFF);
    
    bf.push_back((byte)(msp & 0xFF));
    
    checksum ^= (msp&0xFF);
    
    if (payloadLength != 0) {        
        byte b;
        for(int byteIdx = 0; byteIdx < payloadLength; byteIdx++){
            b = payload[byteIdx];            
            bf.push_back((byte)(b&0xFF));
            checksum ^= (b&0xFF);
        }
        
    }
    bf.push_back(checksum);
    return (bf);
}


/*创建出特定的待参数的请求
 *@param msps 请求的命令列表
 *@param count 请求命令的个数
 *@returns 返回创建的请求
 */
vector<byte> requestMSPList (const int *msps, int count) {
    vector<byte> requestList;
    string emptyPayload("");
    
    for(int mspIdx = 0; mspIdx < count; mspIdx++){
        vector<byte> oneRequest = requestMSPWithPayload(msps[mspIdx], emptyPayload);
        
        requestList.insert(requestList.end(), oneRequest.begin(), oneRequest.end());
    }
    return requestList;
}

/*创建出特定命令的请求
 *@param msp 请求的命令
 *@returns 返回创建的请求
 */
vector<byte> requestMSP(int msp) {
    string payload("");
    return requestMSPWithPayload(msp, payload);
}

/*向串口中发送请求
 *@param msp 所要发送的请求
 */
void sendRequestMSP(const vector<byte>& msp) {
  //  serialCon->write(msp); // send the complete byte sequence in one go
}



NSData *getDefaultOSDDataRequest(){
    vector<byte> requestList = requestMSPList(mainInfoRequest, kOsdInfoRequestListLen);
    
    int requestDataSize = requestList.size();
    
    
    
    /*
    printf("\nrequest \n");
    
    for(int idx = 0; idx < requestDataSize; idx++){
        printf("[%d]", requestList[idx]);
    }
    
    printf("end***");
    */
    
    return [NSData dataWithBytes:requestList.data() length:requestList.size()];
}

NSData *getSimpleCommand(unsigned char commandName){
    unsigned char package[6];

    package[0] = '$';
    package[1] = 'M';
    package[2] = '<';
    package[3] = 0;
    package[4] = commandName;
    
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 5;
    
    checkSum ^= (package[dataSizeIdx] & 0xFF);
    checkSum ^= (package[dataSizeIdx + 1] & 0xFF);
    
    package[checkSumIdx] = checkSum;

    return [NSData dataWithBytes:package length:6];
}

    
#ifdef __cplusplus
}
#endif



