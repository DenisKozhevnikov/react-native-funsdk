//
//  CruiseViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2019/6/25.
//  Copyright © 2019 zhang. All rights reserved.
//

#define defaultNumber 3

#import "CruiseViewController.h"
#import "ItemTableviewCell.h"
#import "CruiseConfig.h"

#import "MediaplayerControl.h"
#import "PlayView.h"

@interface CruiseViewController ()<UITableViewDelegate,UITableViewDataSource,CruiseConfigDelegate,MediaplayerControlDelegate>
{
    CruiseConfig *config; //巡航
    UITableView *tableView;
    PlayView *playview;
    NSMutableArray *titleArray;
    NSMutableArray *pointArray;
    
    MediaplayerControl *mediaControl;
}
@end

@implementation CruiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubView];
    //初始化tableview数据
    [self initDataSource];
    
    [self getCruiseConfig];
    
    [self startPlay];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}
#pragma mark - 获取配置
- (void)getCruiseConfig {
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    if (config == nil) {
        config = [[CruiseConfig alloc] init];
        config.delegate = self;
        config.devID = channel.deviceMac;
        config.channel = channel.channelNumber;
    }
    [SVProgressHUD showWithStatus:TS("")];
    //获取巡航点
    [config FunGetCruisePoint];
    
    //如果支持移动追踪，则继续获取移动追踪数据
    if (device.sysFunction.SupportDetectTrack) {
        [config FungetDetectTrack];
    }
    //是否支持守望功能
    if (device.sysFunction.SupportSetDetectTrackWatchPoint) {
        
    }
}

//获取巡航点回调
- (void)OnGetCruisePoint:(NSArray * _Nullable)points result:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
        pointArray = [points mutableCopy];
        [self.tableView reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//设置巡航点回调
- (void)OnSetCruisePoint:(int)num result:(int)result {
    if (result >=0) {
        [config FunGetCruisePoint];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//删除回调
- (void)OnDeleteCruisePoint:(int)num result:(int)result {
    if (result >=0) {
        //删除之后重新获取巡航点
        [config FunGetCruisePoint];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
    
}
//跳转回调
- (void)OnGotoCruisePoint:(int)num result:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//开始巡航回调
- (void)OnStartCruiseWithResult:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//停止巡航回调
- (void)OnStopCruiseWithResult:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//获取移动追踪回调
- (void)OngetDetectTrackResult:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//移动追踪设置回调
- (void)OnsetDetectTrackResult:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
//添加守望点回调
- (void)setWatchPointResult:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
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
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.Labeltext.text= @"";
    //252、253、254对应三个巡航点
    for (CruiseDataSource *source in pointArray) {
        if (source.cruiseID == (int)(indexPath.row + 252)) {
            if ([source.cruiseName isEqualToString:@""]) {
                cell.Labeltext.text = [NSString stringWithFormat:@"%d",source.cruiseID];
            }else{
                cell.Labeltext.text = source.cruiseName;
            }
            return cell;
        }
    }
    
    if ([title isEqualToString:TS("开始巡航")]) { //开始巡航
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([title isEqualToString:TS("移动追踪开关")]) {
        [cell setCellType:cellTypeSwitch];
        cell.mySwitch.on = [config getTrackEnable];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            //设置移动追踪开关
            [SVProgressHUD show];
            [config setTrackEnable:on];
            [config setTrackConfig];
        };
    }else if ([title isEqualToString:TS("移动追踪灵敏度")]) { //0、1、2 对应低中高
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",[config getTrackSensitivity]];//灵敏度 0、1、2分别对应低、中、高
    }else if ([title isEqualToString:TS("巡航点停留时间")]) {
        cell.Labeltext.text = [NSString stringWithFormat:@"%d",[config getTrackReturnTime]];//单位秒 Second
    }else if ([title isEqualToString:TS("设置守望点")]) {
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *titleStr = titleArray[indexPath.row];
    if ([titleStr isEqualToString:TS("巡航预置点1")]) {
        [self crisePoint:0];
    }else if ([titleStr isEqualToString:TS("巡航预置点2")]){
        [self crisePoint:1];
    }else if ([titleStr isEqualToString:TS("巡航预置点3")]){
        [self crisePoint:2];
    }else if ([titleStr isEqualToString:TS("开始巡航")]){
        //3个点都已存在的情况下，可以开始
        if (pointArray.count == defaultNumber) {
            [config FunStartCruise];
        }else{
            [SVProgressHUD showErrorWithStatus:TS("请先滑动屏幕并设置3个预置点") duration:2];
        }
    }else if ([titleStr isEqualToString:TS("移动追踪灵敏度")]){
        [SVProgressHUD show];
        [config setTrackSensitivity:1]; //这里直接设置灵敏度中，可以根据需求设置或弹出选择界面
        [config setTrackConfig];
    }else if ([titleStr isEqualToString:TS("巡航点停留时间")]){
        [SVProgressHUD show];
        [config setTrackReturnTime:5]; //这里直接设置5s，可以根据需求设置或弹出选择界面选择时间
        [config setTrackConfig];
    }else if ([titleStr isEqualToString:TS("设置守望点")]){
        //添加守望点
        [SVProgressHUD show];
        [config setWatchPointWithNum:100];
    }
}

- (void)crisePoint:(int)index {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("巡航功能") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    //增删改巡航点时，需要判断对应点是否存在
    UIAlertAction *comfirmAction1 = [UIAlertAction actionWithTitle:TS("增加巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (CruiseDataSource *source in pointArray) {
            if (source.cruiseID == (int)(index + 252)) {
                //已经有 index+252 这个点，不能继续增加
                return;
            }
        }
        //新增巡航点
        [config FunAddCruisePointWithNum:index+252]; //252、253、254是默认巡航点id，可以自定义
    }];
    UIAlertAction *comfirmAction2 = [UIAlertAction actionWithTitle:TS("删除巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (CruiseDataSource *source in pointArray) {
            if (source.cruiseID == (int)(index + 252)) {
                //已经有 index+252 这个点，可以删除
                //删除巡航点
                [config FunDeleteCruisePointWithNum:index+252];
            }
        }
    }];
    UIAlertAction *comfirmAction3 = [UIAlertAction actionWithTitle:TS("重置巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (CruiseDataSource *source in pointArray) {
            if (source.cruiseID == (int)(index + 252)) {
                //已经有 index+252 这个点，可以重置
                //重置巡航点
                [config FunResetCruisePointWithNum:index+252];
            }
        }
    }];
    UIAlertAction *comfirmAction4 = [UIAlertAction actionWithTitle:TS("跳转到这里") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (CruiseDataSource *source in pointArray) {
            if (source.cruiseID == (int)(index + 252)) {
                //已经有 index+252 这个点，可以跳转
                [config FunGotoCruisePointWithNum:index+252];
            }
        }
    }];
    [alert addAction:comfirmAction1];
    [alert addAction:comfirmAction2];
    [alert addAction:comfirmAction3];
    [alert addAction:comfirmAction4];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startPlay {
    [self.mediaControl start];
}
#pragma mark - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult{
    if (result >= 0) {
        [self.playview playViewBufferEnd];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self.mediaControl controZStartlPTAction:TILT_DOWN];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mediaControl controZStopIPTAction:TILT_DOWN];
        });
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.mediaControl controZStartlPTAction:TILT_UP];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mediaControl controZStopIPTAction:TILT_UP];
        });
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.mediaControl controZStartlPTAction:PAN_LEFT];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mediaControl controZStopIPTAction:PAN_LEFT];
        });
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.mediaControl controZStartlPTAction:PAN_RIGHT];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mediaControl controZStopIPTAction:PAN_RIGHT];
        });
    }
}


