//
//  BHScanController.m
//  BHScanController
//
//  Created by bihacat on 2017/6/9.
//  Copyright © 2017年 bihacat. All rights reserved.
//

#import "BHScanController.h"
#import "BHScanView.h"
#import "BHScanDevice.h"
#import "TZImagePickerController.h"
#import <CoreImage/CoreImage.h>

#define BH_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define BH_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCANPADDING 50

@interface BHScanController () <TZImagePickerControllerDelegate>

@property (nonatomic, assign) CGRect scanFrame;
@property (nonatomic, strong) BHScanDevice *device;
@property (nonatomic, strong) BHScanView *scanView;
@property (nonatomic, copy) void(^scanCompleteBlock)(NSString *result);
@property (nonatomic, strong) void(^outCompleteBlock)(NSString *result, BHScanController *capture);
@property (nonatomic, strong) UINavigationBar *navigationBar;
/// 记录进入该控制器前的导航栏状态
@property (nonatomic, strong) NSDictionary *originalTitleTextAttributes;
@property (nonatomic, strong) UIColor *originalTintColor;
@property (nonatomic, strong) UIImage *originalShadowImage;
@property (nonatomic, strong) UIImage *originalBackgroundImage; //


@end

@implementation BHScanController

// MARK: - 初始化方法
- (instancetype)initWithScanComplete:(void (^)(NSString *, BHScanController *))complete {
    
    if (self = [super init]) {
        
        [self configInitValue];
        _outCompleteBlock = complete;
        CGFloat width = BH_SCREENWIDTH - SCANPADDING*2;
        _scanFrame = CGRectMake((BH_SCREENWIDTH-width)/2,
                                (BH_SCREENHEIGHT-width)/2,
                                width,
                                width);
        _scanView = [[BHScanView alloc] initWithScanFrame:_scanFrame];
        __weak BHScanController *wkSelf = self;
        _scanCompleteBlock = ^(NSString *result) {
            wkSelf.scanView.timerState = BHTimerStateStop;
            wkSelf.outCompleteBlock(result, wkSelf);
        };
    }
    return self;
}

- (instancetype)initWithScanFrame:(CGRect)frame complete:(void (^)(NSString *, BHScanController *))complete {
    
    if (self = [super init]) {
        _outCompleteBlock = complete;
        [self configInitValue];
        _scanFrame = frame;
        _scanView = [[BHScanView alloc] initWithScanFrame:_scanFrame];
        __weak BHScanController *wkSelf = self;
        _scanCompleteBlock = ^(NSString *result) {
            wkSelf.scanView.timerState = BHTimerStateStop;
            wkSelf.outCompleteBlock(result, wkSelf);
        };
    }
    return self;
}

- (void)configInitValue {
    _navigationTintColor = [UIColor whiteColor];
    _navigationBarAlpha = 0;
    _navigationBarTintColor = [UIColor whiteColor];
    _navigationTitleText = @"二维码扫描";
}

/**
 启动扫码线动画与session
 */
- (void)start {
    _scanView.timerState = BHTimerStateMove;
    if (![_device.session isRunning]) {
        [_device.session startRunning];
    }
}

/**
 暂停扫码线动画与session
 */
- (void)stop {
    _scanView.timerState = BHTimerStateStop;
    if ([_device.session isRunning]) {
        [_device.session stopRunning];
    }
}

// MARK: - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_scanView];
    [self requestCaptureAuth];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configNavigation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stop];
    
    self.navigationController.navigationBar.shadowImage = _originalShadowImage;
    self.navigationController.navigationBar.titleTextAttributes = _originalTitleTextAttributes;
    self.navigationController.navigationBar.tintColor = _originalTintColor;
    [self.navigationController.navigationBar setBackgroundImage:_originalBackgroundImage forBarMetrics:UIBarMetricsDefault];
}



- (void)dealloc {
    if (_device && _device.session.isRunning) {
        [_device.session stopRunning];
    }
    dispatch_source_cancel(_scanView.timer);
}

