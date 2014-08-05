//
//  Channel.m
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

#import "Channel.h"
#import "Settings.h"
#import "Transmitter.h"
#import "util.h"

@interface Channel()

@property(nonatomic, strong) NSMutableDictionary *data;

@end


@implementation Channel
@synthesize data = _data;

@synthesize name = _name;
@synthesize isReversing = _isReversing;
@synthesize trimValue = _trimValue;
@synthesize outputAdjustabledRange = _outputAdjustabledRange;
@synthesize defaultOutputValue = _defaultOutputValue;
@synthesize value = _value;
@synthesize idx = _idx;
@synthesize ownerSettings = _ownerSettings;


- (id)initWithSetting:(Settings *)settings idx:(int)idx{
    self = [super init];
    
    if(self){
        _ownerSettings = settings;
        _idx = idx;
        
        _data = [[settings.settingsData valueForKey:kKeySettingsChannels] objectAtIndex:idx];
        
        _name = [_data valueForKey:kKeyChannelName];
        _isReversing = [[_data valueForKey:kKeyChannelIsReversed] boolValue];
        _trimValue = [[_data valueForKey:kKeyChannelTrimValue] floatValue];
        _outputAdjustabledRange = [[_data valueForKey:kKeyChannelOutputAdjustableRange] floatValue];
        _defaultOutputValue = [[_data valueForKey:kKeyChannelDefaultOutputValue] floatValue];
        
        [self setValue:_defaultOutputValue];
    }
    
    return self;
}

- (void)setValue:(float)value{
	_value = clip(value, -1.0, 1.0);
	float outputValue = clip(value + _trimValue, -1.0, 1.0); 
	if (_isReversing) {
		outputValue = -outputValue;
	}
    
	outputValue *= _outputAdjustabledRange;
    
    [[Transmitter sharedTransmitter] setPpmValue:outputValue atChannel:_idx];
}

- (void)setIsReversed:(BOOL)isReversing{
    _isReversing = isReversing;
    [_data setValue:[NSNumber numberWithBool:isReversing] forKey:kKeyChannelIsReversed];
}

- (void)setTrimValue:(float)trimValue{
    _trimValue = trimValue;
    [_data setValue:[NSNumber numberWithFloat:_trimValue] forKey:kKeyChannelTrimValue];
}

- (void)setOutputAdjustabledRange:(float)outputAdjustabledRange{
    _outputAdjustabledRange = outputAdjustabledRange;
    [_data setValue:[NSNumber numberWithFloat:_outputAdjustabledRange] forKey:kKeyChannelOutputAdjustableRange];
}

- (void)setDefaultOutputValue:(float)defaultOutputValue{
    _defaultOutputValue = defaultOutputValue;
    [_data setValue:[NSNumber numberWithFloat:_defaultOutputValue] forKey:kKeyChannelDefaultOutputValue];
}



@end
