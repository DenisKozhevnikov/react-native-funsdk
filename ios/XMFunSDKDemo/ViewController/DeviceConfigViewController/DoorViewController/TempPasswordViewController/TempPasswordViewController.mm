//
//  TempPasswordViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "TempPasswordViewController.h"
#import "DoorTempPasswordConfig.h"
#import "ItemTableviewCell.h"

#import "NSDate+TimeCategory.h"

@interface TempPasswordViewController ()
<UITableViewDelegate,UITableViewDataSource,DoorTempPasswordDelegate>
{
    DoorTempPasswordConfig *config; //临时密码
    UITableView *tableView;
    NSMutableArray *titleArray;
    
    UIDatePicker *picker;
}
@end

@implementation TempPasswordViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取门锁临时密码
    [self getDoorDevListConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取门锁临时密码
- (void)getDoorDevListConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[DoorTempPasswordConfig alloc] init];
        config.delegate = self;
    }
    //调用获取门锁临时密码的接口
    [config getDoorDevListConfig];
}
#pragma mark 获取门锁临时密码代理回调
- (void)tempPasswordConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存门锁临时密码 （
-(void)saveConfig{
    //1、临时密码需要是6位数字
    //2、有效次数需要 >=1
    //3、起始时间短需要早于结束时间段
    //4、结束时间短段需要比当前时间晚
    //5、超出结束时间段后或者有效次数用尽后，临时密码失效，不再能查询到
    [SVProgressHUD show];
    [config setDoorTempPassword];
}
#pragma mark 保存门锁临时密码代理回调
- (void)tempPasswordConfigSetResult:(NSInteger)result {
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
    if ([title isEqualToString:TS("Temporary_Password")]) { //临时密码
        cell.Labeltext.text =  [config getPassword];
    }
    if ([title isEqualToString:TS("Effective_Count")]) {//临时密码有效次数
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",[config getPasswordNumber]];
    }
    if ([title isEqualToString:TS("Start_Time_Of_Effective_Period")]) { //有效起始时间
        cell.Labeltext.text = [config getStartTime];
    }
    if ([title isEqualToString:TS("End_Time_Of_Effective_Period")]) { //有效结束时间
        cell.Labeltext.text = [config getEndTime];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = titleArray[indexPath.row];
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("Temporary_Password")]) {
       //重新设置密码
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("Input_Six_Password_Tip") message:TS("Input_Six_Password_Tip_Description") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //密码需要长度为6的数字
            NSString *timeStr = [alert.textFields firstObject].text;
            if (timeStr != nil || timeStr.length == 6) {
                //设置门锁临时开门密码
                [config setPassword:timeStr];
                [self.tableView reloadData];
            }
        }];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:cancelAction];
        [alert addAction:comfirmAction];
        [alert.textFields firstObject].keyboardType = UIKeyboardTypeNumberPad;
        [self presentViewController:alert animated:YES completion:nil];
    }else if ([titleStr isEqualToString:TS("Effective_Count")]) {
        //有效次数
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("Effective_Count") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //密码需要长度为6的数字
            NSString *timeStr = [alert.textFields firstObject].text;
            if (timeStr != nil || timeStr.length > 0) {
                //设置门锁临时开门密码
                [config setPasswordNumber:[timeStr intValue]];
                [self.tableView reloadData];
            }
        }];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:cancelAction];
        [alert addAction:comfirmAction];
        [alert.textFields firstObject].keyboardType = UIKeyboardTypeNumberPad;
        [self presentViewController:alert animated:YES completion:nil];
    }else if ([titleStr isEqualToString:TS("Start_Time_Of_Effective_Period")]) {
        //开始时间
        NSString *timeStart = [config getStartTime];
        if (timeStart == nil) {
            [self datePacker].date = [NSDate date];
        }else{
            [self datePacker].date = [NSDate dateFromString:timeStart format:TimeFormatter];
        }
        [self datePacker].tag = 100;
        [self.view addSubview:[self datePacker]];
    }else if ([titleStr isEqualToString:TS("End_Time_Of_Effective_Period")]) {
        //结束时间
        NSString *timeEnd = [config getEndTime];
        if (timeEnd == nil) {
            [self datePacker].date = [NSDate date];
        }else{
            [self datePacker].date = [NSDate dateFromString:timeEnd format:TimeFormatter];
        }
        [self datePacker].tag = 200;
        [self.view addSubview:[self datePacker]];
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
    titleArray = (NSMutableArray*)@[TS("Temporary_Password"),TS("Effective_Count"),TS("Start_Time_Of_Effective_Period"),TS("End_Time_Of_Effective_Period")];
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
