//
//  VoiceBroadcastingViewController.m
//  FunSDKDemo
//
//  Created by plf on 2023/6/2.
//  Copyright © 2023 plf. All rights reserved.
//

#import "VoiceBroadcastingViewController.h"
#import "VoiceTimeSwitchCell.h"
#import <Masonry/Masonry.h>

#import "VoiceBroadcastingManager.h"

@interface VoiceBroadcastingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *timeTB;
@property(nonatomic,strong)NSArray *timeArray;

@property(nonatomic,strong)VoiceBroadcastingManager *voiceBroadcastingManager;

@end

static NSString *const kAlarmSwitchCellIdentifier = @"switchCell";

@implementation VoiceBroadcastingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = TS("TR_Voice_Broadcasting");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [rightBtn setBackgroundColor:[UIColor clearColor]];
    [rightBtn setTitle:TS("Add") forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.timeArray = @[];
    
    [self.view addSubview:self.timeTB];
    [self.timeTB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    
    [self getData];
    
}

-(void)getData
{
    [self.voiceBroadcastingManager getAllAudioClockList:^(NSDictionary * _Nonnull dic) {
        NSLog(@"%@",dic);
        
        if(dic.count >0)
        {
            self.timeArray = [NSArray arrayWithArray:dic[@"ListAllAudioClock"][@"AudioClockInfo"]];
            [self.timeTB reloadData];
        }
        
    }];
}

#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceTimeSwitchCell *cell = (VoiceTimeSwitchCell *)[tableView dequeueReusableCellWithIdentifier:kAlarmSwitchCellIdentifier];
    if (!cell) {
        cell = [[VoiceTimeSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAlarmSwitchCellIdentifier];
    }
    
    NSDictionary *infoDic = [[NSDictionary alloc]initWithDictionary:self.timeArray[indexPath.row]];
    
    cell.titleLabel = infoDic[@"AudioFile"];
    cell.toggleSwitch.on = [infoDic[@"Enable"] boolValue];
    cell.toggleSwitchStateChangedAction = ^(BOOL on) {
    };
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


-(UITableView *)timeTB
{
    if(!_timeTB)
    {
        _timeTB = [[UITableView alloc]init];
        _timeTB.delegate = self;
        _timeTB.dataSource = self;
        [_timeTB registerClass:[VoiceTimeSwitchCell class] forCellReuseIdentifier:@"switchCell"];
        _timeTB.tableFooterView = [UIView new];
    }
    return _timeTB;
}

-(VoiceBroadcastingManager *)voiceBroadcastingManager
{
    if(!_voiceBroadcastingManager)
    {
        _voiceBroadcastingManager = [[VoiceBroadcastingManager alloc]init];
        _voiceBroadcastingManager.devID = self.devID;
        _voiceBroadcastingManager.channelNum = self.channelNum;
    }
    
    return _voiceBroadcastingManager;
}

@end
