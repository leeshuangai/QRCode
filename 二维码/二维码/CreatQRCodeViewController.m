//
//  CreatQRCodeViewController.m
//  二维码
//
//  Created by leeshuangai on 2017/3/3.
//  Copyright © 2017年 李爽. All rights reserved.
//

#import "CreatQRCodeViewController.h"
#import <CoreImage/CoreImage.h>
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
@interface CreatQRCodeViewController ()
/** 二维码图片 */
@property (nonatomic,strong) UIImageView *QRCodeImage;

@end

@implementation CreatQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatUI];
    [self creatQRCode];
}

- (void)creatUI {
    
    //二维码图片
    _QRCodeImage = [[UIImageView alloc]init];
    _QRCodeImage.frame = CGRectMake(0, 0, 200, 200);
    _QRCodeImage.center = self.view.center;
    [self.view addSubview:_QRCodeImage];
    
    
    //返回
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 35, 35);
    //backBtn.backgroundColor  = [UIColor greenColor];
   // [backBtn :[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
}
#pragma mark  返回
- (void)disMiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  生成二维码
- (void)creatQRCode {
    
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    
    // 2. 给滤镜添加数据
    //二维码中的数据可以是字符串和URL两种类型, 如果我们想要生成URL的二维码, 只需要把字符串替换为一个URL字符串即可
    NSString *string = @"www.baidu.com";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVC的方式给filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 3. 生成二维码
    CIImage *image = [filter outputImage];
    
    // 4.生成高清二维码
    //_QRCodeImage.image = [UIImage imageWithCIImage:image];
    _QRCodeImage.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:200];
}

#pragma mark - 生成高清的二维码
/*
 中间带有图片的二维码, 其实只需要在二维码的imageView上再添加一个imageView即可, 当然图片不能太大, 否则会导致扫描不到二维码中的信息
 
 但这时候生成的二维码会比较模糊, 只需要使用下面的方法来获得一个清晰的image, 之后只要把image添加到二维码的imageView上即可
 */

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
