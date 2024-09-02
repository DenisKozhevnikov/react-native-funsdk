//
//  DoorMessageTotalViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/12.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorMessageTotalViewController.h"
#import "OPProCmdConfig.h"

@interface DoorMessageTotalViewController () <OPProCmdDelegate>
{
    OPProCmdConfig *config; //消息统计
    UISwitch *swch;
}
@end

@implementation DoorMessageTotalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    [self configSubView];
    
    [self getConfig];
}
#pragma mark 获取门锁消息统计的接口
- (void)getConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[OPProCmdConfig alloc] init];
        config.delegate = self;
    }
    //调用获取门锁消息统计的接口
    [config getOPProCmdConfig];
}
#pragma mark 获取门锁消息统计代理回调
- (void)OPProCmdConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        if ([config checkConfig]) {
            [swch setOn: [config getMessageCmdValue]];
        }
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark 设置门锁消息统计开关
- (void)saveConfig {
    [SVProgressHUD show];
    [config setOPProCmdConfig];
}
#pragma mark 保存门锁消息统计代理回调
- (void)OPProCmdConfigSetResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark - 设置门锁统计消息开关
- (void)valueChange:(UISwitch*)swich {
    if ([config checkConfig]) {
        [config setMessageCmdValue:swch.isOn];
    }
}
#pragma mark - 界面和数据初始化
- (void)configSubView {
    self.navigationItem.title = TS("Message_Statistics");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth-100, 30)];
    titleLabel.text = TS("Message_Statistics");
    [self.view addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, ScreenWidth-100, 30)];
    detailLabel.text = TS("Message_Statistics_Tip");
    detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailLabel.numberOfLines = 0;
    detailLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:detailLabel];
    
    if (swch == nil) {
        swch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth-60, 115, 40, 30)];
        [swch addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:swch];
    }
}
@end
