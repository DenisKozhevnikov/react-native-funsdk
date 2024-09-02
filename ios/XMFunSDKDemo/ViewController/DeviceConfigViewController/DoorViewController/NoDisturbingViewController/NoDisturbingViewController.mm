//
//  NoDisturbingViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/15.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "NoDisturbingViewController.h"
#import "NoDisturbingConfig.h"
#import "ItemTableviewCell.h"

#import "NSDate+TimeCategory.h"
@interface NoDisturbingViewController ()
<UITableViewDelegate,UITableViewDataSource,NoDisturbingDelegate>
{
    NoDisturbingConfig *config; //免打扰管理
    UITableView *tableView;
    NSMutableArray *titleArray;
    
    UIDatePicker *picker;
}
@end

@implementation NoDisturbingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取门锁免打扰管理
    [self getDoorDevListConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取门锁免打扰管理
- (void)getDoorDevListConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[NoDisturbingConfig alloc] init];
        config.delegate = self;
    }
    //调用获取门锁免打扰管理的接口
    [config getNoDisturbingConfig];
}
#pragma mark 获取门锁免打扰管理代理回调
- (void)NoDisturbingConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存门锁免打扰管理
-(void)saveConfig{
    [SVProgressHUD show];
    [config setNoDisturbingConfig];
}
#pragma mark 保存门锁免打扰管理代理回调
- (void)NoDisturbingConfigSetResult:(NSInteger)result {
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
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if ([title isEqualToString:TS("No_disturb_manager")]) { //免打扰管理
        [cell setCellType:cellTypeSwitch];
        [cell.mySwitch setOn:[config getNoDisturbingEnable]];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            [config setNoDisturbingEnable:on];
        };
    }
    if ([title isEqualToString:TS("Alarm_message_push")]) {//消息推送
        [cell setCellType:cellTypeSwitch];
        [cell.mySwitch setOn:[config getMessageEnable]];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            [config setMessageEnable:on];
        };
    }
    if ([title isEqualToString:TS("Deep_Sleep")]) { //深度休眠
        [cell setCellType:cellTypeSwitch];
        [cell.mySwitch setOn:[config getSleepEnable]];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            [config setSleepEnable:on];
        };
    }
    if ([title isEqualToString:TS("No_Disturb_Time_Set")]) { //时间段设置
        NSString *timeStart  =  [[[config getStartTime] componentsSeparatedByString:@" "] lastObject];;
        NSString *timeEnd =  [[[config getEndTime]componentsSeparatedByString:@" "] lastObject];
        cell.Labeltext.text = [NSString stringWithFormat:@"%@\n%@",timeStart,timeEnd];
        //默认 2000-01-01 22:00：00- 2000-01-01 06:00:00   参数定义为：从晚上22:00开始进入免打扰，早上6:00关闭免打扰
        //修改获取到的时间段参数,年月日三个值不要修改
        //例如 默认时间段为22:00-06:00，想要设置为晚上8点开始，早上8点结束，则设置开始和结束时间分别为
        //[config setStartTime:@"2000-01-01 20:00:00"];
        //[config setEndTime:@"2000-01-01 08:00:00"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = titleArray[indexPath.row];
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("No_disturb_manager")]) { //免打扰
    }else if ([titleStr isEqualToString:TS("Alarm_message_push")]) {
    }else if ([titleStr isEqualToString:TS("Deep_Sleep")]) {
    }else if ([titleStr isEqualToString:TS("No_Disturb_Time_Set")]) {
        //默认 22:00- 06:00   参数定义为：从22:00开始进入免打扰，早上6:00关闭免打扰
        //修改获取到的时间段参数,不要修改年月日三个参数
        if ([[config getStartTime] isEqualToString:@"2000-01-01 22:00:00"]) {
            //例如 默认时间段为22:00-06:00，想要设置为晚上8点开始，早上8点结束，则设置开始和结束时间分别为
            [config setStartTime:@"2000-01-01 20:00:00"];
            [config setEndTime:@"2000-01-01 08:00:00"];
        }else{
            //设置为默认时间段为22:00-06:00 （这里应该让客户自己选择时间来设置）
            [config setStartTime:@"2000-01-01 22:00:00"];
            [config setEndTime:@"2000-01-01 06:00:00"];
        }

    }else{
        return;
    }
}

- (void)changeValue:(UIDatePicker*)datePicker {
    if (picker.tag == 100) {
        [config setStartTime:[NSDate datestrFromDate:datePicker.date withDateFormat:TimeFormatter]];
        [self.tableView reloadData];
    }else if (picker.tag == 200) {
        [config setEndTime:[NSDate datestrFromDate:datePicker.date withDateFormat:TimeFormatter]];
        [self.tableView reloadData];
    }
}
#pragma mark - 界面和数据初始化
- (void)configSubView {
    self.navigationItem.title = TS("Temporary_Password");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView {
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 250 ) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableView;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    titleArray = (NSMutableArray*)@[TS("No_disturb_manager"),TS("Alarm_message_push"),TS("Deep_Sleep"),TS("No_Disturb_Time_Set")];
}
- (UIDatePicker*)datePacker {
    if (picker == nil) {
        picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight-240, ScreenWidth, 160)];
        //设置类型
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        //设置日历
        picker.calendar = [NSCalendar currentCalendar];
        //设置设备的时区
        picker.timeZone = [NSTimeZone defaultTimeZone];
        //设置事件
        [picker addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return picker;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
