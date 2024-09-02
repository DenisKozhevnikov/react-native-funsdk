//
//  AutoCruiseVC.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/7/8.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "AutoCruiseVC.h"
#import "AutoCruiseConfig.h"
#import "ItemTableviewCell.h"
#import "MediaplayerControl.h"
#import "PlayView.h"
#import <Masonry/Masonry.h>

@interface AutoCruiseVC ()<UITableViewDelegate,UITableViewDataSource,MediaplayerControlDelegate,AutoCruiseConfigDelegate>

@property (nonatomic,strong) AutoCruiseConfig *autoCruiseCfg;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *pointArray;
@property (nonatomic,strong) MediaplayerControl *mediaControl;
@property (nonatomic,strong) PlayView *playview;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation AutoCruiseVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self cfgNav];
    
    [self cfgSubViews];
    
    [self.mediaControl start];
    [self.playview refreshView:0];
    [self.playview playViewBufferIng];
    
    [SVProgressHUD show];
    [self.autoCruiseCfg getTimingCfg:^(int result, NSDictionary *info) {
        [self.autoCruiseCfg getCruiseList];
    }];
}

//MARK: EventAction
- (void)cfgNav{
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    self.navigationItem.title = TS("Timed_Cruise");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}

- (void)cfgSubViews{
    [self.view addSubview:self.playview];
    [self.view addSubview:self.tableView];
    
    [self.playview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(self.view.mas_width).multipliedBy(0.75);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self.playview.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
}

- (void)popViewController{
    [self.mediaControl stop];
    [self.navigationController popViewControllerAnimated:YES];
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


//MARK: Delegate
//MARK: - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    NSString *title = [self.titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.Labeltext.text= @"";
    //252、253、254对应三个巡航点
    for (NSDictionary *info in self.pointArray) {
        if ([[info objectForKey:@"Id"] intValue] == (int)(indexPath.row + 252)) {
            
            cell.Labeltext.text = [NSString stringWithFormat:@"%d",[[info objectForKey:@"Id"] intValue]];
            return cell;
        }
    }
    
    if ([title isEqualToString:TS("开始巡航")]) { //开始巡航
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([title isEqualToString:TS("定时巡航开关")]) {
        [cell setCellType:cellTypeSwitch];
        cell.mySwitch.on = [self.autoCruiseCfg getTimingOpen];
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            //设置定时巡航开关
            [SVProgressHUD show];
            [self.autoCruiseCfg setTimingOpen:on];
            [self.autoCruiseCfg saveTimingCfg:^(int result, NSDictionary *info) {
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                }else{
                    [MessageUI ShowErrorInt:(int)result];
                }
            }];
        };
    }else if ([title isEqualToString:TS("定时巡航间隔")]) {
        cell.Labeltext.text = [NSString stringWithFormat:@"%dS",[self.autoCruiseCfg getInterval]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *titleStr = self.titleArray[indexPath.row];
    if ([titleStr isEqualToString:TS("巡航预置点1")]) {
        [self crisePoint:0];
    }else if ([titleStr isEqualToString:TS("巡航预置点2")]){
        [self crisePoint:1];
    }else if ([titleStr isEqualToString:TS("巡航预置点3")]){
        [self crisePoint:2];
    }else if ([titleStr isEqualToString:TS("定时巡航间隔")]){
        [self setTimeInterval];
    }
}

- (void)crisePoint:(int)index {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("巡航功能") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    //增删改巡航点时，需要判断对应点是否存在
    UIAlertAction *comfirmAction1 = [UIAlertAction actionWithTitle:TS("增加巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSDictionary *info in self.pointArray) {
            if ([[info objectForKey:@"Id"] intValue] == (int)(index + 252)) {
                //已经有 index+252 这个点，不能继续增加
                return;
            }
        }
        [SVProgressHUD show];
        //新增巡航点
        [self.autoCruiseCfg addPoint:index+252]; //252、253、254是默认巡航点id，可以自定义
    }];
    UIAlertAction *comfirmAction2 = [UIAlertAction actionWithTitle:TS("删除巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSDictionary *info in self.pointArray) {
            if ([[info objectForKey:@"Id"] intValue] == (int)(index + 252)) {
                //已经有 index+252 这个点，可以删除
                //删除巡航点
                [SVProgressHUD show];
                [self.autoCruiseCfg deletePoint:index+252];
            }
        }
    }];
    UIAlertAction *comfirmAction3 = [UIAlertAction actionWithTitle:TS("重置巡航点") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSDictionary *info in self.pointArray) {
            if ([[info objectForKey:@"Id"] intValue] == (int)(index + 252)) {
                //已经有 index+252 这个点，可以重置
                //重置巡航点
                [SVProgressHUD show];
                [self.autoCruiseCfg resetPoint:index+252];
            }
        }
    }];
