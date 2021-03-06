//
//  QRCodeViewController.m
//  二维码
//
//  Created by leeshuangai on 2017/3/3.
//  Copyright © 2017年 李爽. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 30;
@interface QRCodeViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic,strong)  AVCaptureSession *session;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;


@end

@implementation QRCodeViewController
#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resumeAnimation];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_session stopRunning];
    _session = nil;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    
    //1.遮罩
    [self setupMaskView];
    //2.提示文本
    [self setupTipTitleView];
    //3.顶部导航
    [self setupNavView];
    //4.扫描区域
    [self setupScanWindowView];
    //5.开始动画
    [self beginScanning];

    
}
#pragma mark - 黑色遮罩
- (void)setupMaskView
{
    //中间的遮罩
    UIView *mask = [[UIView alloc] init];
    _maskView = mask;
    mask.layer.borderWidth = kMargin;
    mask.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    mask.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT/2);
    [self.view addSubview:mask];
    
    //补充上遮罩
    UIView *topMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/2-SCREEN_WIDTH/2)];
    [self.view addSubview:topMask];
    topMask.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    //补充下遮罩
    UIView *bottomMask = [[UIView alloc]initWithFrame:CGRectMake(0, mask.frame.size.height+mask.frame.origin.y, SCREEN_WIDTH, mask.frame.size.height)];
    [self.view addSubview:bottomMask];
    bottomMask.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
}
#pragma mark - 提示文字
-(void)setupTipTitleView{
    
   
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _maskView.frame.size.height+_maskView.frame.origin.y, self.view.bounds.size.width, kBorderW)];
    tipLabel.text = @"将取景框对准二维码，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 2;
    tipLabel.font=[UIFont systemFontOfSize:12];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
    
}
#pragma mark - 中间扫描区域
- (void)setupScanWindowView
{
    CGFloat scanWindowH = SCREEN_WIDTH - kMargin * 2;
    CGFloat scanWindowW =  SCREEN_WIDTH - kMargin * 2;
    
    _scanWindow = [[UIView alloc] initWithFrame:CGRectMake(kMargin, _maskView.frame.origin.y+kMargin, scanWindowW, scanWindowH)];
    _scanWindow.clipsToBounds = YES;
    [self.view addSubview:_scanWindow];
 
    //动画条
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18;
    
    //四个角
    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topLeft];
    
    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH,scanWindowH - buttonWH, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomRight];
}


#pragma mark - 顶部导航
-(void)setupNavView{
    
    //1.返回
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    //2.相册
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 35, 49);
    albumBtn.center=CGPointMake(SCREEN_WIDTH/2, 20+49/2.0);
    [albumBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [albumBtn addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];

    //3.闪光灯
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(SCREEN_WIDTH-55,20, 35, 49);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashBtn.contentMode=UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
}
#pragma mark - 开始扫描
- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:_scanWindow.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];
}
#pragma mark  我的相册
-(void)myAlbum{
    
    NSLog(@"我的相册");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //4.随便给他一个转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:NULL];
        
    }else{
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
#pragma mark 选择相册回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1.获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
        
    }];
 
}
#pragma mark  返回
- (void)disMiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark  闪光灯
-(void)openFlash:(UIButton*)button{
    
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}
#pragma mark  开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - 动画
- (void)resumeAnimation {
    CAAnimation *anmitation = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anmitation){
        [_scanNetImageView.layer setSpeed:1.0];
    } else {
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH = SCREEN_WIDTH - kMargin * 2;
        CGFloat scanNetImageViewW = _scanWindow.frame.size.width;
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 2.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
}

#pragma mark  获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

#pragma mark - 扫描结果回调
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{

    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //判断是否为二维码类型
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
        [alert show];
    }
}


#pragma mark - 内存警告
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
