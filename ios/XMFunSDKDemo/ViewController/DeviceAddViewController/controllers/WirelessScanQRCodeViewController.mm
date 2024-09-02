//
//  WirelessScanQRCodeViewController.m
//  FunSDKDemo
//
//  Created by P on 2020/8/11.
//  Copyright © 2020 P. All rights reserved.
//

#import "WirelessScanQRCodeViewController.h"
#import "DeviceManager.h"
#import <Masonry/Masonry.h>
#import "FunSDK/FunSDK.h"
#import <FunSDK/FunSDK2.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import "NSString+Category.h"
#import "UIImage+Ex.h"
#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"

#import "QRCodeImageShowView.h"
#import "AddLANCameraViewController.h"

@interface WirelessScanQRCodeViewController ()<DeviceManagerDelegate>

@property (nonatomic, assign) UI_HANDLE msgHandle;       //页面句柄，用以接收fusndk的回调（OnFunSDKResult）

@property (nonatomic, strong) UILabel *tipLab;
@property(nonatomic,strong) UITextField *wifiTF;         //wifi名
@property(nonatomic,strong) UITextField *passwordTF;     //wifi密码
@property(nonatomic,strong) UIButton *configurationBtn;  //确定按钮
@property(nonatomic,strong) UILabel *wifiLab;            //wifi名
@property(nonatomic,strong) UILabel *passwordLab;        //wifi密码
@property(nonatomic,strong) UIButton *startBtn;          //开始快速配置按钮

@property(nonatomic,strong) QRCodeImageShowView *qrCodeView;          //展示二维码界面

@property (nonatomic, copy) NSString* sRandom;                  //随机码
@property (nonatomic) NSURLSessionDataTask *dataTask;           //网络
/** 添加设备 */
@property (nonatomic, strong) DeviceManager *devManager;
/** 请求次数 */
@property (nonatomic, assign) NSInteger reqCount;

@end

@implementation WirelessScanQRCodeViewController
{
    NSString *SSID;
    NSString *Pasword;
}

-(instancetype)init{
    self= [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏
    [self setNaviStyle];
    [self creatView];
    [self initData];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("code_Config_WiFi");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

-(void)creatView
{
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.wifiLab];
    [self.view addSubview:self.wifiTF];
    [self.view addSubview:self.passwordLab];
    [self.view addSubview:self.passwordTF];
    [self.view addSubview:self.startBtn];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(NavHeight + 40);
        make.left.equalTo(@25);
        make.centerX.equalTo(self);
    }];
    
    [self.wifiLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(self.tipLab.mas_bottom).offset(50);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
    }];
    
    [self.wifiTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.wifiLab.mas_right).offset(5);
        make.centerY.equalTo(self.wifiLab.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@30);
    }];
    
    [self.passwordLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(self.wifiLab.mas_bottom).offset(5);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
    }];
    
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passwordLab.mas_right).offset(5);
        make.centerY.equalTo(self.passwordLab.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@30);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTF.mas_bottom).offset(50);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@45);
        make.centerX.equalTo(self.view);
    }];
}

-(void)initData
{
    //获取手机连接的wifi的名字
    NSString *wifiName = [NSString getCurrent_SSID];
    if (wifiName == nil || wifiName == NULL || wifiName.length == 0)
    {
        self.wifiTF.text = TS("Please_connect_wireless_networks");
    }
    else
    {
        self.wifiTF.text = wifiName;
    }
}

#pragma mark - button event
-(void)popViewController{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showQRImage
{
    [self.wifiTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    
    NSInteger qrWidth = CGRectGetWidth(self.view.frame)*0.8;
    //NSString *macString = [[NetInterface getCurrent_Mac] stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *macString = @"020000000000";
    NSString *ipString = [self getIPAddress]; //获取手机的网络的ip地址
    NSArray *ipArray = [ipString componentsSeparatedByString:@"."];
    self.sRandom = [self randomStringWithLength:10]; //生成随机码
    
    NSString *infoString = [NSString stringWithFormat:@"S:%@\nP:%@\nE:1\nM:%@\nI:%@\nB:%@\n",self.wifiTF.text,self.passwordTF.text,macString,[ipArray lastObject],self.sRandom];
    NSLog(@"二维码内容: %@",infoString);
    
    
    //用二维码内容生成二维码，并展示，给设备扫描用
    self.qrCodeView = [[QRCodeImageShowView alloc]initWithFrame:self.view.bounds];
    
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:[NSString unicode2ISO88591:infoString]
                                  format:kBarcodeFormatQRCode
                                   width:SCREEN_WIDTH
                                  height:SCREEN_WIDTH
                                   error:nil];
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        [self.qrCodeView setQrCodeImage: [UIImage imageWithCGImage:image.cgimage]];
    }else{
        [self.qrCodeView setQrCodeImage:[UIImage resizeQRCodeImage:[self getQRCode:[NSString unicode2ISO88591:infoString]] withSize:SCREEN_WIDTH]];
    }
    
    //    [self.qrCodeView setQrCodeImage:[self resizeQRCodeImage:[self getQRCode:infoString] withSize:SCREEN_WIDTH]];
    self.qrCodeView.disMissSelfView = ^(void) {
        [self.qrCodeView removeFromSuperview];
        self.qrCodeView = nil;
    };
    [self.view addSubview:self.qrCodeView];
    
    [self getNetworkingRequestResult]; //使用随机码从服务器查询是否有新设备配网成功并联网 如果设备联网成功，稍微延迟之后会有回调返回设备信息，用以添加设备
}

