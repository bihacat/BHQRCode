//
//  ViewController.m
//  BHQrCode
//
//  Created by bihacat on 2019/4/4.
//  Copyright © 2019 bihacat. All rights reserved.
//

#import "ViewController.h"
#import "BHScanController.h"
#import "BHScanTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIImage *img = [BHScanTools generate:@"This is My Img" width:400];
//    UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
//    [self.view addSubview:imgV];
//
//    NSArray *string = [BHScanTools identify:img];
//    NSLog(@"%@", string);
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
//    BHScanController *scan = [[BHScanController alloc] initWithScanComplete:^(NSString *result, BHScanController *capture) {
//        NSLog(@"the result is %@", result);
//    }];
    BHScanController *scan = [[BHScanController alloc] initWithScanFrame:CGRectMake(50, 185.5, 314, 314) complete:^(NSString *result, BHScanController *capture) {
        
    }];
    scan.introduceText = @"abc";
    [self presentViewController:scan animated:true completion:^{
        scan.view.frame = CGRectMake(0, 0, 414, 685);
    }];
}

@end
