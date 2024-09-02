//
//  HumanDetectionForIPCViewController.m
//  XMEye
//
//  Created by 杨翔 on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "FunSDK/FunSDK.h"
#import "IntelViewController.h"
#import "HumanDetectionForIPCViewController.h"
#import "SVProgressHUD.h"
#import <Masonry/Masonry.h>

@interface HumanDetectionForIPCViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UISwitch *humanDetectionSwitch;

@property (nonatomic, strong) UISwitch *showTrackSwitch;

@property (nonatomic, strong) UITableView *ruleTableView;

@property (nonatomic, strong) UISwitch *pedRuleSwitch;

@property (nonatomic,strong) UIBarButtonItem *addBtn;

@property (nonatomic, assign) BOOL pedRuleAbility;

// IPC人形检测
@property (nonatomic, strong) NSMutableDictionary *humanDetectionDic;

///0:RuleLine  1:RuleRegion
@property (nonatomic, assign) int RuleType;

//showTrack能力级(是否要显示踪迹)
@property (nonatomic, assign) BOOL showTrack;

/**
 下面几个参数控制区域人形检测
 */

@property (nonatomic, assign) BOOL supportArea;

//区域方向
@property (nonatomic, strong) NSMutableArray* areaDirectArray;

//区域形状(一个数组  里面值多少就是支持集中类型   比如：@[3，4，5],就是支持四边形，五边形和六边形)
@property (nonatomic, strong) NSMutableArray* areaLineArray;


/**
 下面几个参数控制线性人形检测
 */

@property (nonatomic, assign) BOOL supportLine;
//线性方向
@property (nonatomic, strong) NSMutableArray* lineDirectArray;

@property (nonatomic,assign) int msgHandle;

@property (nonatomic,assign) int alarmDirection;    // 报警线类型
@property (nonatomic,assign) int areaPointNum;      // 报警区域类型

@end

@implementation HumanDetectionForIPCViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    
    self.RuleType = 0;
    self.areaLineArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.lineDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.areaDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //创建导航栏
    [self configNav];
    
    [self configSubView];
    
    [self initParam];
    
    FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 1360, "HumanRuleLimit", 4096, 20000, NULL, 0, -1, -1);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getHumanDetection];
}

-(void)getHumanDetection{
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "Detect.HumanDetection", 0,self.channelNum);
    [SVProgressHUD show];
}

-(void)saveChange{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.humanDetectionDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"Detect.HumanDetection",[strValues UTF8String] ,(int)[strValues length]+1,self.channelNum);
    [SVProgressHUD showWithStatus:TS("Saving")];
}

