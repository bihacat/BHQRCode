//
//  BHScanDevice.h
//  BHScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Bihacat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BHScanDevice : NSObject

/**
 扫码进程
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 扫码结果回调block
 */
@property (nonatomic, strong) void(^complete)(NSString *result);

/**
 初始化方法

 @param frame 扫码区域位置
 @param layer 屏幕显示的layer
 */
- (instancetype)initWithScanFrame:(CGRect)frame layer:(CALayer *)layer;

@end