#pragma mark - 界面和数据初始化
- (void)configSubView {
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    [self.view addSubview:self.playview];
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView {
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenWidth*3.0/4.0, ScreenWidth, ScreenHeight-ScreenWidth*3.0/4.0 -NavHeight) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableView;
}
- (PlayView*)playview {
    if (!playview) {
        playview = [[PlayView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth*3.0/4.0)];
        [playview refreshView:0];
        [playview playViewBufferIng];
        
        //playview增加滑动手势
        [self addSwipeGestureRecognizer];
    }
    return playview;
}

- (MediaplayerControl*)mediaControl {
    if (mediaControl == nil) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        mediaControl = [[MediaplayerControl alloc] init];
        mediaControl.devID = channel.deviceMac;//设备序列号
        mediaControl.channel = channel.channelNumber;//当前通道号
        mediaControl.stream = 1;//辅码流
        mediaControl.renderWnd = self.playview;
        mediaControl.delegate = self;
        mediaControl.index = 1000;
    }
    return mediaControl;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    //不支持守望点和移动追踪
    if(object.sysFunction.SupportSetDetectTrackWatchPoint == NO || object.sysFunction.SupportDetectTrack == NO ){
        titleArray = (NSMutableArray*)@[TS("巡航预置点1"),TS("巡航预置点2"),TS("巡航预置点3"),TS("开始巡航")];
    }else{
        titleArray = (NSMutableArray*)@[TS("巡航预置点1"),TS("巡航预置点2"),TS("巡航预置点3"),TS("开始巡航"),TS("移动追踪开关"),TS("移动追踪灵敏度"),TS("巡航点停留时间"),TS("设置守望点")];
    }
    
    pointArray = [[NSMutableArray alloc] initWithCapacity:defaultNumber];
}

- (void)addSwipeGestureRecognizer {
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [right setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.playview addGestureRecognizer:right];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [left setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.playview addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [up setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.playview addGestureRecognizer:up];
    
    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [down setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.playview addGestureRecognizer:down];
}
- (void)popViewController {
    [self.mediaControl stop];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
