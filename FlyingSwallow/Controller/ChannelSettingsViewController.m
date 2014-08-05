//
//  ChannelSettingsViewController.m
//  FlyingSwallow
//
//  Created by koupoo on 12-12-24.
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

#import "ChannelSettingsViewController.h"
#import "Macros.h"
#import "Settings.h"
#import "util.h"

@interface ChannelSettingsViewController ()

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

@implementation ChannelSettingsViewController
@synthesize channel = _channel;


- (void)updateIsReversedSwitchButton{
    [self setSwitchButton:isReversedSwitchButton withValue:_channel.isReversing];
}

- (void)updateTrimValueSlider{
    trimValueSlider.value = _channel.trimValue;
}

- (void)updateTrimValueLabel{
    trimValueLabel.text = [NSString stringWithFormat:@"%.2f", _channel.trimValue];
}

- (void)updateOutputAdjustableRangeSlider{
    outputAdjustableRangeSlider.value = _channel.outputAdjustabledRange;
}

- (void)updateOutputAdjustableRangeLabel{
    outputAdjustableRangeLabel.text = [NSString stringWithFormat:@"%.2f", _channel.outputAdjustabledRange];
}

- (void)updateoOtputPpmRangeLabel{
    int minOutputPpm = (int)(1500 + 500 * clip(-1 + _channel.trimValue, -1, 1) * _channel.outputAdjustabledRange);
    int maxOutputPpm = (int)(1500 + 500 * clip(1 + _channel.trimValue, -1, 1) * _channel.outputAdjustabledRange);
    
    outputPpmRangeLabel.text = [NSString stringWithFormat:@"%d~%dus", minOutputPpm, maxOutputPpm];
}

- (void)updateDefaultOutputValueLabel{
    float outputValue = clip(_channel.defaultOutputValue+ _channel.trimValue, -1.0, 1.0); 
    if (_channel.isReversing) {
        outputValue = -outputValue;
    }
    
    float defaultPpmValue = 1500 + 500 * (outputValue * _channel.outputAdjustabledRange);
    
    defaultOutputValueLabel.text = [NSString stringWithFormat:@"%.2f, %dus", _channel.defaultOutputValue, (int)defaultPpmValue];
}

- (void)updateDefaultOutputValueSlider{
    defaultOutputValueSlider.value = _channel.defaultOutputValue;
}

- (void)updateAllValueUI{
    [self updateIsReversedSwitchButton];
    [self updateTrimValueSlider];
    [self updateTrimValueLabel];
    [self updateOutputAdjustableRangeSlider];
    [self updateOutputAdjustableRangeLabel];
    [self updateoOtputPpmRangeLabel];
    [self updateDefaultOutputValueSlider];
    [self updateDefaultOutputValueLabel];
    
    if([_channel.name isEqualToString:kChannelNameAileron] 
       || [_channel.name isEqualToString:kChannelNameElevator]
       || [_channel.name isEqualToString:kChannelNameRudder]
       || [_channel.name isEqualToString:kChannelNameThrottle]){
        defaultOutputValueView.hidden = YES;
    }
    else{
        defaultOutputValueView.hidden = NO;
    }
}

- (void)udpateChannelSettingsTitleLabel{
    channelSettingsTitleLabel.text = _channel.name;
}

- (void)setChannel:(Channel *)channel{
    _channel = channel;
    [self updateAllValueUI];
    [self udpateChannelSettingsTitleLabel];
}

- (void)setSwitchButton:(UIButton *)switchButton withValue:(BOOL)active
{
    if (active)
    {
        switchButton.tag = 1;
        [switchButton setImage:[UIImage imageNamed:@"Btn_ON.png"] forState:UIControlStateNormal];
    }
    else
    {
        switchButton.tag = 0;
        [switchButton setImage:[UIImage imageNamed:@"Btn_OFF.png"] forState:UIControlStateNormal];
    }
}

