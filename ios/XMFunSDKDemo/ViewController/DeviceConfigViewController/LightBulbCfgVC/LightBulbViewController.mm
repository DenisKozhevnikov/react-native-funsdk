//
//  LightBulbViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/12/10.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "LightBulbViewController.h"
#import "ItemTableviewCell.h"
#import "ItemViewController.h"
#import "LightBulbConfig.h"

@interface LightBulbViewController () <UITableViewDelegate,UITableViewDataSource,WhiteLightConfigDelegate>
{
    LightBulbConfig *config;
    UITableView *recordTableView;
    NSMutableArray *titleArray;
}
@end

@implementation LightBulbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    [self initDataSource];
    [self configSubView];
    //请求配置
    [self getConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取灯泡配置
- (void)getConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[LightBulbConfig alloc] init];
        config.delegate = self;
    }
    //调用获取配置的接口
    [config getDeviceConfig];
}

#pragma mark 获取配置代理回调
- (void)getWhiteLightConfigResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.recordTableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存配置
-(void)saveConfig{
    [SVProgressHUD show];
    [config setDeviceConfig];
}

#pragma mark 保存配置代理回调
- (void)setWhiteLightConfigResult:(NSInteger)result {
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
    if ([title isEqualToString:TS("WorkMode")]) { //工作模式
        NSString *modeValue = [config getWorkMode];
        if (!modeValue || modeValue.length == 0) {
            return cell;
        }
        NSInteger index = [[self getLightModeValueArray] indexOfObject:modeValue];
        cell.Labeltext.text = [self getLightModeArray][index];
    }else if ([title isEqualToString:TS("lightbrightness")]) { //亮度
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",[config getLightBrightness]];
    }else if ([title isEqualToString:TS("WorkPeriod")]) { //时间段开关
        cell.Labeltext.text = [self getLightEnableArray][[config getWorkPeriodEnable]];
    }else if ([title isEqualToString:TS("WorkPeriodStart")]) { //开始时间
        int sHour = [config getWorkPeriodSHour];
        int sMinute = [config getWorkPeriodSMinute];
        cell.Labeltext.text = [NSString stringWithFormat:@"%02d:%02d",sHour,sMinute];
    }else if ([title isEqualToString:TS("WorkPeriodEnd")]) { //结束时间
         int eHour = [config getWorkPeriodEHour];
         int eMinute = [config getWorkPeriodEMinute];
        cell.Labeltext.text = [NSString stringWithFormat:@"%02d:%02d",eHour,eMinute];
    }else if ([title isEqualToString:TS("LightDuration")]) { //持续亮灯时间
       cell.Labeltext.text = [NSString stringWithFormat:@"%ds",[config getMoveTrigLightDuration]];
    }else if ([title isEqualToString:TS("LightLevel")]) { //灵敏度
        cell.Labeltext.text = [self getLevelString:[config getMoveTrigLightLevel]];
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
        ItemTableviewCell *cell = [weakSelf.recordTableView cellForRowAtIndexPath:indexPath];
        cell.Labeltext.text = encodeString;
        if ([cell.textLabel.text isEqualToString:TS("WorkMode")]) {
            NSInteger index = [[self getLightModeArray] indexOfObject:encodeString];
            NSString *value = [self getLightModeValueArray][index];
             [config setWorkMode:value];
        }else if ([cell.textLabel.text isEqualToString:TS("WorkPeriod")]){
            [config setWorkPeriodEnable:[[self getLightEnableArray] indexOfObject:encodeString]];
        }else if ([cell.textLabel.text isEqualToString:TS("LightDuration")]){
            [config setMoveTrigLightDuration:[encodeString intValue]];
        }else if ([cell.textLabel.text isEqualToString:TS("LightLevel")]){
            NSInteger index = [[self getLightLevelArray] indexOfObject:encodeString];
            NSString *value = [self getLightLevelValueArray][index];
             [config setMoveTrigLightLevel:[value intValue]];
        }else{
            return;
        }
    };
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("WorkMode")]) {
        NSMutableArray *array = [[self getLightModeArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("lightbrightness")]){
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("lightbrightness") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"0-100";
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *hourTextField = alert.textFields.firstObject;
            int brightness = [hourTextField.text intValue];
            [config setLightBrightness:brightness];
            ItemTableviewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.Labeltext.text = [NSString stringWithFormat:@"%d",brightness];
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }else if ([titleStr isEqualToString:TS("WorkPeriod")]){
        NSMutableArray *array = [[self getLightEnableArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("LightDuration")]){
        NSMutableArray *array = [[self getLightDurationArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("LightLevel")]){
        NSMutableArray *array = [[self getLightLevelArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("WorkPeriodStart")]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("WorkPeriodStart") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = TS("h");
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = TS("m");
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *hourTextField = alert.textFields.firstObject;
            UITextField *minuteTextField = alert.textFields.lastObject;
            int sHour = [hourTextField.text intValue];
            int sMinute = [minuteTextField.text intValue];
            [config setWorkPeriodSHour:sHour];
            [config setWorkPeriodSMinute:sMinute];
            ItemTableviewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.Labeltext.text = [NSString stringWithFormat:@"%02d:%02d",sHour,sMinute];;
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }else if ([titleStr isEqualToString:TS("WorkPeriodEnd")]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("WorkPeriodEnd") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = TS("h");
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = TS("m");
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *hourTextField = alert.textFields.firstObject;
            UITextField *minuteTextField = alert.textFields.lastObject;
            int eHour = [hourTextField.text intValue];
            int eMinute = [minuteTextField.text intValue];
            [config setWorkPeriodEHour:eHour];
            [config setWorkPeriodEMinute:eMinute];
            ItemTableviewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.Labeltext.text = [NSString stringWithFormat:@"%02d:%02d",eHour,eMinute];;
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }else{
        return;
    }
    //如果赋值成功，跳转到下一级界面
    [self.navigationController pushViewController:itemVC animated:YES];
}

#pragma mark - 界面和数据初始化
- (void)configSubView {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.recordTableView];
}
- (UITableView *)recordTableView {
    if (!recordTableView) {
        recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight ) style:UITableViewStylePlain];
        recordTableView.delegate = self;
        recordTableView.dataSource = self;
        [recordTableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return recordTableView;
}
- (void)initDataSource {
    titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [titleArray addObject:TS("lightbrightness")];
    [titleArray addObject:TS("WorkMode")];
    [titleArray addObject:TS("WorkPeriod")];
    [titleArray addObject:TS("WorkPeriodStart")];
    [titleArray addObject:TS("WorkPeriodEnd")];
    [titleArray addObject:TS("LightDuration")];  //这两个配置只有在 Intelligent(双光灯支持)模式下生效
    [titleArray addObject:TS("LightLevel")];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString*)getLevelString:(int)value {
    if (value <= 2) {
        return [self getLightLevelArray][0];
    }
    if (value <= 4) {
        return [self getLightLevelArray][1];
    }else{
        return [self getLightLevelArray][2];
    }
}
- (NSArray *)getLightModeValueArray {
    NSArray *array = @[@"Auto", @"Timming", @"KeepOpen", @"Intelligent", @"Atmosphere", @"Glint", @"Close"];
    return array;
}
- (NSArray *)getLightModeArray {
    NSArray *array = @[TS("lightAuto"), TS("lightTimming"), TS("lightKeepOpen"), TS("lightIntelligent"), TS("lightAtmosphere"), TS("lightGlint"), TS("lightClose")];
    return array;
}
- (NSArray *)getLightLevelValueArray {
    NSArray *array = @[@"1", @"3", @"5"];
    return array;
}
- (NSArray *)getLightLevelArray {
    NSArray *array = @[TS("Alarm_Lower"), TS("Alarm_Middle"), TS("Alarm_Anvanced")];
    return array;
}
- (NSArray *)getLightDurationArray {
    NSArray *array = @[@"5", @"30", @"120"];
    return array;
}
- (NSArray *)getLightEnableArray {
    NSArray *array = @[TS("close"), TS("open")];
    return array;
}

@end
