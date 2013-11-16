//
//  OSDView.m
//  OSD
//
//  Created by koupoo on 13-3-13.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "OSDView.h"

#define kAltitudeTraceLen                0.8
#define kAltitudeTraceX                  0.85
#define kAltitudeTraceY                  0.1
#define kAltitudeTraceRange              35      //以分米为单位
#define kAltitudeTraceInterval           5
#define kAltitudeTraceTicksPerInterval   5
#define kAltitudeTraceIntervalMarkLen    10
#define kAltitudeTraceTickMarkLen        5

#define kOrientationTraceLen                0.96
#define kOrientationTraceX                  0.02
#define kOrientationTraceY                  0.98
#define kOrientationTraceRange              120      //以度为单位
#define kOrientationTraceInterval           15
#define kOrientationTraceTicksPerInterval   15
#define kOrientationTraceNeesDrawTicks      FALSE
#define kOrientationTraceIntervalMarkLen    6
#define kOrientationTraceTickMarkLen        5


#define kAttitudeTraceLen                0.6
#define kAttitudeTraceX                  0.5
#define kAttitudeTraceRange              50      //以度为单位
#define kAttitudeTraceInterval           5
#define kAttitudeTraceTicksPerInterval   5
#define kAttitudeTraceNeesDrawTicks      FALSE
#define kAttitudeTraceIntervalMarkLen    120
#define kAttitudeTraceTickMarkLen        10

#define kDroneWidth 0.2


#define kWorldRefreshFreq  5


@interface OSDView(){
    CGContextRef context;
    UIImage *worldImage;
    UIImage *droneImage;
}
@end


@implementation OSDView

@synthesize roll = _roll;
@synthesize pitch = _pitch;
@synthesize osdData = _osdData;

- (void)setupImages{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"world.jpg" ofType:nil];
    worldImage = [[UIImage imageWithContentsOfFile:imagePath] retain];
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"drone.png" ofType:nil];
    droneImage = [[UIImage imageWithContentsOfFile:imagePath] retain];
}


- (id)initWithOsdData:(OSDData *)data{
    if(self = [super init]){
        _osdData = [data retain];
        [self setupImages];
    }
    return self;
}
 
- (void)setOsdData:(OSDData *)osdData{
    [_osdData release];
    _osdData = [osdData retain];
    
    [self setNeedsDisplay];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupImages];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)update{
    [self setNeedsDisplay];
}


//roll的值为[-180，180],负值为飞行器往左翻滚，正值为飞行器往右翻滚；pitch的值为[-180，180],负值为头往下翻滚，正值为头往上翻滚；
- (void)drawWorldWithRoll:(float)roll pitch:(float)pitch{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"world.jpg" ofType:nil];
    UIImage *uiImage = [UIImage imageWithContentsOfFile:imagePath];
    CGImageRef image = uiImage.CGImage;
    
    CGRect imageRect;
	imageRect.size = CGSizeMake(uiImage.size.width * 3, uiImage.size.height * 3);
    
    imageRect.origin = CGPointMake((self.frame.size.width - imageRect.size.width) / 2.0, (self.frame.size.height- imageRect.size.height) / 2.0);
    
    CGContextSaveGState(context);
    
    CGContextScaleCTM(context, 1.0, -1.0);//2
    CGContextTranslateCTM(context, 0, -self.frame.size.height);//4
    
    
    float lenPerPitchDegree = kAttitudeTraceLen * self.frame.size.height / 50.0;
    
    if(pitch > 90){
        imageRect.origin.y -= lenPerPitchDegree * (90 - (pitch - 90));
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * (90 - (pitch - 90))) ;
        
        float refinedRoll;
        
        if (roll > 0) {
            refinedRoll = 180 - roll;
        }
        else{
            refinedRoll = -180 - roll;
        }
        
        CGContextRotateCTM(context, refinedRoll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * (90 - (pitch - 90))));
        
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
    }
    else if(pitch < -90){
        //  imageRect.origin.y -= lenPerPitchDegree * pitch;
        
        imageRect.origin.y -= lenPerPitchDegree * (-90 - (pitch - (-90)));
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * (-90 - (pitch - (-90)))) ;
        
        
        float refinedRoll;
        
        if (roll > 0) {
            refinedRoll = 180 - roll;
        }
        else{
            refinedRoll = -180 - roll;
        }
        
        CGContextRotateCTM(context, refinedRoll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * (-90 - (pitch - (-90)))));
        
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
    }
    else {
        imageRect.origin.y -= lenPerPitchDegree * pitch;
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * pitch) ;
        CGContextRotateCTM(context, roll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * pitch));
        
    }
    
    
    
    CGContextDrawImage(context, imageRect, image);  //将图片画到context中，如果需要需要缩放，会自动缩放，imageRect用于定义在context中的哪个地方画image
    
    CGContextRestoreGState(context);
}