- (void)toggleSwitchButton:(UIButton *)switchButton
{
    [self setSwitchButton:switchButton withValue:(0 == switchButton.tag) ? YES : NO];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil channel:(Channel *)channel{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isReversedTitleLabel.text            = getLocalizeString(@"IS REVERSING");
    trimValueTitleLabel.text             = getLocalizeString(@"TRIM VALUE");
    outputAdjustableRangeTitleLabel.text = getLocalizeString(@"OUTPUT ADJUSTABLE RANGE");
    outputPpmRangeTitleLabel.text        = getLocalizeString(@"OUTPUT PPM RANGE");
    defaultOuputValueTitleLabel.text     = getLocalizeString(@"DEFAULT OUTPUT VALUE");
    [defaultButton setTitle:getLocalizeString(@"Default") forState:UIControlStateNormal];
    
    [self updateAllValueUI];
    [self udpateChannelSettingsTitleLabel];
}

- (void)viewDidUnload
{
    channelSettingsTitleLabel = nil;
    isReversedTitleLabel = nil;
    trimValueTitleLabel = nil;
    outputAdjustableRangeTitleLabel = nil;
    outputPpmRangeTitleLabel = nil;
    defaultOuputValueTitleLabel = nil;
    isReversedSwitchButton = nil;
    trimValueSlider = nil;
    outputAdjustableRangeSlider = nil;
    outputPpmRangeLabel = nil;
    defaultOutputValueTextField = nil;
    dismissButton = nil;
    trimValueLabel = nil;
    outputAdjustableRangeLabel = nil;
    defaultOutputValueSlider = nil;
    defaultOutputValueLabel = nil;
    defaultOutputValueView = nil;
    defaultButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)resetToDefault{
    _channel.isReversing = NO;
    _channel.trimValue = 0;
    _channel.outputAdjustabledRange = 1;
    _channel.defaultOutputValue = 0;
    
    if([_channel.name isEqualToString:kChannelNameThrottle])
        _channel.value = 0;
    else
        _channel.value = 0;
    
    [_channel.ownerSettings save];
    
    [self updateAllValueUI];
}

- (IBAction)buttonClick:(id)sender {
    if(sender == dismissButton){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissChannelSettingsView object:self userInfo:nil];
    }
    else if(sender == defaultButton){
        [self resetToDefault];
    }
    else{
        ;
    }
}

- (IBAction)switchButtonClick:(id)sender {
    if(sender == isReversedSwitchButton){
        _channel.isReversing = isReversedSwitchButton.tag == 1 ? NO : YES;
        
        [_channel.ownerSettings save];
        
        [self updateIsReversedSwitchButton];
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    if(sender == trimValueSlider){    
        _channel.trimValue = trimValueSlider.value;
        [self updateTrimValueLabel];
        [self updateoOtputPpmRangeLabel];
        [self updateDefaultOutputValueLabel];
        _channel.value = _channel.defaultOutputValue;
    }
    else if(sender == outputAdjustableRangeSlider){
        _channel.outputAdjustabledRange = outputAdjustableRangeSlider.value;
        [self updateOutputAdjustableRangeLabel];
        [self updateoOtputPpmRangeLabel];
        [self updateDefaultOutputValueLabel];
        _channel.value = _channel.defaultOutputValue;
    }
    else if(sender == defaultOutputValueSlider){
        if(![_channel.name isEqualToString:kChannelNameAileron] 
           && ![_channel.name isEqualToString:kChannelNameElevator]
           && ![_channel.name isEqualToString:kChannelNameRudder]
           && ![_channel.name isEqualToString:kChannelNameThrottle]){
            _channel.defaultOutputValue = defaultOutputValueSlider.value;
            _channel.value = _channel.defaultOutputValue;
            [self updateDefaultOutputValueLabel];
        }
    }
    else{

    }
}

- (IBAction)sliderRelease:(id)sender {
    [_channel.ownerSettings save];
}

@end
