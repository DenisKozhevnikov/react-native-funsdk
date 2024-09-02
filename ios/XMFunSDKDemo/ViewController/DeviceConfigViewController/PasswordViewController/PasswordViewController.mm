//
//  PasswordViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/11/17.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "PasswordViewController.h"
#import "NSString+Extention.h"
#import <Masonry/Masonry.h>
#import "PasswordView.h"
#import "PasswordConfig.h"
#import "DeviceRandomPwdManager.h"

@interface PasswordViewController () <ChangePasswordConfigDelegate>
{
    PasswordView *changePwdView;
    PasswordConfig *config;
}
@end

@implementation PasswordViewController
{
    BOOL random;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏
    [self setNaviStyle];
    [self creteView];
    [self createConfig];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark -  修改保存设备密码
- (void)changePassWord:(NSString*)oldPsw newPwd1:(NSString*)newPsw1 newPsw2:(NSString*)newPsw2{
//    //判断新密码是否为空 
//    if (newPsw1.length == 0 ) {
//        [SVProgressHUD showErrorWithStatus:TS("set_new_psd")];
//        return;
//    }
    //判断2次新密码是否相同
    if ( ![newPsw1 isEqualToString:newPsw2]) {
        [SVProgressHUD showErrorWithStatus:TS("pass_notsame")];
        return;
    }
    [SVProgressHUD show];
    [config changePassword:oldPsw newpassword:newPsw1];
}
#pragma mark -  修改设备密码代理回调
- (void)changePasswordConfigResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
- (void)setNaviStyle {
    self.navigationItem.title = TS("Modify_pwd");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}
- (void)creteView {
    //修改账号密码视图初始化
    changePwdView = [[PasswordView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.view = changePwdView;
    __weak typeof(self) weakSelf = self;
    //修改密码按钮点击处理
    changePwdView.changePwdClicked = ^(NSString * _Nonnull name,NSString * _Nonnull pwdOld, NSString * _Nonnull pwdNew1, NSString * _Nonnull pwdNew2) {
        
        if (random){
            [weakSelf onConfirmModifyPwd:name pasword:pwdNew1];
        }else
        {
            [weakSelf changePassWord:pwdOld newPwd1:pwdNew1 newPsw2:pwdNew2];
        }
        
        
    };
}

-(void)onConfirmModifyPwd:(NSString *)name pasword:(NSString *)password{
    NSString *devName = name;
    if (devName.length == 0) {
        [SVProgressHUD showErrorWithStatus:TS("TR_Set_Dev_User_Not_Empty")];
        return;
    }
    
    //判断设备用户名是否符合规则
    DevicePasswordErrorType errorNameType = [NSString matchDeviceUserNameRule:devName];
    NSString *containsNameStr = [NSString containsSpecialCharacterWithUserName:devName];
    if (errorNameType != DPErrorTypeNone){
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString getDeviceUserNameErrorTips:errorNameType contains:containsNameStr] message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];

        [alertVC addAction:actionOK];

        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    __weak typeof(self) weakSelf = self;
    //
    [[DeviceRandomPwdManager shareInstance] ChangeRandomUserWithDevID:channel.deviceMac newUser:devName newPassword:password result:^(int result, NSString *adminToken, NSString *guestToken) {
        if (result > 0) {
            [SVProgressHUD dismiss];
            //修改成功
            [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success") duration:1.5];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%d",result] duration:1.5];
        }
    }];
}

#pragma mark - 初始化设备密码配置
- (void)createConfig {
    if (config == nil) {
        config = [[PasswordConfig alloc] init];
        config.delegate = self;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
