//
//  AlarmPICViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/3.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "AlarmPICViewController.h"
#import "ItemViewController.h"
#import "ItemTableviewCell.h"
#import "AlarmPIRConfig.h"
@interface AlarmPICViewController ()<UITableViewDelegate,UITableViewDataSource,AlarmPIRConfigDelegate> {
    AlarmPIRConfig *config; //徘徊检测 (PIR报警)
    UITableView *tableView;
    NSMutableArray *titleArray;
}

@end

@implementation AlarmPICViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取摄像机c徘徊检测配置`
    [self getAlarmPIRConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取摄像机参数配置
- (void)getAlarmPIRConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[AlarmPIRConfig alloc] init];
        config.delegate = self;
    }
    //调用获取摄像机图像翻转等参数的接口
    [config getAlarmPIRConfig];
}
#pragma mark 获取摄像机参数代理回调
- (void)AlarmPIRConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存摄像机参数配置
-(void)saveConfig{
    [SVProgressHUD show];
    [config SetConfig];
}
#pragma mark 保存摄像机参数代理回调
- (void)AlarmPIRConfigSetResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    //徘徊检测开关
    if ([title isEqualToString:TS("AlarmPIR_Enable")]) {
        if ([config getAlarmPIREnable] == YES) {
            cell.Labeltext.text =  TS("open");
        }else{
            cell.Labeltext.text =  TS("close");
        }
    }else if ([title isEqualToString:TS("AlarmPIR_time")]) {
        //徘徊检测默认触发2s之后开始录像，也就是徘徊2s才算徘徊检测
        cell.Labeltext.text =[NSString stringWithFormat:@"%d",[config getAlarmPIRCheckTime]];
    }
    else if ([title isEqualToString:TS("Alarm_Sensitivity")]) {
        //灵敏度
        cell.Labeltext.text =[NSString stringWithFormat:@"%d",[config getAlarmPirSensitive]];
    }
    else if ([title isEqualToString:TS("TR_Recording_Duration")]) {
        //灵敏度
        cell.Labeltext.text =[NSString stringWithFormat:@"%d",[config getAlarmRecordLength]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = titleArray[indexPath.row];
    //初始化各个配置的item单元格
    ItemViewController *itemVC = [[ItemViewController alloc] init];
    [itemVC setTitle:titleStr];
    
    __weak typeof(self) weakSelf = self;
    itemVC.itemSelectStringBlock = ^(NSString *encodeString) {
        //itemVC的单元格点击回调,设置各种属性
        ItemTableviewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
        cell.Labeltext.text = encodeString;
        if ([cell.textLabel.text isEqualToString:TS("AlarmPIR_Enable")]) {
            if ([encodeString isEqualToString:TS("open")]) {
                [config setAlarmPIREnable:YES];
            }else {
                [config setAlarmPIREnable:NO];
            }
        }else if ([cell.textLabel.text isEqualToString:TS("AlarmPIR_time")]){
            [config setAlarmPIRCheckTime:[encodeString intValue]];
        }else if ([cell.textLabel.text isEqualToString:TS("Alarm_Sensitivity")]){
            //灵敏度 1是最低的 5是最高的
            [config setAlarmPirSensitive:[encodeString intValue]];
        }else if ([cell.textLabel.text isEqualToString:TS("TR_Recording_Duration")]){
            [config setAlarmRecordLength:[encodeString intValue]];
        }else{
            return;
        }
    };
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("AlarmPIR_Enable")]) {
        [itemVC setValueArray:[self enableArray]];
    }else if ([titleStr isEqualToString:TS("AlarmPIR_time")]){
        [itemVC setValueArray:[self timeArray]];
    }else if ([titleStr isEqualToString:TS("Alarm_Sensitivity")]){
        [itemVC setValueArray:[self sensitivityArray]];
    }else if ([titleStr isEqualToString:TS("TR_Recording_Duration")]){
        [itemVC setValueArray:[self recordArray]];
    }else{
        return;
    }
    //如果赋值成功，跳转到下一级界面
    [self.navigationController pushViewController:itemVC animated:YES];
}

- (NSMutableArray*)enableArray {
    return (NSMutableArray*)@[TS("open"),TS("close")];
}
- (NSMutableArray*)timeArray {
    return (NSMutableArray*)@[@"0.6",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"15",@"20",@"25",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100",@"120",@"140",@"160",@"180"];
}
- (NSMutableArray*)sensitivityArray {
    return (NSMutableArray*)@[@"1",@"2",@"3",@"4",@"5"];
}

- (NSMutableArray*)recordArray {
    return (NSMutableArray*)@[@"5",@"10",@"15"];
}
#pragma mark - 界面和数据初始化
- (void)configSubView {
    self.title = TS("AlarmPIR");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.title name:NSStringFromClass([self class])];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
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
    titleArray = (NSMutableArray*)@[TS("AlarmPIR_Enable"),TS("AlarmPIR_time"),TS("Alarm_Sensitivity"),TS("TR_Recording_Duration")];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
