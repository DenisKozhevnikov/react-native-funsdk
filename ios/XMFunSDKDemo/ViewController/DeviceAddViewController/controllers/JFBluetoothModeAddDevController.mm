//
//  JFBluetoothModeAddDevController.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/29.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFBluetoothModeAddDevController.h"
#import "BlueToothToolManager.h"
#import "JFBluetoothSearchResultAlertView.h"


@interface JFBluetoothModeAddDevController ()<JFBluetoothSearchResultAlertViewDelegate>
/** 蓝牙相关 */
@property (nonatomic, strong) BlueToothManager *bluetoothManager;
/** 雷达搜索 */
@property (nonatomic, strong) XMRadarView *radarView;
/** 用于存储蓝牙设备 */
@property (nonatomic, strong) NSMutableArray <XMSearchedDev *>*bluetoothSource;

@end

@implementation JFBluetoothModeAddDevController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self bluetoothSubviews];
    [self bluetoothConfig];
}

- (void)bluetoothSubviews{
    [self.view addSubview:self.radarView];
    [self.radarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(SCREEN_WIDTH *0.6);
        make.width.mas_equalTo(SCREEN_WIDTH *0.6);
    }];
}

- (void)bluetoothConfig{
    [self.bluetoothManager jf_reqBluetoothStateCompletion:^(JFManagerAuthorization authState, JFManagerState switchState) {
        [self bluetoothHandleWithAuthState:authState switchState:switchState];
    }];
}

- (void)bluetoothHandleWithAuthState:(JFManagerAuthorization)authState switchState:(JFManagerState)switchState{
    // 13.0以后需要判断状态和权限
    if (@available(iOS 13.0, *)){
        if(JFManagerStatePoweredOn == switchState){
            XMLog(@"[JF]权限、开关都开了😊！");
            self.radarView.hidden = NO;
            [self.radarView beginAnimation];
            // 搜索蓝牙设备
            [[BlueToothToolManager sharedBlueToothToolManager] startSearch];
            @XMWeakify(self)
            [BlueToothToolManager sharedBlueToothToolManager].blueToothFoundDevice = ^(NSString * _Nonnull pid, NSString * _Nonnull name, NSString * _Nonnull mac) {
                [weak_self searchedBlueTooth:pid name:name mac:mac];
            };
            return;
        }
        // 权限开了，但开关未开
        if(JFManagerAuthorizationAllowedAlways == authState && JFManagerStatePoweredOff == switchState){
            [self.radarView endAnimation];
            self.radarView.hidden = YES;
            [[BlueToothToolManager sharedBlueToothToolManager] stopSearch];
            XMLog(@"[JF]权限开了，开关未开☹️！");
            [UIAlertController xm_showAlertWithMessage:TS("common_ble_open_tips_2") actionTitle:TS("OK") action:nil];
            return;
        }
        // 未开权限
        if(JFManagerAuthorizationAllowedAlways != authState){
            [self.radarView endAnimation];
            self.radarView.hidden = YES;
            [[BlueToothToolManager sharedBlueToothToolManager] stopSearch];
            XMLog(@"[JF]权限未开😭！");
            [UIAlertController xm_showAlertWithMessage:TS("common_ble_permission_open_tips_1") actionTitle:TS("OK") action:^{
                if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:)]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
    }else{
        // 只需要判断开关状态
        if(JFManagerStatePoweredOn == switchState){
            self.radarView.hidden = NO;
            [self.radarView beginAnimation];
            // 搜索蓝牙设备
            [[BlueToothToolManager sharedBlueToothToolManager] startSearch];
            @XMWeakify(self)
            [BlueToothToolManager sharedBlueToothToolManager].blueToothFoundDevice = ^(NSString * _Nonnull pid, NSString * _Nonnull name, NSString * _Nonnull mac) {
                [weak_self searchedBlueTooth:pid name:name mac:mac];
            };
            XMLog(@"[JF]开关开了😊！");
            return;
        }
        [self.radarView endAnimation];
        self.radarView.hidden = YES;
        [[BlueToothToolManager sharedBlueToothToolManager] stopSearch];
        //
        [UIAlertController xm_showAlertWithMessage:TS("common_ble_open_tips_3") actionTitle:TS("OK") action:^{
            if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:)]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        XMLog(@"[JF]开关未开☹️！");
    }
}
// 搜索到蓝牙外设
- (void)searchedBlueTooth:(NSString *)pid name:(NSString *)name mac:(NSString *)mac{
    XMSearchedDev *dev = [[XMSearchedDev alloc] init];
    dev.pid = pid;
    dev.isBlueTooth = YES;
    dev.name = name;
    dev.mac = mac;
    // 规避重复添加设备
    [self.bluetoothSource enumerateObjectsUsingBlock:^(XMSearchedDev * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && JF_IsEqualToStr(obj.mac, mac)){
            *stop = YES;
            return;
        }
    }];
    [self.bluetoothSource addObject:dev];
    XMLog(@"[JF]搜索到了蓝牙设备：name：%@, 序列号:%@", name, mac);
    [JFBluetoothSearchResultAlertView jf_showResultViewWithDataSource:self.bluetoothSource delegate:self];
}
#pragma mark - JFBluetoothSearchResultAlertViewDelegate
- (void)jf_didSelectedDevModel:(id)devModel{
    if(!devModel) return;
    // 路由设置
    JFRouterSettingController *routerSettingVC = [[JFRouterSettingController alloc] init];
    routerSettingVC.devModel = devModel;
    routerSettingVC.navigationItem.title = TS("TR_Route_set");
    routerSettingVC.navigationItem.titleView = [[UILabel alloc] initWithTitle:routerSettingVC.navigationItem.title name:NSStringFromClass([routerSettingVC class])];
    [self.navigationController pushViewController:routerSettingVC animated:YES];
}

#pragma mark - private method
// MARK: bluetoothManager
- (BlueToothManager *)bluetoothManager{
    if(!_bluetoothManager){
        _bluetoothManager = [[BlueToothManager alloc] init];
    }
    return _bluetoothManager;
}
// MARK: radarView
- (XMRadarView *)radarView{
    if(!_radarView){
        _radarView = [[XMRadarView alloc] initWithFrame:CGRectZero];
        _radarView.hidden = YES;
        _radarView.radarImgName = @"bluetooth_radar_search_icon";
    }
    return _radarView;
}

// MARK: arr
- (NSMutableArray *)bluetoothSource{
    if(!_bluetoothSource){
        _bluetoothSource = [[NSMutableArray alloc] init];
    }
    return _bluetoothSource;
}
- (void)dealloc{
    [self.radarView endAnimation];
    [[BlueToothToolManager sharedBlueToothToolManager] stopSearch];
}

@end