//roll的值为[-180，180],负值为飞行器往左翻滚，正值为飞行器往右翻滚；pitch的值为[-180，180],负值为头往下翻滚，正值为头往上翻滚；
- (void)drawWorldWithRoll2:(float)roll pitch:(float)pitch{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"world.jpg" ofType:nil];
    UIImage *uiImage = [UIImage imageWithContentsOfFile:imagePath];
    CGImageRef image = uiImage.CGImage;
    
    CGRect imageRect;
	imageRect.size = CGSizeMake(uiImage.size.width * 2.2, uiImage.size.height * 2.2);
    
    imageRect.origin = CGPointMake((self.frame.size.width - imageRect.size.width) / 2.0, (self.frame.size.height- imageRect.size.height) / 2.0);
    
    CGContextSaveGState(context);
    
    CGContextScaleCTM(context, 1.0, -1.0);//2
    CGContextTranslateCTM(context, 0, -self.frame.size.height);//4
    
    
    float lenPerPitchDegree = kAttitudeTraceLen * self.frame.size.height / 50.0;
    
    if(pitch > 90){
        imageRect.origin.y -= lenPerPitchDegree * (90 - (pitch - 90));
        
//        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
//        CGContextRotateCTM(context, M_PI);
//        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * (90 - (pitch - 90))) ;
        
        
        CGContextRotateCTM(context, (180 - roll) / 180.0 * M_PI);
        
        
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * (90 - (pitch - 90))));
    }
    else if(pitch < -90){
        //  imageRect.origin.y -= lenPerPitchDegree * pitch;
        
        imageRect.origin.y -= lenPerPitchDegree * (-90 - (pitch - (-90)));
        
//        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
//        CGContextRotateCTM(context, M_PI);
//        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * (-90 - (pitch - (-90))));
        CGContextRotateCTM(context, roll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * (-90 - (pitch - (-90)))));
    }
    else {
        imageRect.origin.y -= lenPerPitchDegree * pitch;
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0 - lenPerPitchDegree * pitch) ;
        CGContextRotateCTM(context, roll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -(self.frame.size.height / 2.0 - lenPerPitchDegree * pitch));
        
    }
    
    CGContextDrawImage(context, imageRect, image);  //将图片画到context中，如果需要需要缩放，会自动缩放，imageRect用于定义在context中的哪个地方画image
    
    CGContextRestoreGState(context);
}

//roll的值为[-180，180],负值为飞行器往左翻滚，正值为飞行器往右翻滚；pitch的值为[-180，180],负值为头往下翻滚，正值为头往上翻滚；
- (void)drawAttitudeTraceWithRoll:(float)roll picth:(float)pitch{
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
    
    CGContextSaveGState(context);
    

    
    int traceMiddleValue, traceStartValue, traceEndValue, tickStepValue;
    
    if(pitch > 90){
        if(fabsf(180 - pitch) < 1e-4){
            traceMiddleValue = 0;
        }
        else {
            traceMiddleValue = 90 - (int)pitch % 90;
        }
        
        float refinedRoll;
        
        if (roll > 0) {
            refinedRoll = 180 - roll;
        }
        else{
            refinedRoll = -180 - roll;
        }
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0);
        CGContextRotateCTM(context, -refinedRoll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0 );
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
        
    }
    else if(pitch < -90){
        if(fabsf(180 + pitch) < 1e-4){
            traceMiddleValue = 0;
        }
        else{
            traceMiddleValue = -90 - (int)pitch % 90;
        }
        
        float refinedRoll;
        
        if (roll > 0) {
            refinedRoll = 180 - roll;
        }
        else{
            refinedRoll = -180 - roll;
        }
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0);
        CGContextRotateCTM(context, -refinedRoll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0 );
        
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
    }
    else{
        traceMiddleValue = pitch; 
    
        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0);
        CGContextRotateCTM(context, - roll / 180.0 * M_PI);
        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0 );
        
