//
//  HudViewController.h
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
#import "Channel.h"
#import "Settings.h"
#import "OSDView.h"

typedef enum{
	ViewBlockViewINVALID = 0,
    ViewBlockJoyStickHud,
    ViewBlockJoyStickHud2,
	ViewBlockViewMAX
}HudViewBlockView;

float accelero_rotation[3][3];

@interface HudViewController : UIViewController<SettingMenuViewControllerDelegate>{
    IBOutlet UILabel *batteryLevelLabel;
    
    IBOutlet UIImageView *batteryImageView;

    IBOutlet UIButton *setttingButton;
    IBOutlet UIButton *joystickLeftButton;
    IBOutlet UIButton *joystickRightButton;
    
    IBOutlet UIImageView *joystickLeftThumbImageView;
    IBOutlet UIImageView *joystickLeftBackgroundImageView;
    IBOutlet UIImageView *joystickRightThumbImageView;
    IBOutlet UIImageView *joystickRightBackgroundImageView;
    
    IBOutlet UIView *warningView;    
    IBOutlet UILabel *warningLabel;
    IBOutlet UILabel *statusInfoLabel;
    IBOutlet UILabel *throttleValueLabel;
    IBOutlet UIButton *rudderLockButton;
    
    IBOutlet UIButton *throttleUpButton;
    IBOutlet UIButton *throttleDownButton;
    IBOutlet UIImageView *downIndicatorImageView;
    IBOutlet UIImageView *upIndicatorImageView;
    
    IBOutlet OSDView *osdView;
    
    
    IBOutlet UILabel *rollValueTextLabel;
    IBOutlet UILabel *pitchValueTextLabel;
    IBOutlet UILabel *altValueTextLabel;
    IBOutlet UILabel *headAngleValueTextLabel;
    
    IBOutlet UIButton *altHoldSwitchButton;
    
    IBOutlet UIButton *helpButton;
    
}
@property (retain, nonatomic) IBOutlet UITextView *debugTextView;
- (IBAction)switchButtonClick:(id)sender;

- (IBAction)joystickButtonDidTouchDown:(id)sender forEvent:(UIEvent *)event;
- (IBAction)josystickButtonDidTouchUp:(id)sender forEvent:(UIEvent *)event;
- (IBAction)joystickButtonDidDrag:(id)sender forEvent:(UIEvent *)event;

- (IBAction)takoffButtonDidTouchDown:(id)sender;
- (IBAction)takeoffButtonDidTouchUp:(id)sender;

- (IBAction)throttleStopButtonDidTouchDown:(id)sender;
- (IBAction)throttleStopButtonDidTouchUp:(id)sender;

- (IBAction)buttonDidTouchDown:(id)sender;
- (IBAction)buttonDidDragEnter:(id)sender;
- (IBAction)buttonDidDragExit:(id)sender;
- (IBAction)buttonDidTouchUpInside:(id)sender;
- (IBAction)buttonDidTouchUpOutside:(id)sender;
- (IBAction)buttonDidTouchCancel:(id)sender;

- (IBAction)unlockButtonDidTouchUp:(id)sender;
- (IBAction)lockButtonDidTouchUp:(id)sender;


@end
