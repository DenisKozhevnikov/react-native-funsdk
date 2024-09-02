//
//  IPCHumanDetectionViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/7/4.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "IPCHumanDetectionViewController.h"
#import "IPCHumanDetectionConfig.h"
#import "ItemTableviewCell.h"
#import "EncodeItemViewController.h"

@interface IPCHumanDetectionViewController ()<UITableViewDataSource,UITableViewDelegate,IPCHumanDetectionDelegate>
{
    NSMutableArray *titleArray;                          //人形检测数组
    UITableView *tableView;                              //人形检测列表
    IPCHumanDetectionConfig *functionConfig;
}

@end


@implementation IPCHumanDetectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据和界面
    [self initDataSource];
    [self configSubView];
    //设置导航栏
    [self setNaviStyle];
    //获取配置
    [self getConfig];
}

-(void)viewWillDisappear:(BOOL)animated{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("appEventHumanDetectAlarm");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
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
    
    int enable = 0;
    if ([title isEqualToString:TS("Alarm_function")]) {
        enable = [functionConfig getHumanDetectEnable];
    }
    else if ([title isEqualToString:TS("Analyzer_Rule")]){ //警戒规则开关 //是否显示拌线区域
        enable = [functionConfig getHumanDetectShowRule];
    }
    else if ([title isEqualToString:TS("Analyzer_Trace")]){ //警戒轨迹开关 //是否显示报警轨迹
        enable = [functionConfig getHumanDetectShowTrack];
    }
    
    cell.Labeltext.text = enable == 0 ? TS("close"):TS("open");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = titleArray[indexPath.row];
    //初始化各个配置的item单元格
    EncodeItemViewController *itemVC = [[EncodeItemViewController alloc] init];
    [itemVC setTitle:titleStr];
    
    __weak typeof(self) weakSelf = self;
    itemVC.itemSelectStringBlock = ^(NSString *encodeString) {
        //itemVC的单元格点击回调,设置各种属性
        ItemTableviewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
        cell.Labeltext.text = encodeString;
    };
    [itemVC setValueArray:[@[TS("close"),TS("open")] mutableCopy]];
    [self.navigationController pushViewController:itemVC animated:YES];
}

#pragma mark - 保存配置
-(void)saveConfig{
    [SVProgressHUD show];
    for (int i = 0; i < titleArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        ItemTableviewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *valueStr = cell.Labeltext.text;
        NSString *title = [titleArray objectAtIndex:i];
        int enable = 0;
        if ([valueStr isEqualToString:TS("open")]) {
            enable = 1;
        }
        if ([title isEqualToString:TS("Alarm_function")]) {
            [functionConfig setHumanDetectEnable:enable];
        }
        else if ([title isEqualToString:TS("Analyzer_Rule")]){
            [functionConfig setHumanDetectShowRule:enable];
        }
        else if ([title isEqualToString:TS("Analyzer_Trace")]){
            [functionConfig setHumanDetectShowTrack:enable];
        }
    }
    
    [functionConfig SetConfig];
}

#pragma mark - 获取人形检测配置
-(void)getConfig{
    [SVProgressHUD show];
    if (!functionConfig) {
        functionConfig = [[IPCHumanDetectionConfig alloc] init];
        functionConfig.delegate = self;
    }
    [functionConfig getHumanDetectionConfig];
}

#pragma mark - 获取配置回调
-(void)IPCHumanDetectionConfigGetResult:(NSInteger)result{
    if (result >= 0) {
        //成功，刷新界面数据
        [tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

-(void)IPCHumanDetectionConfigSetResult:(NSInteger)result{
    if (result >= 0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

- (void)configSubView {
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
-(void)initDataSource {
    //报警开关、警戒类型、警戒规则开关、警戒轨迹开关
    titleArray = [[NSMutableArray alloc] initWithObjects:TS("Alarm_function"),TS("Analyzer_Rule"),TS("Analyzer_Trace"),nil];
}

@end
