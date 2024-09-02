//
//  NetworkViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/6/13.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "NetworkViewController.h"
#import "ItemViewController.h"
#import "ItemTableviewCell.h"
#import "ChangeWifiConfig.h"
#import "QuickConfigurationViewController.h"

@interface NetworkViewController () <UITableViewDelegate,UITableViewDataSource,ChangeWifiConfigDelegate>
{
    ChangeWifiConfig *config; //摄像机参数配置,设备网络配置
    UITableView *tableview;
    UITableView *wifiTableview;
    NSMutableArray *titleArray;
    NSMutableArray *wifiArray;
    
    NSString *wifi;
    NSString *password;
    QuickConfigurationViewController *quickVC;
}

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取摄像机网络配置
    [self getVideoRotainConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取摄像机参数配置
- (void)getVideoRotainConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[ChangeWifiConfig alloc] init];
        config.delegate = self;
    }
    [config getNetWorkWifiConfig];
    [config getWifiListArrayConfig];
}

#pragma mark  获取设备Wi-Fi信息回调
- (void)getNetWorkWifiConfigResult:(NSInteger)result {
    if (result >= 0) {
        //成功，刷新界面数据
        wifi = [config getWifiSSID];
        password = [config getWifiPassword];
        [self.tableview reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark 获取设备Wi-Fi列表回调
- (void)getWifiArrayConfigResult:(NSInteger)result {
    if (result >= 0) {
        //成功，刷新界面数据
        wifiArray = [config getWifiArray];
        [self.wifiTableview reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark 把设备设置成AP模式回调
- (void)setAPModelConfigResult:(NSInteger)result {
    if (result >= 0) {
        [SVProgressHUD dismissWithSuccess:TS("设置AP模式成功，请在手机网络设置中，连接设备热点，然后以AP直连方式重新登录APP")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 100) {
        return titleArray.count;
    }else{
        return wifiArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
        if (!cell) {
            cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *title = [titleArray objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        if ([title isEqualToString:TS("WIFI_SSID")]) {
            cell.Labeltext.text =  wifi;
        }else if ([title isEqualToString:TS("WIFI_Psw")]) {
            cell.Labeltext.text = password;
        }
        return cell;
    }else  {
        ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell2"];
        if (!cell) {
            cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell2"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *title = [wifiArray objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag == 100) {
        NSString *titleStr = titleArray[indexPath.row];
        if ([titleStr isEqualToString:TS("Change_To_AP")]) {
            //设备调整为AP模式（这里是否要加一些限制和判断可以自己确定）
            [SVProgressHUD show];
            [config changeToAPModel];
        }
        else if ([titleStr isEqualToString:TS("Change_Wifi")]){
            [SVProgressHUD showErrorWithStatus:TS("选择下方Wi-Fi，输入Wi-Fi密码，然后开始配网") duration:2];
        }
        else if ([titleStr isEqualToString:TS("WIFI_Psw")]){
            
        }
    }else  {
        NSString *titleStr = wifiArray[indexPath.row];
        wifi = titleStr;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("WIFI_Psw") message:TS("Enter_WIFIPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //输入的Wi-Fi密码
            NSString *timeStr = [alert.textFields firstObject].text;
            password = timeStr;
            quickVC = [[QuickConfigurationViewController alloc] init];
            [self.navigationController pushViewController:quickVC animated:NO];
            [quickVC otherStartWay:wifi psw:password];
            
        }];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:cancelAction];
        [alert addAction:comfirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - 界面和数据初始化
- (void)configSubView {
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.wifiTableview];
}
- (UITableView *)tableview {
    if (!tableview) {
        tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200) style:UITableViewStylePlain];
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.tag = 100;
        [tableview registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableview;
}
- (UITableView *)wifiTableview {
    if (!wifiTableview) {
        wifiTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, ScreenWidth, ScreenHeight-200-NavHeight) style:UITableViewStylePlain];
        wifiTableview.delegate = self;
        wifiTableview.dataSource = self;
        wifiTableview.tag = 200;
        [wifiTableview registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell2"];
    }
    return wifiTableview;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    titleArray = (NSMutableArray*)@[TS("WIFI_SSID"),TS("WIFI_Psw"),TS("Change_To_AP"),TS("Change_Wifi")];
    wifiArray = [[NSMutableArray alloc] initWithCapacity:0];
    wifi = @"";
    password = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
