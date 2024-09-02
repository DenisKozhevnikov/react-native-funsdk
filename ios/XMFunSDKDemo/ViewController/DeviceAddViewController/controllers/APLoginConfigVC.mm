//
//  APLoginConfigVC.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/2/28.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "APLoginConfigVC.h"
#import <Masonry/Masonry.h>
#import <FunSDK/FunSDK.h>

@interface APLoginConfigVC ()

@property (nonatomic,strong) UITextField *tfWiFiName;
@property (nonatomic,strong) UITextField *tfPassword;

@property (nonatomic,strong) UIButton *btnConfirm;

@property (nonatomic,assign) int msgHandle;

@end

@implementation APLoginConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设备AP直连配网";
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    
    [self.view addSubview:self.tfWiFiName];
    [self.view addSubview:self.tfPassword];
    [self.view addSubview:self.btnConfirm];
    
    [self myLayout];
}

#pragma mark - EventAction
- (void)btnConfirmClicked{
    
    [SVProgressHUD show];
    
    FUN_DevStartWifiConfigByAPLogin(self.msgHandle, "192.168.10.1:34567", self.tfWiFiName.text.UTF8String, self.tfPassword.text.UTF8String, 180000);
    
    // 这个接口没有回调 自己检测wifi连接断开时 说明配置已经成功 设备也会有相应提示音
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

#pragma mark - Layout
- (void)myLayout{
    [self.tfWiFiName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.tfPassword.mas_top).mas_offset(-10);
    }];
    
    [self.tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self);
    }];
    
    [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.tfPassword.mas_bottom).mas_offset(40);
    }];
}

#pragma mark - LazyLoad
- (UITextField *)tfWiFiName{
    if (!_tfWiFiName) {
        _tfWiFiName = [[UITextField alloc] init];
        _tfWiFiName.placeholder = @"输入WiFi名称";
        _tfWiFiName.textAlignment = NSTextAlignmentCenter;
        _tfWiFiName.layer.cornerRadius = 3;
        _tfWiFiName.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _tfWiFiName.layer.borderWidth = 1;
    }
    
    return _tfWiFiName;
}

- (UITextField *)tfPassword{
    if (!_tfPassword) {
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.placeholder = @"输入密码";
        _tfPassword.textAlignment = NSTextAlignmentCenter;
        _tfPassword.layer.cornerRadius = 3;
        _tfPassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _tfPassword.layer.borderWidth = 1;
    }
    
    return _tfPassword;
}

- (UIButton *)btnConfirm{
    if (!_btnConfirm) {
        _btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnConfirm setTitle:@"开始配置" forState:UIControlStateNormal];
        [_btnConfirm addTarget:self action:@selector(btnConfirmClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnConfirm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnConfirm.layer.cornerRadius = 3;
        _btnConfirm.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _btnConfirm.layer.borderWidth = 1;
    }
    
    return _btnConfirm;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
}

@end