- (CIImage *)getQRCode:(NSString *)constent{
    //创建二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *strData = [constent dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:strData forKeyPath:@"inputMessage"];
    //生成二维码
    CIImage *outputImage = [filter outputImage];
    
    return outputImage;
}

#pragma mark - 使用随机码从服务器查询是否有新设备配网成功并联网
-(void)getNetworkingRequestResult{
    
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppVersion = [dicInfo objectForKey:@"CFBundleShortVersionString"];
    
    int seconds = [[NSDate date] timeIntervalSince1970];
    
    // 1.创建url
    NSString *strUrl = [NSString stringWithFormat:@"https://pairing.xmcsrv.net/api/query?B=%@&os=iOS&v=%@&T=%i",self.sRandom,strAppVersion,seconds];
    // 对汉字进行转义
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@", strUrl);
    NSURL *url = [NSURL URLWithString:strUrl];
    // 2.创建请求 并：设置缓存策略为每次都从网络加载 超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 3.采用苹果提供的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    @XMWeakify(self)
    // 4.由系统直接返回一个dataTask任务
    self.dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            // 解析数据
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (dict) {
                NSString *msg = [dict objectForKey:@"msg"];
                if ([msg isEqualToString:@"Success"]) {
                    NSLog(@"二维码配网成功");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"refreshDeviceStatus" object:nil userInfo:nil]];
                        [SVProgressHUD show];
                        //添加设备
                        @XMStrongify(self)
                        SDBDeviceInfo devInfo = {0};
                        STRNCPY(devInfo.Devname, SZSTR([dict objectForKey:@"serialNumber"]));
                        STRNCPY(devInfo.Devmac, SZSTR([dict objectForKey:@"serialNumber"]));
                        
                        STRNCPY(devInfo.loginName, SZSTR(@"admin"));
                        
                        STRNCPY(devInfo.loginPsw, SZSTR(@""));
                        
                        devInfo.nType = [[dict objectForKey:@"deviceType"] intValue];
                        
                        [JFDevConfigService jf_devConfigWithDevId:OCSTR(devInfo.Devmac) completion:^(id responceObj, NSInteger errCode) {
                            JFDevConfigServiceModel *model = nil;
                            if (!responceObj) {
                                [self addDevWithSDBDeviceInfo:devInfo];
                                return;
                            }
                            model = responceObj;
                            if (model.devTokenEnable) {
                                // token添加
                                [self.devManager addTokenDevWithDevSerialNumber:OCSTR(devInfo.Devmac) deviceName:OCSTR(devInfo.Devname) loginName:OCSTR(devInfo.loginName) loginPassword:OCSTR(devInfo.loginPsw) devType:devInfo.nType configModel:model];
                            }else{
                                DeviceObject *devObj = [[DeviceObject alloc] init];
                                devObj.deviceMac = OCSTR(devInfo.Devmac);
                                devObj.deviceName = OCSTR(devInfo.Devname);
                                devObj.loginName = OCSTR(devInfo.loginName);
                                devObj.loginPsw = OCSTR(devInfo.loginPsw);
                                devObj.devTokenEnable = model.devTokenEnable;
                                
                                AddLANCameraViewController *controller = [[AddLANCameraViewController alloc] init];
                                controller.deviceInfo = devObj;
                                controller.model = model;
                                controller.configType = JFConfigType_QR;
                                [self.navigationController pushViewController:controller animated:YES];
                            }
                        }];
                        //                        FUN_DevSetLocalPwd(devInfo.Devmac,devInfo.loginName,devInfo.loginPsw);
                        //                        FUN_SysAdd_Device(self.msgHandle, &devInfo);
                        //                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                    });
                    
                }else if([msg isEqualToString:@"Timeout"]){
                    NSLog(@"二维码配网超时");
                    if(self.reqCount < 8){
                        [self getNetworkingRequestResult];
                        self.reqCount ++;
                    }else{
                        dispatch_main_async_safe(^{
                            self.reqCount = 0;
                            [SVProgressHUD showErrorWithStatus:TS("TR_Error_Add_Failed_By_Miss_Tip") duration:1.5];
                        });
                    }
                    // TR_Error_Add_Failed_By_Miss_Token_Tip
                }else{
                    [self getNetworkingRequestResult];
                }
            }
        } else {
            // 网络访问失败
            if (error.code == -999) {
                NSLog(@"网络请求取消");
            }else{
                [self getNetworkingRequestResult];
            }
            NSLog(@"error=%@",error);
        }
    }];
    
    // 5.每一个任务默认都是挂起的，需要调用 resume 方法
    [self.dataTask resume];
}
// 非token添加
- (void)addDevWithSDBDeviceInfo:(SDBDeviceInfo)devInfo{
    FUN_DevSetLocalPwd(devInfo.Devmac,devInfo.loginName,devInfo.loginPsw);
    FUN_SysAdd_Device(self.msgHandle, &devInfo);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

#pragma mark - 获取手机的网络的ip地址
- (NSString *)getIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:(cursor->ifa_name)?(cursor->ifa_name):nil];
                if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                    NSLog(@"IP:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)?inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr):nil]);
                return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)?inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr):nil];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

