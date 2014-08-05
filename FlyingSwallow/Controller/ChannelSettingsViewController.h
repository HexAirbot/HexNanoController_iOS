//
//  ChannelSettingsViewController.h
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

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "FSSlider.h"

#define kNotificationDismissChannelSettingsView @"NotificationDissmissChannelSettingsView"

@interface ChannelSettingsViewController : UIViewController{
    IBOutlet UILabel *channelSettingsTitleLabel;
    
    IBOutlet UILabel *isReversedTitleLabel;
    IBOutlet UILabel *trimValueTitleLabel;
    IBOutlet UILabel *outputAdjustableRangeTitleLabel;
    IBOutlet UILabel *outputPpmRangeTitleLabel;
    IBOutlet UILabel *defaultOuputValueTitleLabel;
    
    IBOutlet UIButton *isReversedSwitchButton;
    IBOutlet FSSlider *trimValueSlider;
    IBOutlet UILabel *trimValueLabel;
    IBOutlet FSSlider *outputAdjustableRangeSlider;
    IBOutlet UILabel *outputAdjustableRangeLabel;
    IBOutlet UILabel *outputPpmRangeLabel;
    IBOutlet UITextField *defaultOutputValueTextField;
    IBOutlet FSSlider *defaultOutputValueSlider;
    IBOutlet UILabel *defaultOutputValueLabel;
    
    IBOutlet UIView *defaultOutputValueView;
    IBOutlet UIButton *dismissButton;
    IBOutlet UIButton *defaultButton;
}

//当重新设置channel后，UI显示的内容会随之更新
@property(nonatomic, strong) Channel *channel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil channel:(Channel *)channel;

- (IBAction)buttonClick:(id)sender;
- (IBAction)switchButtonClick:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)sliderRelease:(id)sender;



@end
