//
//  ByFileViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/11/14.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "ByFileViewController.h"
#import "VideoFileConfig.h" //录像查询接口类
#import "DownloadViewController.h" //录像下载
#import "ItemTableviewCell.h"


@interface ByFileViewController () <UITableViewDelegate, UITableViewDataSource, VideoFileConfigDelegate>
{
    VideoFileConfig *config;
    UITableView *tableV;
    NSMutableArray *recordArray;
    
    NSMutableArray *normalVideoArray; //普通录像数组
    NSMutableArray *alarmVideoArray;  //报警录像数组
}

@property(nonatomic,strong)UIView *selectBackView;  //选择按钮背景view
@property(nonatomic,strong)UIButton *normalBtn;  //普通录像按钮
@property(nonatomic,strong)UIButton *alarmBtn;  //报警录像按钮
@property(nonatomic,strong)UIButton *allVideoBtn;  //全部录像按钮
@end

@implementation ByFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    [self getVideoFileConfig];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 按文件查询设备录像信息
- (void)getVideoFileConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[VideoFileConfig alloc] init];
        config.delegate = self;
    }
     //调用按文件查询录像的接口,查询今天的设备录像，可以自己设置日期进行查询
    [config getDeviceVideoByFile:[NSDate date]];

//    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
//    }];
}
#pragma mark 获取摄像机录像代理回调
- (void)getVideoResult:(NSInteger)result {
    if (result >= 0) {
        [SVProgressHUD dismiss];
        recordArray =[config getVideoFileArray:TYPE_NONE];
        //成功，刷新界面数据
        [self.tableV reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

-(void)normalBtnClick
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (RecordInfo *info in [config getVideoFileArray:TYPE_NONE]) {
        if ([info.fileName containsString:@"[R]"]) {
            [array addObject:info];
        }
    }
    
    recordArray = [array mutableCopy];
    [self.tableV reloadData];
}

-(void)alarmBtnClick
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (RecordInfo *info in [config getVideoFileArray:TYPE_NONE]) {
        if (![info.fileName containsString:@"[R]"]) {
            [array addObject:info];
        }
    }
    
    recordArray = [array mutableCopy];
    [self.tableV reloadData];
}

-(void)allVideoBtnClick
{
    recordArray =[config getVideoFileArray:TYPE_NONE];
    //成功，刷新界面数据
    [self.tableV reloadData];
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    RecordInfo *record = [recordArray objectAtIndex:indexPath.row];
    cell.textLabel.text = record.fileName;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //点击下载录像
    DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
    [self.navigationController pushViewController:downloadVC animated:YES];
    RecordInfo *record = [recordArray objectAtIndex:indexPath.row];
    [downloadVC startDownloadRecord:record];
    
}


#pragma mark - 界面和数据初始化
- (void)configSubView {
    [self.view addSubview:self.tableV];
    [self.view addSubview:self.selectBackView];
    [self.selectBackView addSubview:self.normalBtn];
    [self.selectBackView addSubview:self.alarmBtn];
    [self.selectBackView addSubview:self.allVideoBtn];
    
    [self.normalBtn setCenter:CGPointMake(ScreenWidth/4, 20)];
    [self.alarmBtn setCenter:CGPointMake(ScreenWidth/4*2, 20)];
    [self.allVideoBtn setCenter:CGPointMake(ScreenWidth/4*3, 20)];
}
- (UITableView *)tableV {
    if (!tableV) {
        tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-40 ) style:UITableViewStylePlain];
        tableV.delegate = self;
        tableV.dataSource = self;
        [tableV registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableV;
}

-(UIView *)selectBackView
{
    if (!_selectBackView) {
        _selectBackView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight-40, ScreenWidth, 40)];
        [_selectBackView setBackgroundColor:UIColor.whiteColor];
    }
    return _selectBackView;;
}

-(UIButton *)normalBtn
{
    if (!_normalBtn) {
        _normalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        [_normalBtn setTitle:TS("Alarm_normal") forState:UIControlStateNormal];
        [_normalBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_normalBtn addTarget:self action:@selector(normalBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _normalBtn;
}

-(UIButton *)alarmBtn
{
    if (!_alarmBtn) {
        _alarmBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        [_alarmBtn setTitle:TS("Alarm_video") forState:UIControlStateNormal];
        [_alarmBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_alarmBtn addTarget:self action:@selector(alarmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alarmBtn;
}

-(UIButton *)allVideoBtn
{
    if (!_allVideoBtn) {
        _allVideoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        [_allVideoBtn setTitle:TS("TR_All_Video") forState:UIControlStateNormal];
        [_allVideoBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_allVideoBtn addTarget:self action:@selector(allVideoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allVideoBtn;
}

#pragma mark - 界面和数据初始化
- (void)initDataSource {
    recordArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