//        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
//        CGContextRotateCTM(context, M_PI);
//        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
    }
    
    traceStartValue = MIN(90, traceMiddleValue + (int)(kAttitudeTraceRange / 2));
    traceEndValue = MAX(-90, traceMiddleValue - (int)(kAttitudeTraceRange / 2));
    
    tickStepValue = (int)(kAttitudeTraceInterval / kAttitudeTraceTicksPerInterval);
    
    CGPoint traceStartPos = CGPointMake(self.frame.size.width * kAttitudeTraceX,  self.frame.size.height / 2.0 -  self.frame.size.height * kAttitudeTraceLen / 2.0);
    CGPoint traceEndPos = CGPointMake(traceStartPos.x, traceStartPos.y + self.frame.size.height * kAttitudeTraceLen);
    
    CGContextMoveToPoint(context, traceStartPos.x, traceStartPos.y);
    //CGContextAddLineToPoint(context, traceEndPos.x, traceEndPos.y);
    
    CGPoint tickStartPos,tickEndPos;
    
    float tickLen =  (kAttitudeTraceInterval / (float)kAttitudeTraceTicksPerInterval / (float)kAttitudeTraceRange) * (self.frame.size.height * kAttitudeTraceLen);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Some initial setup for our text drawing needs.
    // First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
    // This is an 8-bit encoding that can reference standard ASCII characters
    // and many common characters used in the Americas and Western Europe.
    CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
    // Next we set the text matrix to flip our text upside down. We do this because the context itself
    // is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    // And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    float yOffset = (kAttitudeTraceRange / 2.0 - (traceStartValue - traceMiddleValue)) / (float)kAttitudeTraceRange * self.frame.size.height * kAttitudeTraceLen;
    
    for(int traceValue = traceStartValue, tickIdx = 0; traceValue >= traceEndValue; traceValue -= tickStepValue){
        
        if(traceValue % (kAttitudeTraceTicksPerInterval * 2) == 0){  //大的刻度
            tickStartPos = CGPointMake(traceStartPos.x - kAttitudeTraceIntervalMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
            tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceIntervalMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
            NSString *traceValueStr = [NSString stringWithFormat:@"%d", traceValue];
            CGPoint traceValueStrPos = CGPointMake(tickEndPos.x + 5, tickEndPos.y + 4);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
            
            traceValueStrPos = CGPointMake(tickStartPos.x - 25, tickEndPos.y + 4);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
        }
        else if(traceValue % kAttitudeTraceTicksPerInterval == 0){
            tickStartPos = CGPointMake(traceStartPos.x - kAttitudeTraceIntervalMarkLen / 3, (traceStartPos.y + yOffset + tickIdx * tickLen));
            tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceIntervalMarkLen / 3, (traceStartPos.y + yOffset + tickIdx * tickLen));
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
        }
        else{//小刻度
            if(kOrientationTraceNeesDrawTicks){
                tickStartPos = CGPointMake(traceStartPos.x -  kAttitudeTraceTickMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
                tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceTickMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
                
                CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
                CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
            }
        }
        
        tickIdx++;
    }
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

//roll的值为[-180，180],负值为飞行器往左翻滚，正值为飞行器往右翻滚；pitch的值为[-180，180],负值为头往下翻滚，正值为头往上翻滚；
- (void)drawAttitudeTraceWithRoll2:(float)roll picth:(float)pitch{
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
    
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0);
    CGContextRotateCTM(context, - roll / 180.0 * M_PI);
    CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0 );
    
    int traceMiddleValue, traceStartValue, traceEndValue, tickStepValue;
    
    if(pitch > 90){
        if(fabsf(180 - pitch) < 1e-4){
            traceMiddleValue = 0;
        }
        else {
            traceMiddleValue = 90 - (int)pitch % 90;
        }
    }
    else if(pitch < -90){
        if(fabsf(180 + pitch) < 1e-4){
            traceMiddleValue = 0;
        }
        else{
            traceMiddleValue = -90 - (int)pitch % 90;
        }
    }
    else{
        traceMiddleValue = pitch; 
    }
    
