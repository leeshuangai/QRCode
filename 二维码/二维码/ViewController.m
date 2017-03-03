//
//  ViewController.m
//  二维码
//
//  Created by leeshuangai on 2017/3/3.
//  Copyright © 2017年 李爽. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "CreatQRCodeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)creatQRCode:(id)sender {
    
    CreatQRCodeViewController *vc = [[CreatQRCodeViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (IBAction)scanBt:(id)sender {
    
    QRCodeViewController *vc = [[QRCodeViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
