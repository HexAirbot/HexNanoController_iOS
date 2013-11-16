//
//  AppDelegate.h
//  FlyingSwallow
//
//  Created by koupoo on 12-12-23.
//  Copyright (c) 2012年 www.hexairbot.com. All rights reserved.

#import <UIKit/UIKit.h>

//可以设置tag，控制minLabel和maxLabel显示的数字的精度，如tag设置为2，当minimum的值为1时，则显示1.00
@interface FSSlider : UISlider 

@property(nonatomic, readonly) UILabel* minLabel;
@property(nonatomic, readonly) UILabel* maxLabel;


@end