#pragma mark -- OnFunSDKResult
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    if (msg->id == EMSG_DEV_GET_CONFIG_JSON ) {
        if (msg->param1 < 0) {
            [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
            [self btnBackClicked];
        }else{
            if (msg->pObject == NULL) {
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
            if ( data == nil ){
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil) {
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            [SVProgressHUD dismiss];
            NSString* strConfigName = [appData valueForKey:@"Name"];
            if ([strConfigName containsString:[NSString stringWithFormat:@"Detect.HumanDetection.[%d]",self.channelNum]]) {
                self.humanDetectionDic = [[appData objectForKey:strConfigName] mutableCopy];
                [self.humanDetectionSwitch setOn:[[self.humanDetectionDic objectForKey:@"Enable"] boolValue]];
                [self.showTrackSwitch setOn:[[self.humanDetectionDic objectForKey:@"ShowTrack"] boolValue]];
                NSArray *pedRuleArray = [self.humanDetectionDic objectForKey:@"PedRule"];
                self.pedRuleAbility = [[[pedRuleArray objectAtIndex:0] objectForKey:@"Enable"] boolValue];
                [self.pedRuleSwitch setOn:self.pedRuleAbility];
                if (pedRuleArray.count > 0) {
                    self.RuleType = [[[pedRuleArray firstObject] objectForKey:@"RuleType"] intValue];
                }
                
                // 去除报警线类型和区域类型
                self.alarmDirection = [[[[pedRuleArray objectAtIndex:0] objectForKey:@"RuleLine"] objectForKey:@"AlarmDirect"] intValue];
                self.areaPointNum = [[[[pedRuleArray objectAtIndex:0] objectForKey:@"RuleRegion"] objectForKey:@"PtsNum"] intValue];
                
                [self.ruleTableView reloadData];
            }
        }
    }else if (msg->id ==EMSG_DEV_SET_CONFIG_JSON){
        [SVProgressHUD dismiss];
        if (msg->param1 < 0) {
            [SVProgressHUD showErrorWithStatus:TS("Save_Failed")];
        }else{
            if( strcmp(msg->szStr, [[NSString stringWithFormat:@"Detect.HumanDetection"] UTF8String])==0 ){
                [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
            }
        }
    }else if (msg->id == EMSG_DEV_CMD_EN){
        if (msg->param1 < 0) {
            [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
            [self btnBackClicked];
        }else{
            if (msg->pObject == NULL) {
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
            if ( data == nil ){
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil) {
                [SVProgressHUD showErrorWithStatus:TS("get_config_f")];
                [self btnBackClicked];
            }
            [SVProgressHUD dismiss];
            NSString* strConfigName = [appData valueForKey:@"Name"];
            
            if ([strConfigName isEqualToString:@"HumanRuleLimit"]) {
                NSDictionary *channelHumanRuleLimitDic = [appData objectForKey:strConfigName];
                if ([channelHumanRuleLimitDic isKindOfClass:[NSNull class]]) {
                    return;
                }
                self.supportLine = [[channelHumanRuleLimitDic objectForKey:@"SupportLine"] boolValue];
                self.supportArea = [[channelHumanRuleLimitDic objectForKey:@"SupportArea"] boolValue];
                self.showTrack = [[channelHumanRuleLimitDic objectForKey:@"ShowTrack"] boolValue];
                
                //区域报警方向(i = 0 正向，1就是反向  2就是双向)
                NSString *dwAreaDirectStr = [channelHumanRuleLimitDic objectForKey:@"dwAreaDirect"];
                NSInteger dwAreaDirect = [self numberWithHexString:dwAreaDirectStr];
                for (int i = 0; i< 10 ; i++) {
                    if (dwAreaDirect & (0x01<<i)){
                        [self.areaDirectArray addObject:[NSNumber numberWithInt:i]];
                    }
                }
                
                //区域形状(支持几种形状  i为2就是三边，3就是四边  以此类推)
                NSString *dwAreaLineStr = [channelHumanRuleLimitDic objectForKey:@"dwAreaLine"];
                NSInteger dwAreaLine = [self numberWithHexString:dwAreaLineStr];
                for (int i = 0; i< 10 ; i++) {
                    if (dwAreaLine & (0x01<<i)){
                        // 屏蔽自定义
                        if (i == 7) {
                            break;
                        }
                        [self.areaLineArray addObject:[NSNumber numberWithInt:i]];
                    }
                }
                
                //线性报警方向(i = 0 正向，1就是反向  2就是双向)
                NSString *dwLineDirectStr = [channelHumanRuleLimitDic objectForKey:@"dwLineDirect"];
                NSInteger dwLineDirect = [self numberWithHexString:dwLineDirectStr];
                for (int i = 0; i< 10 ; i++) {
                    if (dwLineDirect & (0x01<<i)){
                        [self.lineDirectArray addObject:[NSNumber numberWithInt:i]];
                    }
                }
            }
            [self.ruleTableView reloadData];
        }
    }
}

- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}


#pragma mark - UITableViewDelegate/DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return nil;
    }else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.showTrack) {
            return 2;
        }else{
            return 1;
        }
    }else if (section == 1){
        if (self.pedRuleAbility) {
            if (self.supportArea && self.supportLine) {
                return 3;
            }else if ((self.supportArea && !self.supportLine) ||
                      (!self.supportArea && self.supportLine)){
                return 2;
            }else{
                return 1;
            }
        }else{
            return 1;
        }
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycell"];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = TS("Human_Detection");
            cell.accessoryView = self.humanDetectionSwitch;
        }else if (indexPath.row == 1){
            cell.textLabel.text = TS("Show_traces");
            cell.accessoryView = self.showTrackSwitch;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = TS("Perimeter_alert");
            cell.accessoryView = self.pedRuleSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if (indexPath.row == 1) {
            if (self.supportLine) {
            cell.textLabel.text = TS("alert_line");
            if (self.RuleType == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            }else if(self.supportArea && !self.supportLine){
                cell.textLabel.text = TS("alert_area");
                if (self.RuleType == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }else if (indexPath.row == 2){
            cell.textLabel.text = TS("alert_area");
            if (self.RuleType == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2)) {
        IntelViewController *indelVC = [[IntelViewController alloc] init];
        indelVC.humanDetection = YES;
        indelVC.drawType = (DrawType)(indexPath.row - 1);
        if (indelVC.drawType == DrawType_PEA_Line) {
            indelVC.navTitle = TS("alert_line");
            indelVC.directArray = [self.lineDirectArray mutableCopy];
            indelVC.alarmDirection = self.alarmDirection;
            indelVC.areaPointNum = -1;
        }else if(indelVC.drawType == DrawType_PEA_Area){
            indelVC.navTitle = TS("alert_area");
            indelVC.directArray = [self.areaDirectArray mutableCopy];
            indelVC.areaShapeArray = [self.areaLineArray mutableCopy];
            indelVC.alarmDirection = -1;
            indelVC.areaPointNum = self.areaPointNum;
        }
        indelVC.devID = self.devID;
        indelVC.humanDetectionDic = self.humanDetectionDic;
        indelVC.channelNum = self.channelNum;
        
        [self.navigationController pushViewController:indelVC animated:YES];
    }
}

#pragma mark - 配置子视图
-(void)configSubView{
    [self.view addSubview:self.ruleTableView];
    
    [self.ruleTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark -- lazyLoad
-(UITableView *)ruleTableView{
    if (!_ruleTableView) {
        _ruleTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _ruleTableView.dataSource = self;
        _ruleTableView.delegate = self;
        [_ruleTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mycell"];
        
        _ruleTableView.tableFooterView = [UIView new];
        _ruleTableView.scrollEnabled = NO;
    }
    return _ruleTableView;
}

-(UISwitch *)humanDetectionSwitch{
    if (!_humanDetectionSwitch) {
        _humanDetectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_humanDetectionSwitch addTarget:self action:@selector(openHumanDetection:) forControlEvents:UIControlEventValueChanged];
    }
    return _humanDetectionSwitch;
}

-(void)openHumanDetection:(UISwitch *)sender{
    [self.humanDetectionDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"Enable"];
}

-(UISwitch *)showTrackSwitch{
    if (!_showTrackSwitch) {
        _showTrackSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_showTrackSwitch addTarget:self action:@selector(openShowTrack:) forControlEvents:UIControlEventValueChanged];
    }
    return _showTrackSwitch;
}

-(void)openShowTrack:(UISwitch *)sender{
    [self.humanDetectionDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"ShowTrack"];
    //[self.humanDetectionDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"ShowRule"];
}

-(UISwitch *)pedRuleSwitch{
    if (!_pedRuleSwitch) {
        _pedRuleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_pedRuleSwitch addTarget:self action:@selector(openPedRuleAbility:) forControlEvents:UIControlEventValueChanged];
    }
    return _pedRuleSwitch;
}

-(void)openPedRuleAbility:(UISwitch *)sender{
    self.pedRuleAbility = sender.on;
    NSMutableArray *pedRuleArray = [[self.humanDetectionDic objectForKey:@"PedRule"] mutableCopy];
    NSMutableDictionary *pedRuleDic = [[pedRuleArray firstObject] mutableCopy];
    [pedRuleDic setObject:[NSNumber numberWithBool:self.pedRuleAbility] forKey:@"Enable"];
    [pedRuleArray replaceObjectAtIndex:0 withObject:pedRuleDic];
    [self.humanDetectionDic setObject:pedRuleArray forKey:@"PedRule"];
    [self.ruleTableView reloadData];
}

-(void)configNav
{
    self.navigationItem.title = TS("Intelligent_Vigilance");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(btnBackClicked)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItems = @[self.addBtn];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initParam{
    self.humanDetectionDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.RuleType = 0;
}

//MARK: -LazyLoad
-(UIBarButtonItem *)addBtn {
    if (!_addBtn) {
        _addBtn = [[UIBarButtonItem alloc] initWithTitle:TS("ad_save") style:UIBarButtonItemStyleDone target:self action:@selector(saveChange)];
        
        _addBtn.tintColor = [UIColor whiteColor];
    }
    
    return _addBtn;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
