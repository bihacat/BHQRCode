//
//  BHScanTools.h
//  BHQrCode
//
//  Created by tian on 2019/4/4.
//  Copyright © 2019 bihacat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BHScanTools : NSObject

/**
 识别指定图片
 
 @param image 要被识别的图片
 */
+ (NSArray<NSString *> *)identify:(UIImage *)image;

/**
 生成指定大小的二维码图片
 
 @param string 要生成二维码的字符串
 @param width 大小
 @return 生成的二维码图片
 */
+ (UIImage *)generate:(NSString *)string width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
