//
//  DoorUnlockViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorUnlockViewController.h"
#import "DoorUnlockConfig.h"
#import "ItemTableviewCell.h"

@interface DoorUnlockViewController () <DoorUnlockDelegate> {
    
    DoorUnlockConfig *config; //远程开锁
    UILabel *tipLabel; //提示文字
    UILabel *tipLabel2; //提示文字
    UITextField * pswField; //门锁密码输入框
    UIButton *btnSave; //确定按钮
}
@end

@implementation DoorUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    [self configSubView];
    // 获取门锁信息
    [self getDoorUnlockIDConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取门锁信息，准备远程开锁
- (void)getDoorUnlockIDConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[DoorUnlockConfig alloc] init];
        config.delegate = self;
    }
    //调用门锁信息的接口
    [config getDoorUnlockIDConfig];
}
#pragma mark 获取门锁信息代理回调
- (void)DoorUnlockConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [SVProgressHUD dismiss];
        [pswField becomeFirstResponder];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark 点击保存按钮
-(void)btnSaveClicked {
    if (pswField.text == nil || pswField.text.length == 0 || pswField.text.length >10) {
        //密码正常应该是6-10位的纯数字
        return;
    }
    [SVProgressHUD show];
    [config setDoorUnlock:pswField.text];
}
#pragma mark 远程开锁结果回调
- (void)DoorUnlockConfigSetResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 界面和数据初始化
- (void)configSubView {
    self.navigationItem.title = TS("Unlock");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(btnSaveClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.tipLabel];
     [self.view addSubview:self.pswField];
     [self.view addSubview:self.tipLabel2];
    [self.view addSubview:self.btnSave];
}
- (UILabel *)tipLabel {
    if (!tipLabel) {
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, ScreenWidth-60, 60)];
        tipLabel.numberOfLines = 0;
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel.text = TS("Doorlock_unlock_title");
        tipLabel.font = [UIFont systemFontOfSize:18];
        tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return tipLabel;
}
- (UITextField *)pswField {
    if (!pswField) {
        pswField = [[UITextField alloc] initWithFrame:CGRectMake(60, 180, ScreenWidth-120, 30)];
        pswField.placeholder = TS("password");
        pswField.keyboardType = UIKeyboardTypeNumberPad;
        pswField.tintColor = [UIColor lightGrayColor];
    }
    return pswField;
}

- (UILabel *)tipLabel2 {
    if (!tipLabel2) {
        tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 240, ScreenWidth-60, 60)];
        tipLabel2.numberOfLines = 0;
        tipLabel2.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel2.text = TS("Doorlock_unlock_tip");
        tipLabel2.textColor = [UIColor grayColor];
        tipLabel2.font = [UIFont systemFontOfSize:14];
    }
    return tipLabel2;
}

-(UIButton *)btnSave{
    if (!btnSave) {
        btnSave = [[UIButton alloc] initWithFrame:CGRectMake(40, ScreenHeight-180, ScreenWidth-80, 40)];
        [btnSave addTarget:self action:@selector(btnSaveClicked) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setBackgroundColor:[UIColor colorWithRed:37/255.0 green:180/255.0 blue:176/255.0 alpha:1]];
        [btnSave setTitle:TS("OK") forState:UIControlStateNormal];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnSave.layer.masksToBounds = YES;
        btnSave.layer.cornerRadius = 5;
    }
    return btnSave;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
