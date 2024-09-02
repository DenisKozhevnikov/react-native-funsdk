//
//  LANSearchViewController.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/15.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//

#import "LANSearchViewController.h"
#import "DeviceManager.h"
#import <Masonry/Masonry.h>
#import "SearchDeviceCell.h"
#import "DeviceObject.h"
#import "AddLANCameraViewController.h"

@interface LANSearchViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceManagerDelegate>
{
    NSMutableArray *deviceArray;        //设备数组
    DeviceManager *deviceManager;       //设备管理器
}
@property (nonatomic,strong)UITableView *listTableView;         //搜索到的设备列表
@end

@implementation LANSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //设备管理器
    deviceManager = [[DeviceManager alloc] init];
    deviceManager.delegate = self;
    //设置导航栏
    [self setNaviStyle];
    
    [self.view addSubview:self.listTableView];
    //控件布局
    [self configSubView];
    //获取局域网设备
    [SVProgressHUD show];
    [deviceManager SearchDevice];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("search_wifi_device");
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

#pragma mark - 控件布局
-(void)configSubView
{
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@64);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.9);
        make.height.equalTo(self.view.mas_height).offset(-64);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - tableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDeviceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DeviceObject *object = [deviceArray objectAtIndex:indexPath.row];
    
    cell.nameLab.text = [NSString stringWithFormat:@"发现设备%d(%@)",(int)indexPath.row + 1,object.deviceName];
    cell.serialNumLab.text = object.deviceMac;
    cell.ipLab.text = object.deviceIp;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceObject *object = [deviceArray objectAtIndex:indexPath.row];
    
    [SVProgressHUD show];
    // 原设备配网
//    [deviceManager addDeviceBySerialNum:object.deviceMac deviceName:object.deviceName type:object.nType];
    // 新增设备配网
    [JFDevConfigService jf_devConfigWithDevId:object.deviceMac completion:^(id responceObj, NSInteger errCode) {
        JFDevConfigServiceModel *model = nil;
        if (!responceObj) {
            [deviceManager addDeviceBySerialNum:object.deviceMac deviceName:object.deviceName type:object.nType];
            return;
        }
        model = responceObj;
        object.devTokenEnable = model.devTokenEnable;
        if (model.devTokenEnable) {
            // token添加
            [deviceManager addTokenDevWithDevSerialNumber:object.deviceMac deviceName:object.deviceName loginName:object.loginName loginPassword:object.loginPsw devType:object.nType configModel:model];
        }else{
            AddLANCameraViewController *controller = [[AddLANCameraViewController alloc] init];
            controller.deviceInfo = object;
            controller.model = model;
            controller.configType = JFConfigType_lan;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

#pragma mark - funsdk回调处理
#pragma mark 局域网搜索设备回调
-(void)searchDevice:(NSMutableArray *)searchArray result:(int)result{
    [SVProgressHUD dismiss];
    if (result >= 0) {
        deviceArray = [searchArray mutableCopy];
        [self.listTableView reloadData];
    }
    else{
        [MessageUI ShowErrorInt:result];
    }
}

#pragma mark 添加设备回调
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

#pragma mark - lazyload
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        [_listTableView registerClass:[SearchDeviceCell class] forCellReuseIdentifier:@"SearchDeviceCell"];
        _listTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _listTableView;
}

@end
