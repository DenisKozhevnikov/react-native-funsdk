//
//  ShutDownTimeViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/3/18.
//  Copyright © 2019年 XM. All rights reserved.
//
#import "ShutDownTimeConfig.h"
#import "ShutDownTimeViewController.h"
#import "ItemTableviewCell.h"

@interface ShutDownTimeViewController ()<ShutDownTimeConfigDelegate,UITableViewDelegate,UITableViewDataSource>{
    ShutDownTimeConfig *config;
}

@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, assign) int  shutDownTime; //设备自动进入休眠时间


@end

@implementation ShutDownTimeViewController

#pragma mark -- LazyLoad
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myCell"];
        _myTableView.tableFooterView = [UIView new];
    }
    return _myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self configSubViews];
    
    [self getShutDownTime];
}

#pragma mark -- alarmBellState default NO
-(void)initData{
}

-(void)configSubViews{
    [self.view addSubview:self.myTableView];
}

#pragma mark --getConfigAboutDeviceBuzzerState 获取设备自动进入休眠时间
-(void)getShutDownTime{
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[ShutDownTimeConfig alloc] init];
        config.delegate = self;
    }
    [config getShutDownTime];
}

#pragma mark --getConfigAboutDeviceBuzzerStateResult
-(void)getShutDownTimeConfigResult:(int)result {
    if (result <0) {
        [MessageUI ShowErrorInt:result];
    }
    [SVProgressHUD dismiss];
    self.shutDownTime = config.time;
    [self.myTableView reloadData];
}

#pragma mark --setConfigAboutDeviceBuzzerStateResult
- (void)setShutDownTimeConfigResult:(int)result{
    if (result <0) {
        [MessageUI ShowErrorInt:result];
    }else{
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success") duration:1.5f];
    }
}

#pragma mark -- UITableViewDelegate/DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 1) {
        cell.textLabel.text = @"设置休眠";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"唤醒设备";

    }else{
        cell.textLabel.text = TS("Sleep_time");
        if (self.shutDownTime >0) {
            cell.Labeltext.text = [NSString stringWithFormat:@"%dS",self.shutDownTime];
        }
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [config setDeviceSleep];

    }else if(indexPath.row == 2){
        
        [config setDevicewake];
    }else{
        ItemTableviewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.textLabel.text != nil && cell.textLabel.text.length >0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("Set_sleep_time") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //设置时长
                [SVProgressHUD show];
                int time = 15;
                //读取设置的时长并做一些防止输入异常的操作
                NSString *timeStr = [alert.textFields firstObject].text;
                if (timeStr != nil && timeStr.length >0) {
                    time = [timeStr intValue];
                }
                if (time <=0) {
                    time = 15;
                }
                //设置设备自动进入休眠时长
                [config setSutDownTime:time];
                self.shutDownTime = time;
                [self.myTableView reloadData];
            }];
            [alert addTextFieldWithConfigurationHandler:nil];
            [alert addAction:cancelAction];
            [alert addAction:comfirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}

@end
