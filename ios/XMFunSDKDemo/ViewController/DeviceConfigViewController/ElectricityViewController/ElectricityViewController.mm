//
//  ElectricityViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/5/10.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "ElectricityViewController.h"
#import "ItemTableviewCell.h"
#import "ElectricityConfig.h"

@interface ElectricityViewController ()<UITableViewDelegate,UITableViewDataSource,ElectricityConfigDelegate>
{
    ElectricityConfig *config; //低功耗设备电量
    UITableView *tableView;
    NSMutableArray *titleArray;
}

@end

@implementation ElectricityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    [self startUploadElectricity];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 设置设备状态上报
- (void)startUploadElectricity {
    [SVProgressHUD showWithStatus:TS("")];
    //调用设置设备电量上报
    if (config == nil) {
        config = [[ElectricityConfig alloc] init];
        config.delegate = self;
    }
    [config startUploadElectricity];
}
- (void)stopUploadElectricity {
    [SVProgressHUD showWithStatus:TS("")];
    [config stopUploadElectricity];
}
#pragma mark 设置设备状态上报代理回调
- (void)startUploadElectricityResult:(NSInteger)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark 关闭设备上报代理回调
- (void)stopUploadElectricityResult:(NSInteger)result {
    if (result >=0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark 设备上报回调
- (void)deviceUploadElectricityResult:(NSInteger)result {
    if (result >=0) {
        //成功
        [self.tableView reloadData];
    }else{
    }
}


#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if ([title isEqualToString:TS("BATTERY_Upload")]) { //设备电量上报
        [cell setCellType:cellTypeSwitch];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            if (cell.mySwitch.isOn == YES) {
                [self stopUploadElectricity];
            }else{
                [self startUploadElectricity];
            }
        };
    }else if ([title isEqualToString:TS("Charging")]) {
        //充电状态  //充电状态 0：未充电 1：正在充电 2：电充满 3：未知（表示各数据不准确）
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",config.electable];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([title isEqualToString:TS("IDR_BATTERY")]) { //设备电量
        cell.Labeltext.text = [NSString stringWithFormat:@"%d%@",config.percent,@"%"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([title isEqualToString:TS("SD_storage")]) {
         //设备存储状态 //TF卡状态： -2：设备存储未知 -1：存储设备被拔出 0：没有存储设备 1：有存储设备 2：存储设备插入
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",config.storageStatus];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}



#pragma mark - 界面和数据初始化
- (void)configSubView {
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView {
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight ) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableView;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    titleArray = (NSMutableArray*)@[TS("BATTERY_Upload"),TS("Charging"),TS("IDR_BATTERY"),TS("SD_storage")];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