//    if (pitch > 90 || pitch < -90) {
//        CGContextTranslateCTM(context,self.frame.size.width / 2.0 , self.frame.size.height / 2.0) ;
//        CGContextRotateCTM(context, M_PI);
//        CGContextTranslateCTM(context, -self.frame.size.width / 2.0, -self.frame.size.height / 2.0);
//    }
    
    traceStartValue = MIN(90, traceMiddleValue + (int)(kAttitudeTraceRange / 2));
    traceEndValue = MAX(-90, traceMiddleValue - (int)(kAttitudeTraceRange / 2));
    
    tickStepValue = (int)(kAttitudeTraceInterval / kAttitudeTraceTicksPerInterval);
    
    CGPoint traceStartPos = CGPointMake(self.frame.size.width * kAttitudeTraceX,  self.frame.size.height / 2.0 -  self.frame.size.height * kAttitudeTraceLen / 2.0);
    CGPoint traceEndPos = CGPointMake(traceStartPos.x, traceStartPos.y + self.frame.size.height * kAttitudeTraceLen);
    
    CGContextMoveToPoint(context, traceStartPos.x, traceStartPos.y);
    CGContextAddLineToPoint(context, traceEndPos.x, traceEndPos.y);
    
    CGPoint tickStartPos,tickEndPos;
    
    float tickLen =  (kAttitudeTraceInterval / (float)kAttitudeTraceTicksPerInterval / (float)kAttitudeTraceRange) * (self.frame.size.height * kAttitudeTraceLen);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Some initial setup for our text drawing needs.
    // First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
    // This is an 8-bit encoding that can reference standard ASCII characters
    // and many common characters used in the Americas and Western Europe.
    CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
    // Next we set the text matrix to flip our text upside down. We do this because the context itself
    // is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    // And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    float yOffset = (kAttitudeTraceRange / 2.0 - (traceStartValue - traceMiddleValue)) / (float)kAttitudeTraceRange * self.frame.size.height * kAttitudeTraceLen;
    
    for(int traceValue = traceStartValue, tickIdx = 0; traceValue >= traceEndValue; traceValue -= tickStepValue){
        
        if(traceValue % (kAttitudeTraceTicksPerInterval * 2) == 0){  //大的刻度
            tickStartPos = CGPointMake(traceStartPos.x - kAttitudeTraceIntervalMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
            tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceIntervalMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
            NSString *traceValueStr = [NSString stringWithFormat:@"%d", traceValue];
            CGPoint traceValueStrPos = CGPointMake(tickEndPos.x + 5, tickEndPos.y + 4);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
            
            traceValueStrPos = CGPointMake(tickStartPos.x - 25, tickEndPos.y + 4);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
        }
        else if(traceValue % kAttitudeTraceTicksPerInterval == 0){
            tickStartPos = CGPointMake(traceStartPos.x - kAttitudeTraceIntervalMarkLen / 3, (traceStartPos.y + yOffset + tickIdx * tickLen));
            tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceIntervalMarkLen / 3, (traceStartPos.y + yOffset + tickIdx * tickLen));
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
        }
        else{//小刻度
            if(kOrientationTraceNeesDrawTicks){
                tickStartPos = CGPointMake(traceStartPos.x -  kAttitudeTraceTickMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
                tickEndPos = CGPointMake(traceStartPos.x + kAttitudeTraceTickMarkLen / 2, (traceStartPos.y + yOffset + tickIdx * tickLen));
                
                CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
                CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
            }
        }
        
        tickIdx++;
    }
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}


