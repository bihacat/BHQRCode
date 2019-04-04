# BHQrCode

# Dependency
```
TZImagePickerController (3.2.0)
```

# Install
```
pod 'BHQrCode'
```

# Description
支持push和present方式跳转到二维码扫描页
```
BHScanController *scan = [[BHScanController alloc] initWithScanComplete:^(NSString *result, BHScanController *capture) {
    NSLog(@"the result is %@", result);
}];
[self.navigationController presentViewController:scan animated:true completion:nil];
```

```
BHScanController *scan = [[BHScanController alloc] initWithScanComplete:^(NSString *result, BHScanController *capture) {
    NSLog(@"the result is %@", result);
}];
[self presentViewController:scan animated:true completion:nil];
```

生成二维码图片

```
UIImage *img = [BHScanTools generate:@"http://www.bihacat.com" width:400];
UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
[self.view addSubview:imgV];
```

识别指定二维码内容
```
NSString *string = [BHScanTools identify:img].firstObject;
NSLog(@"%@", string); // "http://www.bihacat.com"
```

Apis

|属性|类型|备注|默认值|
|---|---|---|---|
|scanLineImage|UIImage|扫码线图片|-|
|scanImage|UIImage|扫码框图片|-|
|tintColor|UIColor|扫码框和扫码线颜色|图片颜色|
|scanColor|UIColor|单独设置扫码框颜色|图片颜色
|scanLineColor|UIColor|单独设置扫码线颜色|图片颜色
|coverViewAlpha|CGFloat|遮罩层透明度|0.4|
|introduceText|NSString|提示文字内容|将二维码/条码放入框内，即可自动扫描。|
|introduceFontSize|CGFloat|提示文字字体大小|14|
|introduceFont|UIFont|提示文字字体||
|introduceTextColor|UIColor|提示文字颜色|UIColor.whiteColor|
|introduceFrame|CGRect|提示文字位置|-|
|appName|NSString|无拍照权限时提示的应用名|当前应用名|
|navigationTintColor|UIColor|导航栏文字、按钮颜色|白色|
|navigationBarAlpha|CGFloat|导航栏透明度|0 白色透明|
|navigationBarTintColor|UIColor|导航栏背景颜色,修改是不要忘记修改navigationBarAlpha|白色|
|navigationTitleText|NSString|导航栏标题|二维码扫描|
|showAlbum|BOOL|是否显示相册按钮|否|

![WechatIMG348](https://user-images.githubusercontent.com/38452321/55539406-250a8980-56f3-11e9-8e26-36c977c12e28.jpeg)
