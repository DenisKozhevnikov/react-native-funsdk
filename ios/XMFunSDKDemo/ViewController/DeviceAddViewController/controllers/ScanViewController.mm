//
//  ScanViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/6/4.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()  <AVCaptureMetadataOutputObjectsDelegate>
{
    
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化界面
    [self initScanView];
    //开始扫描
    [self startSancode];
    
}

- (void)startSancode {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
            //无权限，提示用户设置
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:TS("No_permission_access_Camera") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("Go to settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            
            [alertVC addAction:actionCancel];
            [alertVC addAction:actionOK];
            
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        [self startReadingMachineReadableCodeObjects:@[AVMetadataObjectTypeQRCode] inView:self.view];
    });
}

// 开始扫描
- (void)startReadingMachineReadableCodeObjects:(NSArray *)codeObjects inView:(UIView *)preview {
    // 摄像头设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // 设置输入口
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error || !input) {
        NSLog(@"error: %@", [error description]);
        return;
    }
    
    // 会话session, 把输入口加入会话
    self.session = [[AVCaptureSession alloc] init];
    [self.session addInput:input];// 将输入添加到session
    
    // 设置输出口，加入session, 设置输出口参数
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    CGRect rect = self.view.frame;
    float y = (rect.origin.y)/ ScreenHeight;
    float x = (( ScreenWidth - rect.size.width )/ 2 )/ ScreenWidth;
    float h = rect.size.height / ScreenHeight;
    float w = rect.size.width / ScreenWidth;
    [output setRectOfInterest:CGRectMake(y,x,h,w)];
    
    [self.session addOutput:output];
    
    [output setMetadataObjectTypes:codeObjects];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()]; // 使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    // 设置展示层(预览层)
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];// 设置预览层信息
    [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.preview.frame = [UIScreen mainScreen].bounds;
    
    [preview.layer insertSublayer:self.preview atIndex:0]; //添加至视图
    
    [self beginReading];
}

// 启动session
- (void)beginReading{
    [self.session startRunning];
}

// 关闭session
- (void)stopReading{
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
}

// 识别到二维码 并解析转换为字符串
#pragma mark -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self stopReading];
    
    AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
    NSString *codeStr= nil;
    if ([metadata respondsToSelector:@selector(stringValue)]) {
        codeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
    }
    [self.navigationController popViewControllerAnimated:YES];
    self.block (codeStr);
}

- (void)initScanView {
    self.view.backgroundColor = [UIColor lightGrayColor];
    //初始化扫描画面
    UIView *backVIew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    backVIew.center = CGPointMake(ScreenWidth/2.0, 250);
    [self.view addSubview:backVIew];
    
    
    //初始化二维码扫描提示文字显示
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, backVIew.frame.origin.y + 280, ScreenWidth, 50)];
    tipLab.textColor = [UIColor blackColor];
    tipLab.font = [UIFont systemFontOfSize:15];
    tipLab.text = TS("qr_scan_tips");
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.lineBreakMode = NSLineBreakByWordWrapping;
    tipLab.numberOfLines = 0;
    
    [self.view addSubview:tipLab];
}

@end