- (void)drawAltitudeTrace:(float)altitude{
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Some initial setup for our text drawing needs.
    // First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
    // This is an 8-bit encoding that can reference standard ASCII characters
    // and many common characters used in the Americas and Western Europe.
    CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
    // Next we set the text matrix to flip our text upside down. We do this because the context itself
    // is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    // And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    
    CGPoint traceStartPos = CGPointMake(self.frame.size.width * kAltitudeTraceX, self.frame.size.height * kAltitudeTraceY);
    CGPoint traceEndPos = CGPointMake(traceStartPos.x, traceStartPos.y + self.frame.size.height * kAltitudeTraceLen);
    
    CGContextShowTextAtPoint(context, traceStartPos.x, traceStartPos.y - 5, "m", 1);
    
    
    CGPoint middlePoint = CGPointMake(traceStartPos.x, traceStartPos.y + (traceEndPos.y - traceStartPos.y) / 2.0);
    NSString *altitudeValueStr = [NSString stringWithFormat:@"%.1f", altitude / 10.0];
    CGContextShowTextAtPoint(context, middlePoint.x -30, middlePoint.y + 2,[altitudeValueStr cString], altitudeValueStr.length);
    
    
    CGContextMoveToPoint(context, traceStartPos.x, traceStartPos.y);
    CGContextAddLineToPoint(context, traceEndPos.x, traceEndPos.y);
    
    int traceMiddleValue = (int)(altitude * 10); //+ rand() % 10;
    int traceStartValue = traceMiddleValue + (int)(kAltitudeTraceRange / 2);  
    int traceEndValue = traceMiddleValue - (int)(kAltitudeTraceRange / 2);
    
    int tickStepValue = (int)(kAltitudeTraceInterval / kAltitudeTraceTicksPerInterval);
    
    CGPoint tickStartPos,tickEndPos;
    
    
    float tickLen =  (kAltitudeTraceInterval / (float)kAltitudeTraceTicksPerInterval / (float)kAltitudeTraceRange) * (self.frame.size.height * kAltitudeTraceLen);

    
    for(int traceValue = traceStartValue - tickStepValue, tickIdx = 1; traceValue >= traceEndValue; traceValue -= tickStepValue){
        tickStartPos = CGPointMake(traceStartPos.x, (traceStartPos.y + tickIdx * tickLen));
        
        if(traceValue % kAltitudeTraceTicksPerInterval == 0){  //大的刻度
            tickEndPos = CGPointMake(traceStartPos.x + kAltitudeTraceIntervalMarkLen, (traceStartPos.y + tickIdx * tickLen));
            NSString *traceValueStr = [NSString stringWithFormat:@"%.1f", traceValue / 10.0];
            CGPoint traceValueStrPos = CGPointMake(tickEndPos.x + 5, tickEndPos.y + 4);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
        }
        else{//小刻度
            tickEndPos = CGPointMake(traceStartPos.x + kAltitudeTraceTickMarkLen, (traceStartPos.y + tickIdx * tickLen));
        }
        
        CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
        CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
        
        tickIdx++;
    }
    
    CGContextStrokePath(context);
}

- (void)drawDrone{
    CGImageRef image = droneImage.CGImage;
    
    CGRect imageRect;
	imageRect.size = CGSizeMake(self.frame.size.width * kDroneWidth, droneImage.size.height / droneImage.size.width * self.frame.size.width * kDroneWidth);
    imageRect.origin = CGPointMake(self.frame.size.width / 2.0 - imageRect.size.width / 2.0, self.frame.size.height / 2.0 - imageRect.size.height);
    
    CGContextSaveGState(context);
    
    CGContextScaleCTM(context, 1.0, -1.0);//2
    CGContextTranslateCTM(context, 0, -self.frame.size.height);//4
    
    CGContextDrawImage(context, imageRect, image);  //将图片画到context中，如果需要需要缩放，会自动缩放，imageRect用于定义在context中的哪个地方画image
    
    CGContextRestoreGState(context);
}