- (void)configNavigation {
    if (self.navigationController == nil) {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (@available(iOS 11.0, *)) {
            UIView *barTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BH_SCREENWIDTH, statusBarHeight)];
            [self.view addSubview:barTopView];
            barTopView.backgroundColor = _navigationBarTintColor;
            barTopView.alpha = _navigationBarAlpha;
        }
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, statusBarHeight, BH_SCREENWIDTH, 44)];
        _navigationBar.shadowImage = [[UIImage alloc] init];
        [_navigationBar setBackgroundImage:[self imageWithColor:_navigationBarTintColor alpha:_navigationBarAlpha] forBarMetrics:UIBarMetricsDefault];
        _navigationBar.tintColor = _navigationTintColor;
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:_navigationTitleText];
        [_navigationBar pushNavigationItem:navigationItem animated:true];
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"BHQrCode" ofType:@"bundle"];
        NSString *imagePath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"close@2x" ofType:@"png"];
        UIImage *image = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
        navigationItem.leftBarButtonItem = closeItem;
        _navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: _navigationTintColor};
        if (_showAlbum) {
            UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(albumClick)];
            navigationItem.rightBarButtonItem = albumItem;
        }
        [self.view addSubview:_navigationBar];
    } else {
        self.navigationItem.title = _navigationTitleText;
        
        self.originalTitleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
        self.originalTintColor = self.navigationController.navigationBar.tintColor;
        self.originalShadowImage = self.navigationController.navigationBar.shadowImage;
        self.originalShadowImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: _navigationTintColor};
        [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:_navigationBarTintColor alpha:_navigationBarAlpha] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.tintColor = _navigationTintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        if (_showAlbum) {
            UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(albumClick)];
            self.navigationItem.rightBarButtonItem = albumItem;
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color alpha:(CGFloat)alpha {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)albumClick {
    TZImagePickerController *picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingGif = false;
    picker.allowPickingVideo = false;
    picker.allowCrop = false;
    picker.allowTakePicture = false;
    [self presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [self identityThisImage:photos.firstObject];
}

- (void)dismissController {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)requestCaptureAuth {
    __weak BHScanController *wkSelf = self;
    
    AVAuthorizationStatus state = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (state) {
        case AVAuthorizationStatusNotDetermined: {
            // 用户还没有决定是否给相机授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        // 用户接受
                        [wkSelf deviceWork];
                    } else {
                        // 用户拒绝
                        [wkSelf showPrompt:nil];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户拒绝相机授权或没有相机权限
            [self showPrompt:nil];
            break;
        case AVAuthorizationStatusAuthorized:
            // 授权
            [self deviceWork];
            break;
    }
}

- (void)deviceWork {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _device = [[BHScanDevice alloc] initWithScanFrame:_scanFrame layer:self.view.layer];
        _device.complete = _scanCompleteBlock;
    } else {
        [self showPrompt:@"当前设备没有拍照功能"];
    }
    
}

- (void)showPrompt:(NSString *)text {
    
    _scanView.hidden = true;
    
    UILabel *promptView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, BH_SCREENWIDTH-40, 300)];
    promptView.textAlignment = NSTextAlignmentCenter;
    
    NSString *promptText = nil;
    if (text == nil) {
        if (!_appName) {
            _appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] ?
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] :
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        }
        promptText = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@访问您的相机", _appName];
    } else {
        promptText = text;
    }
    promptView.text = promptText;
    promptView.numberOfLines = 0;
    [self.view addSubview:promptView];
    
}

// MARK: - Set
- (void)setScanLineImage:(UIImage *)scanLineImage {
    _scanLineImage = scanLineImage;
    _scanView.scanLine.image = scanLineImage;
}

- (void)setScanImage:(UIImage *)scanImage {
    _scanImage = scanImage;
    _scanView.scanImageView.image = scanImage;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    _scanView.scanImageView.tintColor = tintColor;
    _scanView.scanLine.tintColor = tintColor;
}

- (void)setScanColor:(UIColor *)scanColor {
    _scanColor = scanColor;
    _scanView.scanImageView.tintColor = scanColor;
}

- (void)setScanLineColor:(UIColor *)scanLineColor {
    _scanLineColor = scanLineColor;
    _scanView.scanLine.tintColor = scanLineColor;
}

- (void)setCoverViewAlpha:(CGFloat)coverViewAlpha {
    _coverViewAlpha = coverViewAlpha;
    for (UIView *item in @[_scanView.topCoverView, _scanView.leftCoverView, _scanView.bottomCoverView, _scanView.rightCoverView]) {
        item.alpha = coverViewAlpha;
    }
}

- (void)setIntroduceText:(NSString *)introduceText {
    _introduceText = introduceText;
    _scanView.introduceLabel.text = introduceText;
}

- (void)setIntroduceFontSize:(CGFloat)introduceFontSize {
    _introduceFontSize = introduceFontSize;
    _scanView.introduceLabel.font = [UIFont systemFontOfSize:introduceFontSize];
    [_scanView.introduceLabel sizeToFit];
}

- (void)setIntroduceFont:(UIFont *)introduceFont {
    _introduceFont = introduceFont;
    _scanView.introduceLabel.font = introduceFont;
    [_scanView.introduceLabel sizeToFit];
}

- (void)setIntroduceTextAlignment:(NSTextAlignment)introduceTextAlignment {
    _introduceTextAlignment = introduceTextAlignment;
    _scanView.introduceLabel.textAlignment = introduceTextAlignment;
}

- (void)setIntroduceTextColor:(UIColor *)introduceTextColor {
    _introduceTextColor = introduceTextColor;
    _scanView.introduceLabel.textColor = introduceTextColor;
}

- (void)setIntroduceFrame:(CGRect)introduceFrame {
    _introduceFrame = introduceFrame;
    _scanView.introduceLabel.frame = introduceFrame;
}

// MARK: - 方法实现
// 识别指定图片
- (void)identityThisImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:features.count];
    for (NSInteger i = 0; i < [features count]; i++) {
        CIQRCodeFeature *feature = [features objectAtIndex:i];
        NSString *scannedResult = feature.messageString;
        [results addObject:scannedResult];
    }
    __weak BHScanController *wkSelf = self;
    if (_outCompleteBlock) {
        self.outCompleteBlock(results.firstObject, wkSelf);
    }
}

@end
