//
//  OSDView.h
//  OSD
//
//  Created by koupoo on 13-3-13.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSDData.h"

@interface OSDView : UIView

- (id)initWithOsdData:(OSDData *)data;

@property(nonatomic, assign) float roll;
@property(nonatomic, assign) float pitch;

@property(nonatomic, retain) OSDData *osdData;

@end