//orientation的值范围[0, 360]
- (void)drawOrientationTrace:(float)orientation{
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
    
    CGPoint traceStartPos = CGPointMake(self.frame.size.width * kOrientationTraceX, self.frame.size.height * kOrientationTraceY);
    CGPoint traceEndPos = CGPointMake(traceStartPos.x+ self.frame.size.width * kOrientationTraceLen, traceStartPos.y);
    
    CGContextMoveToPoint(context, traceStartPos.x, traceStartPos.y);
    CGContextAddLineToPoint(context, traceEndPos.x, traceEndPos.y);
    
    int traceMiddleValue = (int)(orientation) + rand() % 30; 
    int traceStartValue = traceMiddleValue - (int)(kOrientationTraceRange / 2);  
    int traceEndValue = traceMiddleValue + (int)(kOrientationTraceRange / 2);
    
    int tickStepValue = (int)(kOrientationTraceInterval / kOrientationTraceTicksPerInterval);
    
    CGPoint tickStartPos,tickEndPos;
    
    float tickLen = (kOrientationTraceInterval / (float)kOrientationTraceTicksPerInterval / (float)kOrientationTraceRange) * (self.frame.size.width * kOrientationTraceLen);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    // Some initial setup for our text drawing needs.
    // First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
    // This is an 8-bit encoding that can reference standard ASCII characters
    // and many common characters used in the Americas and Western Europe.
    CGContextSelectFont(context, "Helvetica", 13.0, kCGEncodingMacRoman);
    // Next we set the text matrix to flip our text upside down. We do this because the context itself
    // is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    // And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    for(int traceValue = traceStartValue, tickIdx = 0; traceValue <= traceEndValue; traceValue += tickStepValue, tickIdx++){
        tickStartPos = CGPointMake(traceStartPos.x  + tickIdx * tickLen, traceStartPos.y);
        
        if(traceValue % kOrientationTraceTicksPerInterval == 0){  //大的刻度
            tickEndPos = CGPointMake(traceStartPos.x + tickIdx * tickLen, traceStartPos.y -  kOrientationTraceIntervalMarkLen);
            NSString *traceValueStr = [NSString stringWithFormat:@"%d", traceValue % 360];
            
            
            switch (traceValue % 360) {
                case 0:
                    traceValueStr = @"N";
                    break;
                case 45:
                    traceValueStr = @"NE";
                    break;
                case 90:
                    traceValueStr = @"E";
                    break;
                case 125:
                    traceValueStr = @"SE";
                    break;
                case 180:
                    traceValueStr = @"S";
                    break;
                case 225:
                    traceValueStr = @"SW";
                    break;
                case 270:
                    traceValueStr = @"W";
                    break;
                case 315:
                    traceValueStr = @"NW";
                    break;
                    
                default:
                    break;
            }
            
            CGPoint traceValueStrPos = CGPointMake(tickEndPos.x - 4, tickEndPos.y - 2);
            CGContextShowTextAtPoint(context, traceValueStrPos.x, traceValueStrPos.y,[traceValueStr cString], traceValueStr.length);
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y); 
            
            CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
            CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y); 
        }
        else{//小刻度
            if(kOrientationTraceNeesDrawTicks){
                tickEndPos = CGPointMake(traceStartPos.x + tickIdx * tickLen, traceStartPos.y -  kOrientationTraceTickMarkLen);
                CGContextMoveToPoint(context, tickStartPos.x, tickStartPos.y);
                CGContextAddLineToPoint(context, tickEndPos.x, tickEndPos.y);
            }
        }
        
        
    }
    
    CGContextStrokePath(context);
}


- (void)drawSpeedTrace:(float)speed{
    
}


-(void)drawRect:(CGRect)rect{
    context= UIGraphicsGetCurrentContext();
    
    float roll = 10 - rand()% 20;
    float pitch = 10 - rand()% 20;
    
    roll = 0;
    pitch =40;
    
//    [self drawWorldWithRoll:_roll pitch:_pitch];
//    [self drawAttitudeTraceWithRoll:_roll picth:_pitch];
    
    NSLog(@"***Roll:%f, ***Pitch:%f ***Alt:%f",_osdData.angleX, -_osdData.angleY, -_osdData.altitude);
    
    
    [self drawWorldWithRoll:_osdData.angleX pitch:-_osdData.angleY];
    [self drawAttitudeTraceWithRoll:_osdData.angleX picth:-_osdData.angleY];
    
    
//    static BOOL needsRefresh = TRUE;
//
//    if(needsRefresh){
        [self drawAltitudeTrace:_osdData.altitude];
        
        if (_osdData.head < 0) {
            [self drawOrientationTrace:360 + _osdData.head];
        }
        else {
            [self drawOrientationTrace:_osdData.head];
        }
//        
//        
//    }
//    
//    needsRefresh = !needsRefresh;
    
    [self drawDrone];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (void)dealloc{
    [_osdData release];
    [worldImage release];
    [droneImage release];
    [super dealloc];
}

@end
