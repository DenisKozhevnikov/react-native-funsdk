//
//  LoginViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/5/15.
//  Copyright © 2018年 XM. All rights reserved.
//

typedef struct Face_struct {
    uint imageLength;
    uint frameLength;
    uint testLength1;
    uint testLength2;
} Face_struct;

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "UserAccountModel.h"
@interface LoginViewController () <UserAccountModelDelegate>
{
    UserAccountModel *accountModel; //账号相关功能接口管理器
    Face_struct face;
    NSData *faceData;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //账号相关功能接口管理器
    accountModel = [[UserAccountModel alloc] init];
    accountModel.delegate = self;
    
    //实时检测用户名是否已经记录过
    [self.userNameTf addTarget:self action:@selector(onUserNameChanged) forControlEvents:UIControlEventEditingChanged];
    
    //设置导航栏
    [self setNaviStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    //如果登录过，显示登录过的账号和密码
    NSString *userName = [[LoginShowControl getInstance] getLoginUserName];
    if (![userName isEqualToString:@""]) {
        self.userNameTf.text = userName;
        self.passwordTf.text = [[LoginShowControl getInstance] getLoginPassword];
    }
    
    // temp 
    self.userNameTf.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"DemoUser"];
    self.passwordTf.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"DemoPassword"];
    
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("Login_User");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - 用户名变化
-(void)onUserNameChanged{
    //获取本地保存的账户信息,如果用户名存在，则显示密码
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userInfoDic = [[defaults objectForKey:@"DemoUserInfo"] mutableCopy];
    if (!userInfoDic) {
        return;
    }
    if (![[userInfoDic allKeys] containsObject:@"DemoUserInfo"]) {
        return;
    }

    self.passwordTf.text = [userInfoDic objectForKey:self.userNameTf.text];
}

//云登陆
- (IBAction)cloudLogin {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [accountModel loginWithName:self.userNameTf.text andPassword:self.passwordTf.text];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.userNameTf.text forKey:@"DemoUser"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTf.text forKey:@"DemoPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//本地登陆
- (IBAction)localLogin {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [accountModel loginWithTypeLocal];
}
//ap直连
- (IBAction)apLogin:(id)sender {
    //判断当前网络是否为ap直连
    if (![NSString checkSSID:[NSString getCurrent_SSID]]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("Error_Prompt") message:TS("check_wifi_setting") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [accountModel loginWithTypeAP];
}
- (IBAction)registerUser {
    FUN_SysInit("arsp.xmeye.net;arsp1.xmeye.net;arsp2.xmeye.net", 15010);
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}
#pragma mark 登录结果回调,result 结果信息，一般<0是失败，>=0是成功
- (void)loginWithNameDelegate:(long)reslut {
    [SVProgressHUD dismiss];
    //如果成功，dismiss，回到主界面
    if (reslut >= 0) {
        //[self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
        //保存当前登录的用户名和密码
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dic = [[defaults objectForKey:@"DemoUserInfo"] mutableCopy];
        if (dic == nil) {
            dic = [[NSMutableDictionary alloc] init];
        }
        [dic setObject:self.passwordTf.text forKey:self.userNameTf.text];
        [defaults setObject:dic forKey:@"DemoUserInfo"];
        return;
    }
    //如果失败，不做操作，留在登陆界面
    [MessageUI ShowErrorInt:(int)reslut];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