//    UIAlertAction *comfirmAction4 = [UIAlertAction actionWithTitle:TS("跳转到这里") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        for (CruiseDataSource *source in pointArray) {
//            if (source.cruiseID == (int)(index + 252)) {
//                //已经有 index+252 这个点，可以跳转
//                [config FunGotoCruisePointWithNum:index+252];
//            }
//        }
//    }];
    [alert addAction:comfirmAction1];
    [alert addAction:comfirmAction2];
    [alert addAction:comfirmAction3];
//    [alert addAction:comfirmAction4];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// 处理时间间隔
- (void)setTimeInterval{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("定时巡航间隔") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    //增删改巡航点时，需要判断对应点是否存在
    UIAlertAction *comfirmAction1 = [UIAlertAction actionWithTitle:TS("300S") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [self.autoCruiseCfg setInterval:300];
        [self.autoCruiseCfg saveTimingCfg:^(int result, NSDictionary *info) {
            if (result >= 0) {
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }else{
                [MessageUI ShowErrorInt:(int)result];
            }
        }];
    }];
    UIAlertAction *comfirmAction2 = [UIAlertAction actionWithTitle:TS("1800S") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [self.autoCruiseCfg setInterval:1800];
        [self.autoCruiseCfg saveTimingCfg:^(int result, NSDictionary *info) {
            if (result >= 0) {
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }else{
                [MessageUI ShowErrorInt:(int)result];
            }
        }];
    }];
    UIAlertAction *comfirmAction3 = [UIAlertAction actionWithTitle:TS("3600S") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [self.autoCruiseCfg setInterval:3600];
        [self.autoCruiseCfg saveTimingCfg:^(int result, NSDictionary *info) {
            if (result >= 0) {
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }else{
                [MessageUI ShowErrorInt:(int)result];
            }
        }];
    }];
    //    UIAlertAction *comfirmAction4 = [UIAlertAction actionWithTitle:TS("跳转到这里") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        for (CruiseDataSource *source in pointArray) {
    //            if (source.cruiseID == (int)(index + 252)) {
    //                //已经有 index+252 这个点，可以跳转
    //                [config FunGotoCruisePointWithNum:index+252];
    //            }
    //        }
    //    }];
    [alert addAction:comfirmAction1];
    [alert addAction:comfirmAction2];
    [alert addAction:comfirmAction3];
    //    [alert addAction:comfirmAction4];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult{
    if (result >= 0) {
        [self.playview playViewBufferEnd];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

//MARK: 获取巡航点回调
- (void)OnGetAutoCruisePoint:(NSArray * _Nullable)points result:(int)result {
    if (result >=0) {
        [SVProgressHUD dismiss];
        self.pointArray = [points mutableCopy];
        [self.tableView reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: 设置巡航点回调
- (void)OnSetAutoCruisePoint:(int)num result:(int)result {
    if (result >=0) {
        [self.autoCruiseCfg getCruiseList];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: 删除回调
- (void)OnDeleteAutoCruisePoint:(int)num result:(int)result {
    if (result >=0) {
        //删除之后重新获取巡航点
        [self.autoCruiseCfg getCruiseList];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
    
}
//MARK: - LazyLoad
- (MediaplayerControl*)mediaControl {
    if (!_mediaControl) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        _mediaControl = [[MediaplayerControl alloc] init];
        _mediaControl.devID = channel.deviceMac;//设备序列号
        _mediaControl.channel = channel.channelNumber;//当前通道号
        _mediaControl.stream = 1;//辅码流
        _mediaControl.renderWnd = self.playview;
        _mediaControl.delegate = self;
        _mediaControl.index = 1000;
    }
    
    return _mediaControl;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    
    return _tableView;
}

- (PlayView*)playview {
    if (!_playview) {
        _playview = [[PlayView alloc] initWithFrame:CGRectZero];
        [_playview refreshView:0];
        [_playview playViewBufferIng];
        
        //playview增加滑动手势
        [self addSwipeGestureRecognizer];
    }
    
    return _playview;
}

- (NSMutableArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [@[TS("巡航预置点1"),TS("巡航预置点2"),TS("巡航预置点3"),TS("定时巡航开关"),TS("定时巡航间隔")] mutableCopy];
    }
    
    return _titleArray;
}

- (AutoCruiseConfig *)autoCruiseCfg{
    if (!_autoCruiseCfg) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        _autoCruiseCfg = [[AutoCruiseConfig alloc] init];
        _autoCruiseCfg.devID = channel.deviceMac;
        _autoCruiseCfg.delegate = self;
    }
    
    return _autoCruiseCfg;
}

@end
