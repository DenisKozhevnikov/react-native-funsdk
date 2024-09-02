//
//  JFRouterSettingController.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFRouterSettingController.h"
#import "QuickConfigurationView.h"
#import "AddLANCameraViewController.h"
#import "BlueToothToolManager.h"
#import "DeviceManager.h"
#import <XMNetInterface/NetInterface.h>

@interface JFRouterSettingController ()<DeviceManagerDelegate>
/** 路由设置 */
@property (nonatomic, strong) QuickConfigurationView *routerSettingView;
/** 添加设备管理 */
@property (nonatomic, strong) DeviceManager *devManager;
/** 蓝牙管理者 */
@property (nonatomic,strong) BlueToothToolManager *blueToothToolManager;
/** 配网成功后的外设 信息更全 */
@property (nonatomic, strong) XMSearchedDev *pairedPeripheral;

/** wifi */
@property (nonatomic, copy) NSString * wifiName;
/** wifi pwd */
@property (nonatomic, copy) NSString * wifiPwd;

@end

@implementation JFRouterSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self routerSettingSubviews];
    [self routerSettingConfig];
}

- (void)routerSettingSubviews{
    self.view.backgroundColor = JFCommonColor_FFF;
    [self.view addSubview:self.routerSettingView];
    [self.routerSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

- (void)routerSettingConfig{
    self.routerSettingView.wifiTF.text = [NSString getCurrent_SSID];
    NSString *psw = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString getCurrent_SSID]];
    if (psw) {
        self.routerSettingView.passwordTF.text = psw;
    }
    
    @XMWeakify(self)
    self.routerSettingView.startConfig = ^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        @XMStrongify(self)
        self.wifiName = ssid;
        self.wifiPwd = password;
        // 开始链接蓝牙设备
        [self.blueToothToolManager connectPeripheral:[NSString stringWithFormat:@"%@%@",self.devModel.mac, self.devModel.pid]];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:ssid];
    };
    self.routerSettingView.stopConfig = ^{
        [self.blueToothToolManager cancelConnection];
    };
    // MARK: 蓝牙配置
    // 1、链接成功
    self.blueToothToolManager.blueToothConnectSuccessBlock = ^{
        XMLog(@"[JF]连接蓝牙设备成功!");
        [self.blueToothToolManager startAddBlueToothDevice:self.wifiName password:self.wifiPwd mac:[NSString xm_deviceMacAddress]];
    };
    // 2、连接设备失败回调
    self.blueToothToolManager.blueToothConnectFailedBlock = ^(NSError * _Nonnull error) {
        [self.blueToothToolManager cancelConnection];
        [UIAlertController xm_showAlertWithMessage:TS("TR_Connect_bluetooth_failed") actionTitle:TS("OK") action:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
        XMLog(@"[JF]连接蓝牙设备失败！");
    };
    // 3、蓝牙设备返回数据（不管成功失败）
    self.blueToothToolManager.blueToothResponse = ^{
        XMLog(@"[JF]");
    };
    // 4、蓝牙设备返回数据回调
    self.blueToothToolManager.blueToothResponseSuccessBlock = ^(NSString * _Nonnull userName, NSString * _Nonnull password, NSString * _Nonnull sn, NSString * _Nonnull ip, NSString * _Nonnull mac, NSString * _Nonnull token, BOOL result) {
        [weak_self blueToothResponseWith:userName password:password sn:sn ip:ip mac:mac token:token result:result];
        XMLog(@"[JF]连接蓝牙设备成功，userName:%@, password:%@, sn:%@, ip:%@, mac:%@, token:%@", userName, password, sn, ip, mac, token);
    };
    // 5、蓝牙设备配网失败
    self.blueToothToolManager.blueToothResponseFailedBlock = ^(NSString * _Nonnull result) {
        [self.blueToothToolManager cancelConnection];
        if (53 == [result integerValue]) {
            [UIAlertController xm_showAlertWithMessage:TS("TR_Device_Ddd_Connect_Network_Wrong_Pwd_Error_Tip") actionTitle:TS("OK") action:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }];
        }
        if (50 == [result integerValue] || 51 == [result integerValue] || 52 == [result integerValue]) {
            //50:未知错误 51:未找到热点 52:握手失败
            [UIAlertController xm_showAlertWithMessage:TS("TR_Device_Add_Connect_Wifi_Failed_With_Empty_Data") actionTitle:TS("OK") action:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }];
        }
        XMLog(@"[JF]");
    };
}

