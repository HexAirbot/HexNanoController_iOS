//
//  SettingsMenuViewController.h
//  FlyingSwallow
//
//  Created by koupoo on 12-12-21. Email: koupoo@126.com
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
#import "SettingsMenuViewController.h"
#import "FSSlider.h"
#import "Settings.h"
#import "ChannelSettingsViewController.h"

#define kNotificationDismissSettingsMenuView @"NotificationDissmissSettingsView"

@class SettingsMenuViewController;

@protocol SettingMenuViewControllerDelegate <NSObject>

- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl interfaceOpacityValueDidChange:(float)newValue;
- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl leftHandedValueDidChange:(BOOL)enabled;
- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl accModeValueDidChange:(BOOL)enabled;
- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl beginnerModeValueDidChange:(BOOL)enabled;
- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl headfreeModeValueDidChange:(BOOL)enabled;
- (void)settingsMenuViewController:(SettingsMenuViewController *)ctrl ppmPolarityReversed:(BOOL)enabled;

@end

enum SwitchButtonStatus{
    SWITCH_BUTTON_UNCHECKED = 0,
    SWITCH_BUTTON_CHECKED,
};

enum ChannelListTableViewSection {
    ChannelListTableViewSectionChannels = 0,
};


@interface SettingsMenuViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>{
    IBOutlet UILabel *pageTitleLabel;
    
    IBOutlet UIView *peripheralView;
    IBOutlet UIView *personalSettingsPageView;
    IBOutlet UIView *channelSetttingsPageView;
    IBOutlet UIView *modeSettingsPageView;
    IBOutlet UIView *aboutPageView;
    IBOutlet UIView *trimSettingsView;
    
    
    IBOutlet UIScrollView *settingsPageScrollView;
    
    IBOutlet UIButton *previousPageButton;
    IBOutlet UIButton *nextPageButton;
    
    IBOutlet UIButton *okButton;
    
    IBOutlet UIPageControl *pageControl;
    
    IBOutlet UILabel *leftHandedTitleLabel;
    IBOutlet UIButton *leftHandedSwitchButton;
    
    IBOutlet UILabel *accModeTitleLabel;
    IBOutlet UIButton *accModeSwitchButton;
    
    
    IBOutlet UILabel *interfaceOpacityTitleLabel;
    IBOutlet FSSlider *interfaceOpacitySlider;
    IBOutlet UILabel *interfaceOpacityLabel;
    
    IBOutlet UITableView *channelListTableView;
    
    IBOutlet UILabel *ppmPolarityReversedTitleLabel;
    IBOutlet UIButton *ppmPolarityReversedSwitchButton;
    
    IBOutlet UIButton *defaultSettingsButton;
    
    IBOutlet UILabel *takeOffThrottleTitleLabel;
    IBOutlet FSSlider *takeOffThrottleSlider;
    IBOutlet UILabel *takeOffThrottleLabel;
    
    IBOutlet UILabel *aileronElevatorDeadBandTitleLabel;
    IBOutlet FSSlider *aileronElevatorDeadBandSlider;
    IBOutlet UILabel *aileronElevatorDeadBandLabel;
    
    IBOutlet UILabel *rudderDeadBandTitleLabel;
    IBOutlet FSSlider *rudderDeadBandSlider;
    IBOutlet UILabel *rudderDeadBandLabel;
    IBOutlet UIWebView *aboutWebView;

    IBOutlet UITableView *peripheralListTableView;
    IBOutlet UIButton *peripheralListScanButton;
    
    IBOutlet UIActivityIndicatorView *connectionActivityIndicatorView;
    IBOutlet UILabel *connectionStateTextLabel;
    
    IBOutlet UILabel *isScanningTextLabel;

    IBOutlet UIButton *accCalibrateButton;
    IBOutlet UIButton *magCalibrateButton;
    
    
    IBOutlet UIButton *upTrimButton;
    IBOutlet UIButton *downTrimButton;
    IBOutlet UIButton *rightTrimButton;
    IBOutlet UIButton *leftTrimButton;
    
    IBOutlet UIButton *upFastTrimButton;
    
    IBOutlet UIButton *downFastTrimButton;
    
    IBOutlet UIButton *leftFastTrimButton;
    
    IBOutlet UIButton *rightFastTrimButton;
    
    IBOutlet UILabel *beginnerModeTitleLabel;
    IBOutlet UIButton *beginnerModeSwitchButton;
    
    IBOutlet UILabel *headfreeModeTitleLabel;
    IBOutlet UIButton *headfreeModeSwitchButton;
    
    IBOutlet FSSlider *param1Slider;
    IBOutlet FSSlider *param2Slider;
    IBOutlet FSSlider *param3Slider;
    IBOutlet FSSlider *param4Slider;
    IBOutlet FSSlider *param5Slider;
    IBOutlet FSSlider *param6Slider;
    IBOutlet FSSlider *param7Slider;
    IBOutlet FSSlider *param8Slider;
    IBOutlet FSSlider *param9Slider;
    IBOutlet FSSlider *param10Slider;
    IBOutlet FSSlider *param11Slider;
    IBOutlet FSSlider *param12Slider;
    
    IBOutlet UILabel *param1Label;
    IBOutlet UILabel *param2Label;
    IBOutlet UILabel *param3Label;
    IBOutlet UILabel *param4Label;
    IBOutlet UILabel *param5Label;
    IBOutlet UILabel *param6Label;
    
    IBOutlet UILabel *param7Label;
    IBOutlet UILabel *param8Label;
    IBOutlet UILabel *param9Label;
    IBOutlet UILabel *param10Label;
    IBOutlet UILabel *param11Label;
    IBOutlet UILabel *param12Label;
    
    IBOutlet UITextField *param1ScaleTextFiled;
    IBOutlet UITextField *param2ScaleTextFiled;
    IBOutlet UITextField *param3ScaleTextFiled;
    IBOutlet UITextField *param4ScaleTextFiled;
    IBOutlet UITextField *param5ScaleTextFiled;
    IBOutlet UITextField *param6ScaleTextFiled;
    IBOutlet UITextField *param7ScaleTextFiled;
    IBOutlet UITextField *param8ScaleTextFiled;
    IBOutlet UITextField *param9ScaleTextFiled;
    IBOutlet UITextField *param10ScaleTextFiled;
    IBOutlet UITextField *param11ScaleTextFiled;
    IBOutlet UITextField *param12ScaleTextFiled;
    
    IBOutlet UILabel *param1ValueLabel;
    IBOutlet UILabel *param2ValueLabel;
    IBOutlet UILabel *param3ValueLabel;
    IBOutlet UILabel *param4ValueLabel;
    IBOutlet UILabel *param5ValueLabel;
    IBOutlet UILabel *param6ValueLabel;
    IBOutlet UILabel *param7ValueLabel;
    IBOutlet UILabel *param8ValueLabel;
    IBOutlet UILabel *param9ValueLabel;
    IBOutlet UILabel *param10ValueLabel;
    IBOutlet UILabel *param11ValueLabel;
    IBOutlet UILabel *param12ValueLabel;
    
    IBOutlet UIView *testSettingsView;
    IBOutlet UIView *testSettingsView2;
}
@property(nonatomic, assign) NSObject<SettingMenuViewControllerDelegate> *delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil settings:(Settings *)settings;

- (IBAction)buttonClick:(id)sender;

- (IBAction)switchButtonClick:(id)sender;

- (IBAction)sliderRelease:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

- (IBAction)write:(id)sender;
- (IBAction)read:(id)sender;



@end



