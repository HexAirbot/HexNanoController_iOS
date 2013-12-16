//
//  HelpViewController.h
//  RCTouch
//
//  Created by koupoo on 13-12-16.
//  Copyright (c) 2013年 www.angeleyes.it. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNotificationDismissHelpView @"NotificationDissmissHelpView"

@interface HelpViewController : UIViewController<UIScrollViewDelegate>{
    IBOutlet UILabel *pageTitleLabel;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *settingsPageScrollView;

    IBOutlet UIView *pageView01;
    IBOutlet UIView *pageView02;
    IBOutlet UIView *pageView03;
    IBOutlet UIView *pageView04;
    IBOutlet UIView *pageView05;
    IBOutlet UIButton *closeBtn;
}
- (IBAction)close:(id)sender;

@end
