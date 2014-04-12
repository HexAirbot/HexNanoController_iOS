//
//  PPMTransmitter.m
//  RCTouch
//
//  Created by koupoo on 13-3-15.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "Transmitter.h"
#import "AsyncUdpSocket.h"
#import "OSDCommon.h"
#import "BasicInfoManager.h"


#define kPpmChannelCount 8

#define UDP_SERVER_HOST @"192.168.0.1"
#define UDP_SERVER_PORT 6000

#define kOsdRequestFreqRatio  2        //Freq = 1.0/kOsdRequestFreqRatio * 50 

#define kInputAllowableContiniousTimeoutCount  2
#define kOutputAllowableContiniousTimeoutCount 2

#define kInputTimeout  0.5
#define kOutputTimeout 0.5

static Transmitter *sharedTransmitter;

@interface Transmitter(){
    enum PpmPolarity polarity;
    NSTimer *timer;
    
    float oldChannelList[kPpmChannelCount];
    float channelList[kPpmChannelCount];  //   ROLL,PITCH,YAW,THROTTLE,AUX1,AUX2,AUX3,AUX4

    unsigned char package[22];
    
    BleSerialManager *bleSerialMangager;
    
    int outputTimeoutCount;
    int inputTimeoutCount;
}

@end

@implementation Transmitter

@synthesize osdData = _osdData;
@synthesize outputState = _outputState;
@synthesize inputState = _inputState;

+ (Transmitter *)sharedTransmitter{
    if (sharedTransmitter == nil) {
		sharedTransmitter = [[super alloc] init];
		return sharedTransmitter;
	}
	return sharedTransmitter;
}

- (id)init{
    if(self = [super init]){
        _outputState = TransmitterStateError;
        _inputState = TransmitterStateError;
        bleSerialMangager = [[BleSerialManager alloc] init];
        bleSerialMangager.delegate = self;
    }
    return self;
}

- (BleSerialManager *)bleSerialManager{
    return bleSerialMangager;
}


//传输4个通道的数据，通道数据占4个字节
- (void)updatePpmPackage2{
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 9;
    
    checkSum ^= (package[dataSizeIdx] & 0xFF);
    checkSum ^= (package[dataSizeIdx + 1] & 0xFF);
    
    for(int channelIdx = 0; channelIdx < kPpmChannelCount - 4; channelIdx++){
        float scale =  channelList[channelIdx];
        
        if (scale > 1) {
            scale = 1;
        }
        else if(scale < -1){
            scale = -1;
        }
        
        unsigned char pulseLen =  (uint16_t)(fabs(500 + 500 * scale)) / 4;
        
        package[5 + channelIdx] = pulseLen;
        checkSum ^= (package[5 + channelIdx] & 0xFF);
    }
    
    package[checkSumIdx] = checkSum;
}


//传输八个通道的数据，通道数据用5个字节来表示
- (void)updatePpmPackage{
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 10;
    
    package[dataSizeIdx] = 5;
    
    checkSum ^= (package[dataSizeIdx] & 0xFF);
    checkSum ^= (package[dataSizeIdx + 1] & 0xFF);
    
    for(int channelIdx = 0; channelIdx < kPpmChannelCount - 4; channelIdx++){
        float scale =  channelList[channelIdx];
        
        
        if (scale > 1) {
            scale = 1;
        }
        else if(scale < -1){
            scale = -1;
        }
        
        unsigned char pulseLen =  (uint16_t)(fabs(500 + 500 * scale)) / 4;
    
        package[5 + channelIdx] = pulseLen;

//蓝牙延迟测试
//        if(channelIdx ==0){
//            static int len = 0;
//            package[5 + channelIdx] = len++;
//            if (len > 250) {
//                len = 0;
//            }
//        }
        
        checkSum ^= (package[5 + channelIdx] & 0xFF);
    }
    
    unsigned char auxChannels = 0x00;
    
    float aux1Scale = channelList[4];
    
    if (aux1Scale < -0.666) {
        auxChannels |= 0x00;
    }
    else if(aux1Scale < 0.3333){
        auxChannels |= 0x40;
    }
    else{
        auxChannels |= 0x80;
    }
    
    float aux2Scale = channelList[5];
    
    if (aux2Scale < -0.666) {
        auxChannels |= 0x00;
    }
    else if(aux2Scale < 0.3333){
        auxChannels |= 0x10;
    }
    else{
        auxChannels |= 0x20;
    }
    
    float aux3Scale = channelList[6];
    
    if (aux3Scale < -0.666) {
        auxChannels |= 0x00;
    }
    else if(aux3Scale < 0.3333){
        auxChannels |= 0x04;
    }
    else{
        auxChannels |= 0x08;
    }
    
    float aux4Scale = channelList[7];
    
    if (aux4Scale < -0.666) {
        auxChannels |= 0x00;
    }
    else if(aux4Scale < 0.3333){
        auxChannels |= 0x01;
    }
    else{
        auxChannels |= 0x02;
    }
    
    
    package[5 + 4] = auxChannels;
    checkSum ^= (package[5 + 4] & 0xFF);
    
    
    package[checkSumIdx] = checkSum;
}