- (void)addDevHandle:(XMSearchedDev *)devModel{
    self.navigationItem.title = TS("EE_DVR_CONSUMER_OPR_SEARCHING");
    XMSearchedDev *model = devModel;
    __block JFDevConfigServiceModel *repModel = nil;
    @XMWeakify(self)
    // 添加设备
    [JFDevConfigService jf_devConfigWithDevId:model.sn completion:^(id responceObj, NSInteger errCode) {
        if(!responceObj || errCode < 0){
            @XMStrongify(self)
            XMLog(@"[JF]蓝牙配网添加token设备失败！");
            if (errCode == -10000 || errCode == -99987 || errCode == -100000) {
                [UIAlertController xm_showAlertWithMessage:TS("TR_Add_Dev_Failed_Msg") sureTitle:TS("TR_Retry_Add") cancelTitle:TS("Cancel") sureAction:^{
                    [self addDevHandle:self.devModel];
                } cancelAction:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }];
                return;
            }
        }
        repModel = responceObj;
        if (repModel.devTokenEnable) {
            // token添加
            [self.devManager addTokenDevWithDevSerialNumber:model.sn deviceName:model.name loginName:model.devUserName?model.devUserName:@"admin" loginPassword:model.devPassword?model.devPassword:@"" devType:model.iDevType configModel:repModel];
        }else{
            DeviceObject *devObj = [[DeviceObject alloc] init];
            devObj.deviceMac = model.sn;
            devObj.deviceName = model.name;
            devObj.loginName = ISLEGALSTR(model.devUserName)?model.devUserName:@"admin";
            devObj.loginPsw = model.devPassword?model.devPassword:@"";
            devObj.devTokenEnable = repModel.devTokenEnable;
            
            AddLANCameraViewController *controller = [[AddLANCameraViewController alloc] init];
            controller.deviceInfo = devObj;
            controller.model = repModel;
            controller.configType = JFConfigType_bluetooth;
            [self.navigationController pushViewController:controller animated:YES];
        }
        XMLog(@"");
    }];
}

