//
//  BasicInfo.h
//  EMagazine
//
//  Created by koupoo on 11-7-5.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>


@interface BasicInfoManager : NSObject {
}

@property (nonatomic, retain) UITextView *debugTextView;
@property (nonatomic, readonly)  CMMotionManager *motionManager;

@property (nonatomic, readonly) NSMutableString *debugStr;

@property (nonatomic) BOOL needsAltHoldMode;
@property (nonatomic, assign) BOOL isFullDuplex;


+ (id)sharedManager;



@end