- (void)updatePackageCheckSum{
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 21;
    
    for (int checkIdx = dataSizeIdx; checkIdx < checkSumIdx; checkIdx++) {
        checkSum ^= (package[checkIdx] & 0xFF);
    }
    
    package[checkSumIdx] = checkSum;
}

- (void)initPackage{
    package[0] = '$';
    package[1] = 'M';
    package[2] = '<';
    package[3] = 4;

    //package[3] = 16;
    //package[4] = (byte)MSP_SET_RAW_RC;
    
    package[4] = MSP_SET_RAW_RC_TINY;
    
    //[self updatePpmPackage];
    
    [self updatePpmPackage];
}

- (void)sendTransmitterStateDidChangeNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTransmitterStateDidChange object:self userInfo:nil];
}

- (void)sendOsdRequest{

}

- (void)transmmit{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    static int osdRequestTimer = 0;
    osdRequestTimer++;
    
    [self updatePpmPackage];
    
    BOOL channelListIsChange = NO;
    
    /*
    for(int channelIdx = 0; channelIdx < kPpmChannelCount; channelIdx++){
        if (fabs(channelList[channelIdx] - oldChannelList[channelIdx]) > 0.004f) {
            channelListIsChange = YES;
            NSLog(@"***channelListIsChange");
            break;
        }å
    }
    */
    
    NSData *request = getDefaultOSDDataRequest();
    
    memcpy(oldChannelList, channelList, kPpmChannelCount * sizeof(float));
    
    NSMutableData *data = nil;

    if (data == nil) {
        data = [NSMutableData dataWithBytes:package length:11];
    }
    else{
        [data appendData:[NSData dataWithBytes:package length:11]];
    }
    
    if ([bleSerialMangager isConnected] && data != nil) {
        [bleSerialMangager sendControlData:data];
    }
    
    static int cnt = 0;
    cnt++;
    if ((cnt % 4) == 3) {
        [bleSerialMangager sendRequestData:getDefaultOSDDataRequest()];
    }
    else if (cnt % 4 == 2){
        [bleSerialMangager sendRequestData:getSimpleCommand(MSP_BAT)];
    }
    
    
    [pool release];
}


- (BOOL)start{
    [self stop];
    
    [self initPackage];

    if (_osdData == nil) {
        _osdData = [[OSDData alloc] init];
        _osdData.delegate = self;
    }
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(transmmit) userInfo:nil repeats:YES] retain];

    return YES;
}

- (BOOL)stop{    
    [timer invalidate];
    [timer release];
    timer = nil;
    
    return YES;
}

- (void)setPpmValue:(float)value atChannel:(int)channelIdx{
    channelList[channelIdx] = value;
}

- (BOOL)isConnected{
    return  ((_outputState == TransmitterStateOk) && (_inputState == TransmitterStateOk));
}

- (BOOL)transmmitData:(NSData *)data{
    if ([bleSerialMangager isConnected] && data != nil) {
        
        NSMutableData *packageData = [NSMutableData data];
        
        for (int idx = 0; idx < 1; idx++) {
            [packageData appendData:data];
        }
        /*old version
        [bleSerialMangager sendControlData:packageData];
         */
        [bleSerialMangager sendRequestData:packageData];
        return YES;
    }
    else
        return NO;
}

- (BOOL)transmmitSimpleCommand:(unsigned char)commandName{
    return [self transmmitData:getSimpleCommand(commandName)];
}


//- (void)shakeHands{
//    [udpSocket sendData:[@"Hello Drone" dataUsingEncoding:NSUTF8StringEncoding] toHost:UDP_SERVER_HOST port:UDP_SERVER_PORT withTimeout:-1 tag:0];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	exit(0);
}

