//
//  ConfigListView.m
//  FunSDKDemo
//
//  Created by plf on 2023/4/27.
//  Copyright © 2023 plf. All rights reserved.
//

#import "ConfigListView.h"
#import "SelectItemCell.h"
#import "UIColor+Util.h"
#import <Masonry/Masonry.h>

@interface  ConfigListView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *configListTB;
@property(nonatomic,strong)NSArray *configListArray;
@property(nonatomic,strong)NSMutableArray *selectArray;

@property(nonatomic,strong)UIButton *confirmBtn;

@end

@implementation ConfigListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];
        
        self.configListArray = @[@"cpu",     //CPU占用率
                                 @"mem",     //内存使用率
                                 @"disk",    //磁盘使用率
                                 @"strg",    //Storage，磁盘容量等
                                 @"pksz",    //Packet剩余大小
                                 @"lpwt",    //最近一次关机时间
                                 @"lpwr",    //最近一次重启原因
                                 @"swv",     //主控软件版本
                                 @"swrt",    //主控软件发布时间
                                 @"mpv",     //单片机程序版本
                                 @"dpv",     //锁板程序版本
                                 @"swl",     //WiFi信号强度
                                 @"ss4g",    //4G/5G（蜂窝网络）信号强度
                                 @"bs",      //电池状态
                                 @"bl",      //电池电量
                                 @"bas",     //辅电池状态
                                 @"bal",     //辅助电池电量
                                 @"cnum",    //客户端连接数
                                 @"sds",     //TF/SD状态
                                 @"sdfc",    //TF/SD卡剩余容量
                                 @"wkr",     //唤醒原因
                                 @"chmx",    //最大支持通道个数
                                 @"SystemFunction",     //设备系统功能
                                 @"EncodeCapability",   //设备编码能力
                                 @"SupportExtRecord",   //设备录像模式
                                 @"Camera",             //设备摄像机参数
                                 @"System.Sleep",     //省电模式（选择项：1、触发模式；2、监控模式；3、图传模式）
                                 @"Consumer.SwitchWifiMode",//3861L双向模式(选择项：0、双向；1、单项)：
        ];
        
                
        self.selectArray = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] valueForKey:@"ShadowConfigSelect"]mutableCopy]];
        
        if(self.selectArray.count == 0)
        {
            for (int i = 0; i<self.configListArray.count; i++) {
                [self.selectArray addObject:@"0"];
            }
        }
    }
    return self;
}

-(void)showSelectView
{
    [self addSubview:self.configListTB];
    [self.configListTB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.8);
        make.height.equalTo(self).multipliedBy(0.5);
    }];
    
    [self addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.configListTB);
        make.top.equalTo(self.configListTB.mas_bottom);
        make.height.mas_equalTo(44);
    }];
}

-(void)dismissView
{
    [self removeFromSuperview];
}


#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.lbTitle.text = self.configListArray[indexPath.row];
    
    cell.ifSelected = [self.selectArray[indexPath.row] intValue]==0?NO:YES;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.selectArray replaceObjectAtIndex:indexPath.row withObject:[self.selectArray[indexPath.row] intValue] == 0?@"1":@"0"];
    
    
    SelectItemCell *cell = [self.configListTB cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    cell.ifSelected = cell.ifSelected?NO:YES;
}

-(void)confirmToConfig
{
    NSString *configStr = @"";
    for (int i = 0; i<self.selectArray.count; i++) {
        if([self.selectArray[i] intValue] == 1)
        {
            if(configStr.length == 0)
            {
                configStr = [NSString stringWithFormat:@"\"%@\"",self.configListArray[i]];
            }
            else
            {
                configStr = [NSString stringWithFormat:@"%@,\"%@\"",configStr,self.configListArray[i]];
            }
        }
    }
    
    if(configStr.length > 0)
    {
        configStr = [NSString stringWithFormat:@"[%@]",configStr];
    }
    
    if(self.addConfigBlock)
    {
        self.addConfigBlock(configStr);
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:self.selectArray forKey:@"ShadowConfigSelect"];
    
    [self dismissView];
    
}

-(UITableView *)configListTB
{
    if(!_configListTB)
    {
        _configListTB = [[UITableView alloc]init];
        _configListTB.delegate = self;
        _configListTB.dataSource = self;
        [_configListTB registerClass:[SelectItemCell class] forCellReuseIdentifier:@"Cell"];
        _configListTB.tableFooterView = [UIView new];
    }
    
    return _configListTB;
}

-(UIButton *)confirmBtn
{
    if(!_confirmBtn)
    {
        _confirmBtn = [[UIButton alloc]init];
        [_confirmBtn setTitle:TS("OK") forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_confirmBtn setBackgroundColor:[UIColor whiteColor]];
        [_confirmBtn addTarget:self action:@selector(confirmToConfig) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmBtn;
}

@end
