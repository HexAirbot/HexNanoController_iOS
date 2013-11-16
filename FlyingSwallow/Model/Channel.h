//
//  Channel.h
//  FlyingSwallow
//
//  Created by koupoo on 12-12-22.
//  Copyright (c) 2012年 www.hexairbot.com. All rights reserved.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License V2
//  as published by the Free Software Foundation.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
@class Settings;

#define kKeyChannelName @"Name"
#define kKeyChannelIsReversed @"IsReversed"
#define kKeyChannelTrimValue @"TrimValue"
#define kKeyChannelOutputAdjustableRange @"OutputAdjustableRange"
#define kKeyChannelDefaultOutputValue @"DefaultOutputValue"

#define kChannelNameAileron @"Aileron"
#define kChannelNameElevator @"Elevator"
#define kChannelNameRudder @"Rudder"
#define kChannelNameThrottle @"Throttle"
#define kChannelNameAUX1 @"AUX1"
#define kChannelNameAUX2 @"AUX2"
#define kChannelNameAUX3 @"AUX3"
#define kChannelNameAUX4 @"AUX4"



@interface Channel : NSObject{
   
}

@property(nonatomic, readonly) NSString *name;

//设置下面4个值后，都不会自动保存到持久化文件中

@property(nonatomic, assign) BOOL isReversing;
@property(nonatomic, assign) float trimValue;
@property(nonatomic, assign) float outputAdjustabledRange;
@property(nonatomic, assign) float defaultOutputValue;

@property(nonatomic, assign) float value;
@property(nonatomic, assign) int idx;
@property(nonatomic, assign) Settings *ownerSettings;


- (id)initWithSetting:(Settings *)settings idx:(int)idx;

@end