//MARK: 蓝牙配网结果
- (void)blueToothResponseWith:(NSString *)userName password:(NSString *)password sn:(NSString *)sn ip:(NSString *)ip mac:(NSString *)mac token:(NSString *)token result:(BOOL)result{
    if (result) {
        if (!self.pairedPeripheral) {
            self.pairedPeripheral = [[XMSearchedDev alloc] init];
        }
        self.pairedPeripheral.name = sn;
        self.pairedPeripheral.pid = self.devModel.pid;
        self.pairedPeripheral.sn = sn;
        self.pairedPeripheral.isBlueTooth = YES;
        
        SDK_CONFIG_NET_COMMON_V2 pDevsInfo = {0};
        //序列号 mac地址 ip 端口
        NSArray *ipArray = [ip componentsSeparatedByString:@"."];
        if (ipArray.count == 4) {
            pDevsInfo.HostIP.c[0] = [[ipArray objectAtIndex:0] intValue];
            pDevsInfo.HostIP.c[1] = [[ipArray objectAtIndex:1] intValue];
            pDevsInfo.HostIP.c[2] = [[ipArray objectAtIndex:2] intValue];
            pDevsInfo.HostIP.c[3] = [[ipArray objectAtIndex:3] intValue];
        }
        
        pDevsInfo.TCPPort = 34567;
        memcpy(pDevsInfo.sMac, [mac cStringUsingEncoding:NSASCIIStringEncoding], 2*[mac length]);
        memcpy(pDevsInfo.sSn, [sn cStringUsingEncoding:NSASCIIStringEncoding], 2*[sn length]);
        Fun_AddLANDevsToCache(&pDevsInfo, 1);
        BlueToothToolManager *manager = [BlueToothToolManager sharedBlueToothToolManager];
        [manager cancelConnection];
        //
        [self addIOTDeviceWithUserName:userName passWord:password devID:sn token:token ip:ip mac:mac];
    }else{
        [SVProgressHUD showErrorWithStatus:TS("add_failed")];
    }
}
//MARK: iot设备不跳转到密码设置界面 ，直接设置随机用户名和密码
- (void)addIOTDeviceWithUserName:(NSString *)userName passWord:(NSString *)password devID:(NSString *)devID token:(NSString *)token ip:(NSString *)ip mac:(NSString *)mac{
    NSString *logStr = [NSString stringWithFormat:@"SDK_LOG:[APP_BLE] 蓝牙配网获取到的用户名密码1userName=%@password=%@devID=%@token=%@",userName,password,devID,token];
    Fun_Log([logStr UTF8String]);
    NSDictionary *dic = @{@"userName":userName,@"password":password,@"random":[NSNumber numberWithBool:YES]};
    self.pairedPeripheral.isBlueTooth = YES;
    //修改用户名密码前一定要先同步密码或者token到本 不然GG 永远不可能修改成功

    Fun_DevSetLocalEncToken([devID UTF8String],token.UTF8String);
    
    if ([[NetInterface getCurrent_SSID] isEqualToString:self.wifiName] && self.wifiName != nil){
        @XMWeakify(self)
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SDK_CONFIG_NET_COMMON_V2 pDevsInfo = {0};
            //序列号 mac地址 ip 端口
            NSArray *ipArray = [ip componentsSeparatedByString:@"."];
            if (ipArray.count == 4) {
                pDevsInfo.HostIP.c[0] = [[ipArray objectAtIndex:0] intValue];
                pDevsInfo.HostIP.c[1] = [[ipArray objectAtIndex:1] intValue];
                pDevsInfo.HostIP.c[2] = [[ipArray objectAtIndex:2] intValue];
                pDevsInfo.HostIP.c[3] = [[ipArray objectAtIndex:3] intValue];
            }
            
            pDevsInfo.TCPPort = 34567;
            memcpy(pDevsInfo.sMac, [mac cStringUsingEncoding:NSASCIIStringEncoding], 2*[mac length]);
            memcpy(pDevsInfo.sSn, [devID cStringUsingEncoding:NSASCIIStringEncoding], 2*[devID length]);
            Fun_Log("快速配置流程：蓝牙配网主动判断34567是否能连接");
            int ret = Fun_DevIsDetectTCPService(&pDevsInfo, 15000);
            Fun_Log([NSString stringWithFormat:@"快速配置流程：34567%@",ret == 1 ? @"走通" : @"不通"].UTF8String);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weak_self continueAdding:devID];
            });
        });
    }else{
        [self continueAdding:devID];
    }
}
//
- (void)continueAdding:(NSString *)devID{
    @XMWeakify(self)
    Fun_Log("快速配置流程：蓝牙配网获取随机用户名密码");
    //
    [self addDevHandle:self.pairedPeripheral];
}

#pragma mark - DeviceManagerDelegate
- (void)addDeviceResult:(int)result{
    if (result >= 0) {
    }else{
        [MessageUI ShowErrorInt:result];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (QuickConfigurationView *)routerSettingView{
    if(!_routerSettingView){
        _routerSettingView = [[QuickConfigurationView alloc] initWithFrame:CGRectZero];
    }
    return _routerSettingView;
}

- (DeviceManager *)devManager{
    if(!_devManager){
        _devManager = [[DeviceManager alloc] init];
        _devManager.delegate = self;
    }
    return _devManager;
}

- (BlueToothToolManager *)blueToothToolManager{
    if (!_blueToothToolManager) {
        _blueToothToolManager = [BlueToothToolManager sharedBlueToothToolManager];
    }
    return _blueToothToolManager;
}

@end
