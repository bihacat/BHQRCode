//
//  ViewController.m
//  BHQrCode
//
//  Created by tian on 2019/4/4.
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
    BHScanController *scan = [[BHScanController alloc] initWithScanComplete:^(NSString *result, BHScanController *capture) {
        NSLog(@"the result is %@", result);
    }];
    [self presentViewController:scan animated:true completion:nil];
}

@end
