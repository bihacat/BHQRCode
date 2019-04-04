//
//  BHScanView.m
//  BHScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Bihacat. All rights reserved.
//

#import "BHScanView.h"

#define BH_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define BH_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSUInteger, LineMoveDirect) {
    LineMoveDirectUp,
    LineMoveDirectDown
};

@interface BHScanView ()

@property (nonatomic, assign) CGRect scanFrame;

@property (nonatomic, assign) LineMoveDirect lineDirection;

@end

@implementation BHScanView

- (instancetype)initWithScanFrame:(CGRect)scanFrame {
    if (self = [super initWithFrame:CGRectMake(0, 0, BH_SCREENWIDTH, BH_SCREENHEIGHT)]) {
        [self configCoverView];
        _scanFrame = scanFrame;
        [self resetCoverViewFrame];
        [self configScanUI];
        [self configTimer];
    }
    return self;
}

- (void)configTimer {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_MSEC, 0);
    
    __weak BHScanView *wkSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        CGRect lineFrame = wkSelf.scanLine.frame;
        if (wkSelf.timerState == BHTimerStateStop) {
            lineFrame.origin.y = wkSelf.scanFrame.origin.y;
        } else {
            switch (wkSelf.lineDirection) {
                case LineMoveDirectUp:
                    lineFrame.origin.y -= 1;
                    break;
                case LineMoveDirectDown:
                    lineFrame.origin.y += 1;
                    break;
            }
        }
        wkSelf.scanLine.frame = lineFrame;
        
        if (lineFrame.origin.y >= wkSelf.scanFrame.origin.y + wkSelf.scanFrame.size.width - lineFrame.size.height) {
            wkSelf.lineDirection = LineMoveDirectUp;
        } else if (lineFrame.origin.y <= wkSelf.scanFrame.origin.y) {
            wkSelf.lineDirection = LineMoveDirectDown;
        }
    });
    dispatch_resume(_timer);
}

- (void)configScanUI {
    
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"BHQrCode" ofType:@"bundle"];
    NSBundle *captureBundle = [NSBundle bundleWithPath:bundlePath];
    
    _scanImageView = [[UIImageView alloc] initWithFrame:_scanFrame];
    NSString *bgPath = [captureBundle pathForResource:@"scan_bg_pic@2x" ofType:@"png"];
    _scanImageView.image = [[UIImage alloc] initWithContentsOfFile:bgPath];
    [self addSubview:_scanImageView];
    
    _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(_scanFrame.origin.x, _scanFrame.origin.y, _scanFrame.size.width, 2)];
    NSString *linePath = [captureBundle pathForResource:@"scan_line@2x" ofType:@"png"];
    _scanLine.image = [[UIImage alloc] initWithContentsOfFile:linePath];
    [self addSubview:_scanLine];
    
    _introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scanFrame.origin.x, _scanFrame.origin.y+_scanFrame.size.height+20, _scanFrame.size.width, 40)];
    _introduceLabel.numberOfLines = 0;
    _introduceLabel.textAlignment = NSTextAlignmentCenter;
    _introduceLabel.text = @"将二维码/条码放入框内，即可自动扫描。";
    _introduceLabel.textColor = UIColor.whiteColor;
    _introduceLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_introduceLabel];
}

- (void)configCoverView {
    _topCoverView = [[UIView alloc] init];
    _leftCoverView = [[UIView alloc] init];
    _rightCoverView = [[UIView alloc] init];
    _bottomCoverView = [[UIView alloc] init];
    for (UIView *item in @[_topCoverView, _leftCoverView, _bottomCoverView, _rightCoverView]) {
        item.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:item];
    }
}

- (void)resetCoverViewFrame {
    _leftCoverView.frame = CGRectMake(0, 0, _scanFrame.origin.x, BH_SCREENHEIGHT);
    _topCoverView.frame = CGRectMake(_scanFrame.origin.x, 0, BH_SCREENWIDTH, _scanFrame.origin.y);
    _rightCoverView.frame = CGRectMake(_scanFrame.origin.x, _scanFrame.size.height+_scanFrame.origin.y, BH_SCREENWIDTH, BH_SCREENHEIGHT);
    _bottomCoverView.frame = CGRectMake(_scanFrame.size.width+_scanFrame.origin.x, _scanFrame.origin.y, BH_SCREENWIDTH, _scanFrame.size.height);
}

@end
