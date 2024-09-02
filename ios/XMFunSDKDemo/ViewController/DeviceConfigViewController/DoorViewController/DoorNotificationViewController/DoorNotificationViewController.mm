//
//  DoorNotificationViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/23.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorNotificationViewController.h"
#import "DoorNotificationConfig.h"
#import "ItemTableviewCell.h"

@interface DoorNotificationViewController ()
<UITableViewDelegate,UITableViewDataSource,DoorNotificationDelegate>
{
    DoorNotificationConfig *config; //推送管理
    UITableView *tableView;
    NSMutableArray *titleArray;
    NSMutableArray *dataArray;
}
@end

@implementation DoorNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取门锁推送管理
    [self getDoorNotificationConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取门锁推送管理
- (void)getDoorNotificationConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[DoorNotificationConfig alloc] init];
        config.delegate = self;
    }
    //调用获取门锁推送管理的接口
    [config getDoorNotificationConfig];
}
#pragma mark 获取门锁推送管理代理回调
- (void)DoorNotificationConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [dataArray addObject:[config getPasswordAdmin]];
        [dataArray addObject:[config getPasswordGeneral]];
        [dataArray addObject:[config getPasswordGuest]];
        [dataArray addObject:[config getPasswordTemporary]];
        [dataArray addObject:[config getPasswordForce]];
        //获取数据
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存门锁推送管理
-(void)saveConfig{
    [SVProgressHUD show];
    [config setPasswordAdmin:[dataArray firstObject]];
    [config setPasswordGeneral:[dataArray objectAtIndex:1]];
    [config setPasswordGuest:[dataArray objectAtIndex:2]];
    [config setPasswordTemporary:[dataArray objectAtIndex:3]];
    [config setPasswordForce:[dataArray lastObject]];
    [config setDoorNotificationConfig];
}
#pragma mark 保存门锁推送管理代理回调
- (void)DoorNotificationConfigSetResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array =  [dataArray objectAtIndex:section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableArray *array =  [[dataArray objectAtIndex:indexPath.section] mutableCopy];
    NSMutableDictionary *dic = [[array objectAtIndex:indexPath.row] mutableCopy];
    
    NSString *title = [dic objectForKey:@"name"];
    NSNumber *enable = [dic objectForKey:@"enable"];
    cell.textLabel.text = title;
    [cell setCellType:cellTypeSwitch];
    [cell.mySwitch setOn:[enable boolValue]];
    cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
        [dic setObject:[NSNumber numberWithBool:on] forKey:@"enable"];
        [array replaceObjectAtIndex:indexPath.row withObject:dic];
        [dataArray replaceObjectAtIndex:indexPath.section withObject:array];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = titleArray[indexPath.row];
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("No_disturb_manager")]) { //免打扰
    }else if ([titleStr isEqualToString:TS("Alarm_message_push")]) {
    }else if ([titleStr isEqualToString:TS("Deep_Sleep")]) {
    }else if ([titleStr isEqualToString:TS("No_Disturb_Time_Set")]) {
    }else{
        return;
    }
}

#pragma mark - 界面和数据初始化
- (void)configSubView {
    self.navigationItem.title = TS("Alarm_message_push");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
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
    titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
