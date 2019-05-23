//
//  BHScanController.h
//  BHScanController
//
//  Created by bihacat on 2017/6/9.
//  Copyright © 2017年 bihacat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHScanController : UIViewController

#pragma mark - 界面
/**
 扫码线图片
 */
@property (nonatomic, strong) UIImage *scanLineImage;

/**
 扫码框图片
 */
@property (nonatomic, strong) UIImage *scanImage;

/**
 扫码框和扫码线颜色
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 单独设置扫码框颜色
 */
@property (nonatomic, strong) UIColor *scanColor;

/**
 单独设置扫码线颜色
 */
@property (nonatomic, strong) UIColor *scanLineColor;

/**
 遮罩层透明度
 */
@property (nonatomic, assign) CGFloat coverViewAlpha;

#pragma mark - 文字
/**
 提示文字内容
 */
@property (nonatomic, copy) NSString *introduceText;

/**
 提示文字字体大小
 */
@property (nonatomic, assign) CGFloat introduceFontSize;

/**
 提示文字字体
 */
@property (nonatomic, strong) UIFont *introduceFont;

/**
 提示文字颜色
 */
@property (nonatomic, strong) UIColor *introduceTextColor;

/**
 提示文字对齐方式, 默认:居中
 */
@property (nonatomic, assign) NSTextAlignment introduceTextAlignment;

/**
 提示文字位置
 */
@property (nonatomic, assign) CGRect introduceFrame;

/**
 无拍照权限时提示的应用名，默认为当前应用名
 */
@property (nonatomic, copy) NSString *appName;

#pragma mark - 导航栏
/**
 导航栏文字、按钮颜色 默认白色
 */
@property (nonatomic, strong) UIColor *navigationTintColor;

/**
 导航栏透明度 默认为0 白色透明
 */
@property (nonatomic, assign) CGFloat navigationBarAlpha;

/**
 导航栏背景颜色 默认白色 修改是不要忘记修改navigationBarAlpha
 */
@property (nonatomic, strong) UIColor *navigationBarTintColor;

/**
 导航栏标题 默认为“二维码扫描”
 */
@property (nonatomic, copy) NSString *navigationTitleText;

/**
 是否显示相册按钮，默认为否
 */
@property (nonatomic, assign) BOOL showAlbum;

#pragma mark - 方法
/**
 初始化方法(默认扫码区宽高为屏幕宽度-100, 居中显示)
 
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanComplete:(void(^)(NSString *result, BHScanController *capture))complete;

/**
 初始化方法

 @param frame 扫码区域位置
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanFrame:(CGRect)frame complete:(void(^)(NSString *result, BHScanController *capture))complete;

- (void)start;
- (void)stop;

@end
