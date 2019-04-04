//
//  BHScanTools.m
//  BHQrCode
//
//  Created by tian on 2019/4/4.
//  Copyright © 2019 bihacat. All rights reserved.
//

#import "BHScanTools.h"

@implementation BHScanTools

// 识别图片
+ (NSArray<NSString *> *)identify:(UIImage *)image {
    BHScanTools *tools = [[BHScanTools alloc] init];
    return [tools detactImage:image];
}

- (NSArray<NSString *> *)detactImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:features.count];
    for (NSInteger i = 0; i < [features count]; i++) {
        CIQRCodeFeature *feature = [features objectAtIndex:i];
        NSString *scannedResult = feature.messageString;
        [results addObject:scannedResult];
    }
    return [NSArray arrayWithArray:results];
}

// 生成二维码图片
+ (UIImage *)generate:(NSString *)string width:(CGFloat)width {
    BHScanTools *tools = [[BHScanTools alloc] init];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:[string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:true] forKeyPath:@"inputMessage"];
    return [tools changeCIImage:filter.outputImage toUIImageWidth:width];
}

- (UIImage *)changeCIImage:(CIImage *)image toUIImageWidth:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