#pragma mark - 生成随机码
-(NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

-(UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    //Release
    CGContextRelease(contextRef);
    
    CGImageRelease(imageRef);
    
    return [UIImage imageWithCGImage:imageRefResized];
}

#pragma mark - DeviceManagerDelegate
- (void)addDeviceResult:(int)result{
    if(result >= 0){
        dispatch_main_async_safe(^{
            [SVProgressHUD showSuccessWithStatus:TS("Success")];
            [self.qrCodeView removeFromSuperview];
            self.qrCodeView = nil;
//            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        [MessageUI ShowErrorInt:result];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}


#pragma mark - FunSDK 回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case  EMSG_SYS_ADD_DEVICE:{
            if (msg->param1 < 0) {
                if (msg->param1 == -99992) {
                    [SVProgressHUD dismissWithError:TS("Device_Exist") afterDelay:1.5];
                }else{
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }else{
                [SVProgressHUD showSuccessWithStatus:TS("Success")];
                //把添加成功的设备信息添加到设备列表
                [[DeviceManager getInstance] addDeviceToList:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
                
                [self.qrCodeView removeFromSuperview];
                self.qrCodeView = nil;
            }
            
            break;
        default:
            break;
            
        }
    }
}


#pragma mark - lazyload
-(UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:15];
        _tipLab.text = TS("TR_Add_Dev_By_Qr_Code_Guide_1_Tips");
        _tipLab.textAlignment = NSTextAlignmentLeft;
        _tipLab.numberOfLines = 0;
    }
    return _tipLab;
}

-(UILabel *)wifiLab{
    if (!_wifiLab) {
        _wifiLab = [[UILabel alloc] init];
        _wifiLab.text = TS("WIFI:");
    }
    
    return _wifiLab;
}

-(UILabel *)passwordLab{
    if (!_passwordLab) {
        _passwordLab = [[UILabel alloc] init];
        _passwordLab.text = TS("Password2");
    }
    
    return _passwordLab;
}

-(UITextField *)wifiTF{
    if (!_wifiTF) {
        _wifiTF = [[UITextField alloc] init];
        _wifiTF.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TS("") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    }
    
    return _wifiTF;
}

-(UITextField *)passwordTF{
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TS("Enter_WIFIPassword") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    }
    
    return _passwordTF;
}

-(UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] init];
        [_startBtn setTitle:TS("OK") forState:UIControlStateNormal];
        [_startBtn setBackgroundColor:GlobalMainColor];
        [_startBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startBtn addTarget:self action:@selector(showQRImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _startBtn;
}

- (DeviceManager *)devManager{
    if(!_devManager){
        _devManager = [[DeviceManager alloc] init];
        _devManager.delegate = self;
    }
    return _devManager;
}

@end