- (void)showBindToPortErrAlertView{
    NSString *msg = [NSString stringWithFormat:@"RC Touch can't bind to port %d. The port may be already used by another app.", UDP_SERVER_PORT];

    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Sorry" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//- (BOOL)setupSocket
//{
//    if(socketIsSetuped) 
//        return YES;
//    else{
//        if(udpSocket == nil)
//            udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self enableIPv6:NO];
//        NSError *error = nil;
//        
//        if (![udpSocket bindToPort:UDP_SERVER_PORT error:&error])
//        {
//            NSLog(@"Error binding: %@", error);
//            [self showBindToPortErrAlertView];
//            return NO;
//        }
//        
//        [udpSocket receiveWithTimeout:kInputTimeout tag:0];
//        
//        NSLog(@"UDP is Ready\r");
//        
//        socketIsSetuped = YES;
//        
//        return YES;
//    }
//}

- (void)osdDataDidUpdateOneFrame:(OSDData *)osdData{
    //在主线程中被调用
    [[[BasicInfoManager sharedManager] osdView] setNeedsDisplay];
}
//
//
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
//{
//    outputTimeoutCount = 0;
//    if (_outputState == TransmitterStateError) {
//        _outputState = TransmitterStateOk;
//        [self sendTransmitterStateDidChangeNotification];
//    }
//}
//
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
//{
//    if (outputTimeoutCount < kOutputAllowableContiniousTimeoutCount) {
//        outputTimeoutCount++;
//        
//        if (outputTimeoutCount == kOutputAllowableContiniousTimeoutCount) {
//            _outputState = TransmitterStateError;
//            [self sendTransmitterStateDidChangeNotification];
//        }
//    }
//    
//    NSLog(@"Did note send data, Err:%@", error);
//}
//
//- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
//     didReceiveData:(NSData *)data
//            withTag:(long)tag
//           fromHost:(NSString *)host
//               port:(UInt16)port
//{
//    //在主线程中被调用
//    
//	//NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *msg = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    
//    //NSLog(@"receive len:%d msg:%@", data.length,  msg);
//
//    if([host isEqualToString:@"192.168.0.1"]){
//        [_osdData parseRawData:data];
//    }
//
//    //[[BasicInfoManager sharedManager] debugTextView].text = [NSString stringWithFormat:@"%@%@", [[BasicInfoManager sharedManager] debugTextView].text, msg];
//    
//    [udpSocket receiveWithTimeout:kOutputTimeout tag:0];
//    
//    inputTimeoutCount = 0;
//    
//    if (_inputState == TransmitterStateError) {
//        _inputState = TransmitterStateOk;
//        [self sendTransmitterStateDidChangeNotification];
//    }
//    
//	return YES;
//}
//
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
//    [udpSocket receiveWithTimeout:kInputTimeout tag:0];
//    
//    if (inputTimeoutCount < kInputAllowableContiniousTimeoutCount ) {
//        inputTimeoutCount++;
//        
//        if (inputTimeoutCount == kInputAllowableContiniousTimeoutCount) {
//            _inputState = TransmitterStateError;
//            [self sendTransmitterStateDidChangeNotification];
//        }
//    }
//    
//    NSLog(@"Did note receive data, Err:%@", error);
//}

#pragma mark BleSerialManagerDelegate Methods

-(void)bleSerialManager:(BleSerialManager *)manager didUpdateState:(BOOL)isAvailable{
//    static BOOL isScanning;
//    
//    if (isAvailable) {
//        if (isScanning == NO) {
//            [manager scan];
//            isScanning = YES;
//        }
//    }
}

-(void)bleSerialManager:(BleSerialManager *)manager didDiscoverBleSerial:(CBPeripheral *)peripheral{
    NSLog(@"discover ble serial");
}

-(void)bleSerialManager:(BleSerialManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral{
    _outputState = TransmitterStateOk;
    _inputState = TransmitterStateOk;
    [self sendTransmitterStateDidChangeNotification];
}


-(void)bleSerialManager:(BleSerialManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral{
    _outputState = TransmitterStateError;
    _inputState = TransmitterStateError;
    [self sendTransmitterStateDidChangeNotification];
    
    NSLog(@"didFailToConnectPeripheral");
    
    [[[Transmitter sharedTransmitter] bleSerialManager] disconnect];
   // isTryingConnect = YES;
    [[[Transmitter sharedTransmitter] bleSerialManager] connect:peripheral];
}


//当BLE模块断电，或远离了通信距离，该方法会被调用
-(void)bleSerialManager:(BleSerialManager *)manager didDisconnectPeripheral:(CBPeripheral *)peripheral{
    _outputState = TransmitterStateError;
    _inputState = TransmitterStateError;
    
    NSLog(@"didDisconnectPeripheral");

    [self sendTransmitterStateDidChangeNotification];
}

-(void)bleSerialManagerDidFailSendData:(BleSerialManager *)manager error:(NSError *)error{
//    if (outputTimeoutCount < kOutputAllowableContiniousTimeoutCount) {
//        outputTimeoutCount++;
//        
//        if (outputTimeoutCount == kOutputAllowableContiniousTimeoutCount) {
//            _outputState = TransmitterStateError;
//            [self sendTransmitterStateDidChangeNotification];
//        }
//    }
    
    NSLog(@"fail send data***");
}

-(void)bleSerialManagerDidSendData:(BleSerialManager *)manager{
    outputTimeoutCount = 0;
    if (_outputState == TransmitterStateError) {
        _outputState = TransmitterStateOk;
        [self sendTransmitterStateDidChangeNotification];
    }
    NSLog(@"did send data***");
}

-(void)bleSerialManager:(BleSerialManager *)manager didReceiveData:(NSData *)data{
    [_osdData parseRawData:data];
}

#pragma mark BleSerialManagerDelegate Methods end

- (void)dealloc{
    [self stop];
    [_osdData  release];
    [super dealloc];
}

@end
