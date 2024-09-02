//
//  MQTTViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2023/9/22.
//  Copyright © 2023 zhang. All rights reserved.
//

#import "MQTTViewController.h"
#import "ItemViewController.h"
#import "ItemTableviewCell.h"
#import "SubscribeManager.h"

@interface MQTTViewController ()  <UITableViewDelegate,UITableViewDataSource,SubscribeManagerDelegate>
{
    SubscribeManager *subscribe; //MQTT
    UITableView *paramTableView;
    NSMutableArray *paramTitleArray;
    UISwitch *_subscribeSwitch;
}

@end

@implementation MQTTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 初始化MQTT
    [self initMQTT];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

- (void)initMQTT {
    if (subscribe ==nil) {
        subscribe = [[SubscribeManager alloc] init];
        subscribe.delegate = self;
        [subscribe initSubscribeServer];
    }
}


- (void)subscribeServer:(UISwitch*)subSwitch {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    if (subSwitch.isOn) {
        [subscribe subscribeFromServer:channel.deviceMac];
    }else{
        [subscribe unSubscribeFromServer:channel.deviceMac];
    }
}

#pragma mark - MQTT代理回调方法
//初始化MQTT回调
- (void)initSubscribeServerDelegateResult:(NSInteger)result {
    if (result< 0) {
        [MessageUI ShowErrorInt:result];
    }
}
//注销MQTT回调
- (void)uninitSubscribeServerDelegateResult:(NSInteger)result{
    if (result< 0) {
        [MessageUI ShowErrorInt:result];
    }
}

//订阅设备在线状态通知结果
- (void)SubscribeFromServerDelegate:(NSString *)deviceMac Result:(NSInteger)result{
    if (result< 0) {
        [MessageUI ShowErrorInt:result];
    }
}
//取消订阅设备在线状态通知结果
- (void)UnSubscribeFromServerDelegate:(NSString *)deviceMac Result:(NSInteger)result{
    if (result< 0) {
        [MessageUI ShowErrorInt:result];
    }
}

//服务端下发的状态回调
- (void)messageFromServer:(NSString*)deviceMac message:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:actionOK];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return paramTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    NSString *title = [paramTitleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if ([title isEqualToString:TS("Subscription device status")]) {
        [cell addSubview:self.subscribeSwitch];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark - 界面和数据初始化
- (void)configSubView {
    [self.view addSubview:self.paramTableView];
}
- (UITableView *)paramTableView {
    if (!paramTableView) {
        paramTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight ) style:UITableViewStylePlain];
        paramTableView.delegate = self;
        paramTableView.dataSource = self;
        [paramTableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return paramTableView;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    paramTitleArray = (NSMutableArray*)@[TS("Subscription device status")];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UISwitch*)subscribeSwitch {
    if (!_subscribeSwitch) {
        _subscribeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth-80, 10, 60, 30)];
        [_subscribeSwitch addTarget:self action:@selector(subscribeServer:) forControlEvents:UIControlEventValueChanged];
    }
    return _subscribeSwitch;
}
@end
