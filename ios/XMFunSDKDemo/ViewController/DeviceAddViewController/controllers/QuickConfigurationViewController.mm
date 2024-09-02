//
//  QuickConfigurationViewController.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/15.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//

#import "QuickConfigurationViewController.h"
#import "QuickConfigurationView.h"
#import "DeviceManager.h"
#import <Masonry/Masonry.h>
#import "AddLANCameraViewController.h"


@interface QuickConfigurationViewController ()<DeviceManagerDelegate>
{
    DeviceManager *deviceManager;       //设备管理器
    QuickConfigurationView *configView; //快速配置界面
    
    NSString *SSID;
    NSString *Pasword;
}

@end

@implementation QuickConfigurationViewController

#pragma mark  从网络配置界面跳转到这里并直接开始快速配置 （正常快速配置功能不会调用这个方法）
-(void)otherStartWay:(NSString *)ssid psw:(NSString *)password {
    SSID = ssid;
    Pasword = password;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //设备管理器
    deviceManager = [[DeviceManager alloc] init];
    deviceManager.delegate = self;
    
    self.view = self.configView;
    
    
    __weak typeof(self) weakSelf = self;
    //开始快速配置
    configView.startConfig = ^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        [weakSelf startQuickConfiguration:ssid psw:password];
        [weakSelf setCurrentSSID:ssid psw:password];
    };
    //停止快速配置
    configView.stopConfig = ^{
        [weakSelf stopQuickConfiguration];
    };
    //添加设备
    configView.addDevice = ^{
        if (SSID.length > 0) {
            //已连接设备时，在线修改设备连接的wifi功能回调。正常快速配置功能不会调用到这里，这里添加设备会返回-604101，意思是设备已存在，可以根据自己的需求，特殊处理这个回调，也可以参考我们的其他APP，在这里进入重新设置设备名和设备密码流程等等
            [weakSelf addDevice];
        }else{
            //快速配网流程
            [weakSelf addDevice];
        }
    };
    
    //设置导航栏
    [self setNaviStyle];
    
    
}
- (QuickConfigurationView*)configView {
    if (configView == nil) {
        configView = [[QuickConfigurationView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-NavHeight)];
        self.view = configView;
        
        if (SSID == nil) {
            configView.wifiTF.text = [NSString getCurrent_SSID];
            configView.passwordTF.text = [self getCurrentSSID_psw:configView.wifiTF.text];
        }else{
            //从网络配置界面跳转的快速配置流程 （正常快速配置功能不会调用到这里）
            configView.wifiTF.text = SSID;
            configView.passwordTF.text = Pasword;
        }
    }
    return configView;
}
- (void)viewWillAppear:(BOOL)animated{
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("quick_configuration");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

#pragma mark - button event
-(void)popViewController{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  开始快速配置
//因为苹果官方限制，iOS14.5以后的系统，需要申请广播权限才能配网，申请地址：https://developer.apple.com/contact/request/networking-multicast
-(void)startQuickConfiguration:(NSString *)ssid psw:(NSString *)password{
    if (SSID.length >0) {
        //从网络配置界面跳转的快速配置流程 （正常快速配置功能不会调用到这里）
        [deviceManager startOtherWayConfig:ssid password: password];
        
    }else{
        [deviceManager startConfigWithSSID:ssid password:password];
    }
    
}

#pragma mark  结束快速配置
-(void)stopQuickConfiguration{
    [deviceManager stopConfig];
}

#pragma mark  添加设备
-(void)addDevice{
    DeviceObject *object = [configView.deviceArray objectAtIndex:0];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    //通过序列号添加,如果有设备名，则使用设备名，没有设备名称时使用序列号
    NSString *name = object.deviceMac;
    if (object.deviceName && object.deviceName.length > 0) {
        name = object.deviceName;
    }
    
    //把数据传到添加界面 如果是随机用户名密码设备，需要修改登录用户名以及密码，无法直接默认登录名（admin）添加设备
    AddLANCameraViewController *vc = [[AddLANCameraViewController alloc] init];
    vc.deviceInfo = object;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - funsdk回调处理
-(void)quickConfiguration:(DeviceObject*)device result:(int)resurt{
    if (resurt >= 0) {
        if (device.deviceMac.length == 0) {
            
        }else{
            //快速配置成功，刷新界面
            [configView stopTiming];
            [configView.deviceArray removeAllObjects];
            [configView.deviceArray addObject:device];
            [configView createPlayView];
        }
    }
}


- (NSString*)getCurrentSSID_psw:(NSString*)SSID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SSID];
}
- (void)setCurrentSSID:(NSString*)SSID psw:(NSString*)psw {
    return [[NSUserDefaults standardUserDefaults] setObject:psw forKey:SSID];
}
@end
