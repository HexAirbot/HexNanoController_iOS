//
//  BasicInfo.m
//  EMagazine
//
//  Created by koupoo on 11-7-5.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import "BasicInfoManager.h"

static BasicInfoManager *sharedManager;

@implementation BasicInfoManager


@synthesize debugTextView;
@synthesize osdView;
@synthesize motionManager = _motionManager;
@synthesize debugStr = _debugStr;
@synthesize needsAltHoldMode = _needsAltHoldMode;

+ (id)sharedManager{
	if (sharedManager == nil) {
		sharedManager = [[super alloc] init];
        
		return sharedManager;
	}
	return sharedManager;
}

- (CMMotionManager *)motionManager{
    if (_motionManager == nil) {
        _motionManager =  [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

- (NSMutableString *)debugStr{
    if (_debugStr == nil) {
        _debugStr =  [[NSMutableString alloc] init];
    }
    return _debugStr;
}

- (void)dealloc{
	[debugTextView release];
    [osdView release];
    [_motionManager release];
    [_debugStr release];
	[super dealloc];
}

@end
