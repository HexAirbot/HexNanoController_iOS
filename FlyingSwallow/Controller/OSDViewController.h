//
//  OSDViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "VerticalScaleView.h"
#import "OSDData.h"

@interface OSDViewController : UIViewController{
    IBOutlet ArtificialHorizonView *artificalHorizonView;
    
}

@property(nonatomic, strong) OSDData *osdData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(OSDData *)osdData;

- (void)updateUI;
- (IBAction)switchOsdViewVisibleState:(id)sender;
- (void)setOsdViewVisibleState:(BOOL)visible;

@end
