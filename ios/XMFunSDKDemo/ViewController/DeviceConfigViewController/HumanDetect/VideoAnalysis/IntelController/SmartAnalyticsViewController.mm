//
//  SmartAnalyticsViewController.m
//  XMEye
//
//  Created by 杨翔 on 2017/5/3.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "SmartAnalyticsViewController.h"
#import "UnexpansionTableViewCell.h"
#import "ExpansionTableViewCell.h"
#import "SmartInfoTableViewCell.h"
#import "IntelViewController.h"
#import "MyNavigationBar.h"
#import "InterInterfaceControl.h"

@interface SmartAnalyticsViewController ()<UITableViewDelegate,UITableViewDataSource,InterInterfaceControlDelegate,UnexpansionTableViewCellSwitchDelegate>
{
    InterInterfaceControl *control;
}

@property (nonatomic, assign) BOOL bExpandPEA;

@property (nonatomic, assign) BOOL bExpandOSC;

@property (nonatomic, assign) BOOL bExpandAVD;

@property (nonatomic, assign) NSInteger selectRow;

@property (nonatomic, assign) NSInteger selectSection;

@property (nonatomic, strong) UITableView *ruleTableView;

@end

@implementation SmartAnalyticsViewController
static NSString *const kUnexpansionTableViewCell = @"UnexpansionTableViewCell";
static NSString *const kExpansionTableViewCell = @"ExpansionTableViewCell";
static NSString *const kUITableViewCell = @"UITableViewCell";
static NSString *const kSmartInfoTableViewCell = @"SmartInfoTableViewCell";


-(UITableView *)ruleTableView{
    if (!_ruleTableView) {
        _ruleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavHeight)];
        _ruleTableView.dataSource = self;
        _ruleTableView.delegate = self;
        [_ruleTableView registerClass:[UnexpansionTableViewCell class] forCellReuseIdentifier:kUnexpansionTableViewCell];
        [_ruleTableView registerClass:[ExpansionTableViewCell class] forCellReuseIdentifier:kExpansionTableViewCell];
        [_ruleTableView registerClass:[SmartInfoTableViewCell class] forCellReuseIdentifier:kSmartInfoTableViewCell];
    }
    return _ruleTableView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //创建导航栏
    [self createNavgationbar];
    
    //配置子视图
    [self configSubView];
    
    //获取智能分析配置
    [self getAnalyzeData];
}

-(void)createNavgationbar
{
    self.view.backgroundColor = [UIColor whiteColor];
    MyNavigationBar *navBar = [[MyNavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NavHeight)];
    navBar.backgroundColor = GlobalMainColor;
    
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.bounds = CGRectMake(20,24, 200, 40);
    labTitle.center = CGPointMake(SCREEN_WIDTH * 0.5, NavHeight-22);
    labTitle.text = TS("Video_Analyze");
    labTitle.textAlignment = NSTextAlignmentCenter;
    labTitle.font = [UIFont boldSystemFontOfSize:20.0];
    labTitle.backgroundColor = [UIColor clearColor];
    labTitle.textColor = btnTextColor;
    
    navBar.titleLabel = labTitle;
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    
    navBar.btnLeft = btnLeft;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NavHeight)];
    imgView.image = [UIImage imageNamed:@"naviBarImage.png"];
    imgView.userInteractionEnabled = YES;
    navBar.imgView = imgView;
    navBar.imgView.userInteractionEnabled = YES;
    
    [navBar showMyNavBar];
    [self.view addSubview:navBar];
}

-(void)btnBackClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createIntelControl
{
    if (control == nil) {
        control = [[InterInterfaceControl alloc] init];
        control.devID = self.devID;
        control.delegate = self;
        control.channelNum = self.channelNum;
    }
}
-(void)getAnalyzeData
{
    [self createIntelControl];
    [control getAnalyzeData];
}
-(void)saveAnalyzeConfig:(int)index
{
    if ([SVProgressHUD isVisible]) {
        return;
    }
    //视频诊断参数设置
    control.intelData.ChangeEnable = NO; //场景变换检测
    control.intelData.InterfereEnable = NO; //人为干扰检测
    control.intelData.FreezeEnable = NO; //画面冻结检测
    control.intelData.NosignalEnable = NO; //信号缺失检测
    if (index == 1) {
        control.intelData.ChangeEnable = YES; //场景变换检测
    }else if (index == 2){
        control.intelData.InterfereEnable = YES; //人为干扰检测
    }
    else if (index == 3){
        control.intelData.FreezeEnable = YES; //画面冻结检测
    }
    else if (index == 4){
        control.intelData.NosignalEnable = YES; //信号缺失检测
    }
    [control saveAnalyzeConfig];
}
-(void)AnalyzeValueChange:(UISwitch*)sender
{    //智能分析报警开关和显示踪迹开关
    if (sender.tag == 1) {
        control.intelData.AnalyzeEnable = sender.isOn;
    }else if (sender.tag == 2)
    {
        control.intelData.PeaShowTrace = sender.isOn;
        control.intelData.OscShowTrace = sender.isOn;
        control.intelData.PeaShowRule = sender.isOn;
        control.intelData.OscShowRule = sender.isOn;
    }
}
#pragma mark - 获取配置之后的回调
-(void)InterInterfaceControlGetResultDelegate:(BOOL)result{
    if (result) {
        UnexpansionTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UnexpansionTableViewCell *cell1 = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.analySwitch.on = control.intelData.AnalyzeEnable;
        int alarmType = control.intelData.ModuleType;
        switch (alarmType) {
            case 0:
                _bExpandPEA = YES;
                _bExpandAVD = NO;
                _bExpandOSC = NO;
                self.selectSection = 1;
                [self changeExpansionBtnOfCellStateWithRow:0 section:1];
                cell1.analySwitch.on = control.intelData.PeaShowTrace;
                break;
            case 1:
                _bExpandOSC = YES;
                _bExpandPEA = NO;
                _bExpandAVD = NO;
                self.selectSection = 2;
                [self changeExpansionBtnOfCellStateWithRow:0 section:2];
                cell1.analySwitch.on = control.intelData.OscShowTrace;
                
                break;
            case 2:
                _bExpandOSC = NO;
                _bExpandPEA = NO;
                _bExpandAVD = YES;
                self.selectSection = 3;
                [self changeExpansionBtnOfCellStateWithRow:0 section:3];
                cell1.analySwitch.on = control.intelData.PeaShowTrace;
                
            default:
                break;
        }
        [self.ruleTableView reloadData];
        [self changeUITableViewCellAccessoryType];
    }else{
        [self btnBackClicked];
    }
}
-(void)changeExpansionBtnOfCellStateWithRow:(NSInteger)row section:(NSInteger)section{
    ExpansionTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    [self expandBtnClicked:cell.ExpansionBtn];
}

#pragma mark - 根据获取到的数据来刷新界面
-(void)changeUITableViewCellAccessoryType{
    switch (self.selectSection) {
        case 1:
            if (control.intelData.TripWireEnable) {
                [self refreshUITableViewCellAccessoryTypeWithRow:1 section:1];
            }else if(control.intelData.PerimeterEnable){
                [self refreshUITableViewCellAccessoryTypeWithRow:2 section:1];
            }
            break;
        case 2:
            if (control.intelData.AbandumEnable) {
                [self refreshUITableViewCellAccessoryTypeWithRow:1 section:2];
            }else if(control.intelData.StolenEnable){
                [self refreshUITableViewCellAccessoryTypeWithRow:2 section:2];
            }
            break;
        case 3:
            if (control.intelData.ChangeEnable) {
                [self refreshUITableViewCellAccessoryTypeWithRow:1 section:3];
            }else if(control.intelData.InterfereEnable){
                [self refreshUITableViewCellAccessoryTypeWithRow:2 section:3];
            }else if(control.intelData.FreezeEnable){
                [self refreshUITableViewCellAccessoryTypeWithRow:3 section:3];
            }else if(control.intelData.NosignalEnable){
                [self refreshUITableViewCellAccessoryTypeWithRow:4 section:3];
            }
            break;
        default:
            break;
    }
    [self.ruleTableView reloadData];
}

-(void)refreshUITableViewCellAccessoryTypeWithRow:(NSInteger)row section:(NSInteger)section{
    SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectRow = row;
}

#pragma mark - 配置子视图
-(void)configSubView{
    [self.view addSubview:self.ruleTableView];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return _bExpandPEA?3:1;
            break;
        case 2:
            return _bExpandOSC?3:1;
            break;
        case 3:
            return _bExpandAVD?5:1;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        switch (section) {
            case 0:{
                switch (row) {
                    case 0:{
                        UnexpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUnexpansionTableViewCell forIndexPath:indexPath];
                        cell.textLabel.text = TS("SmartAnalytics");
                        cell.analySwitch.on = control.intelData.AnalyzeEnable;
                        cell.analySwitch.hidden = NO;
                        cell.analySwitch.tag = 1;
                        cell.delegate = self;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                        break;
                    case 1:{
                        UnexpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUnexpansionTableViewCell forIndexPath:indexPath];
                        cell.textLabel.text = TS("Show_traces");
                        cell.analySwitch.tag = 2;
                        cell.delegate = self;
                        if (_bExpandOSC) {
                            cell.analySwitch.on = control.intelData.PeaShowTrace;
                        }else{
                            cell.analySwitch.on = control.intelData.OscShowTrace;
                        }
                        
                        cell.analySwitch.hidden = NO;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                        break;
                    case 2:{
                        UnexpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUnexpansionTableViewCell forIndexPath:indexPath];
                        cell.textLabel.text = TS("Alert_type");
                        cell.analySwitch.hidden = YES;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
            case 1:{
                switch (row) {
                    case 0:{
                        ExpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExpansionTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Perimeter_alert");
                        cell.ExpansionBtn.tag = 101;
                        if (_bExpandPEA) {
                            cell.selectBtn.selected = YES;
                        }else{
                            cell.selectBtn.selected = NO;
                        }
                        [cell.ExpansionBtn addTarget:self action:@selector(expandBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }
                        break;
                    case 1:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Alert_line");
                        return cell;
                    }
                        break;
                    case 2:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Alert_area");
                        
                        return cell;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case 2:{
                switch (row) {
                    case 0:{
                        ExpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExpansionTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Item_care");
                        cell.ExpansionBtn.tag = 102;
                        if (_bExpandOSC) {
                            cell.selectBtn.selected = YES;
                        }else{
                            cell.selectBtn.selected = NO;
                        }
                        [cell.ExpansionBtn addTarget:self action:@selector(expandBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }
                        break;
                    case 1:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Items_stay");
                        return cell;
                    }
                        break;
                    case 2:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Items_stolen");
                        return cell;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case 3:{
                switch (row) {
                    case 0:{
                        ExpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExpansionTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Video_diagnosis");
                        cell.ExpansionBtn.tag = 103;
                        if (_bExpandAVD) {
                            cell.selectBtn.selected = YES;
                        }else{
                            cell.selectBtn.selected = NO;
                        }
                        [cell.ExpansionBtn addTarget:self action:@selector(expandBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }
                        break;
                    case 1:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Scene_change_detection");
                        return cell;
                    }
                        break;
                    case 2:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Signal_loss_detection");
                        return cell;
                    }
                        break;
                    case 3:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Clarity_detection");
                        return cell;
                    }
                        break;
                    case 4:{
                        SmartInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmartInfoTableViewCell forIndexPath:indexPath];
                        cell.textLab.text = TS("Human_disturbance_detection");
                        return cell;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                return [[UITableViewCell alloc] init];
                break;
        }
        
        return [[UITableViewCell alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    IntelViewController *indelVC = [[IntelViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:indelVC];
    ExpansionTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    switch (section) {
        case 0:
            break;
        case 1:
            switch (row) {
                case 0:
                    [self expandBtnClicked:cell.ExpansionBtn];
                    [self changeBtnSelectState:section with:row];
                    control.intelData.ModuleType = 0;
                    break;
                case 1:
                case 2:{
                    [self changeCellAccessoryType:row withSection:section];
                    
                    indelVC.drawType = (DrawType)(row -1);
                    indelVC.devID = self.devID;
                    indelVC.humanDetection = NO;
                    indelVC.channelNum = self.channelNum;
                    [indelVC setInterfaceControl:control];
                    [self presentViewController:navi animated:YES completion:nil];
                }
                    break;
                default:
                    break; 
            }
            break;
        case 2:
            switch (row) {
                case 0:
                    [self expandBtnClicked:cell.ExpansionBtn];
                    [self changeBtnSelectState:section with:row];
                    control.intelData.ModuleType = 1;
                    break;
                case 1:
                case 2:{
                    [self changeCellAccessoryType:row withSection:section];
                    
                    indelVC.drawType = (DrawType)(row + 1);
                    indelVC.devID = self.devID;
                    indelVC.channelNum = self.channelNum;
                    [indelVC setInterfaceControl:control];
                    [self presentViewController:navi animated:YES completion:nil];
                }
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (row) {
                case 0:
                    [self expandBtnClicked:cell.ExpansionBtn];
                    [self changeBtnSelectState:section with:row];
                    control.intelData.ModuleType = 2;
                    break;
                case 1:
                case 2:
                case 3:
                case 4:{
                    [self changeCellAccessoryType:row withSection:section];
                    [self saveAnalyzeConfig:row];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - 改变cell的accossoryview
-(void)changeCellAccessoryType:(NSInteger)row withSection:(NSInteger)section{
    self.selectSection = section;
    self.selectRow = row;
    switch (section) {
        case 1:
        case 2:{
            for (int i = 0 ; i<3; i++) {
                SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
                if (cell) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
            break;
        case 3:{
            for (int i = 0 ; i<5; i++) {
                SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
                if (cell) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
            break;
        default:
            break;
    }
    SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

-(void)changeBtnSelectState:(NSInteger)section with:(NSInteger)row{
    for (int i = 1; i<4; i++) {
        ExpansionTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:i]];
        [cell.selectBtn setSelected:NO];
        if (i == section) {
            [cell.selectBtn setSelected:YES];
        }
    }
    
    //防止cell的复用
    if (section != self.selectSection) {
        for (int i = 0; i<5; i++) {
            SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
            if (cell) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }else{
        SmartInfoTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow inSection:section]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self.ruleTableView reloadData];
}

#pragma mark -判断警戒类型是否已经勾选
-(void)expandBtnClicked:(UIButton *)sender{
    if (sender.tag == 101) {
        BOOL bExpand = sender.selected;
        _bExpandPEA = !bExpand;
        if (_bExpandPEA) {
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            _bExpandOSC = NO;
            _bExpandAVD = NO;
            
        }
        sender.selected = _bExpandPEA;
    }
    if (sender.tag == 102) {
        BOOL bExpand = sender.selected;
        _bExpandOSC = !bExpand;
        if (_bExpandOSC) {
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            _bExpandPEA = NO;
            _bExpandAVD = NO;

        }
        sender.selected = _bExpandOSC;
    }
    if (sender.tag == 103) {
        BOOL bExpand = sender.selected;
        _bExpandAVD = !bExpand;
        if (_bExpandAVD) {
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [self closeCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            _bExpandPEA = NO;
            _bExpandOSC = NO;
        }
        sender.selected = _bExpandAVD;
    }
    [self.ruleTableView reloadData];
}

-(void)closeCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExpansionTableViewCell *cell = [self.ruleTableView cellForRowAtIndexPath:indexPath];
    cell.ExpansionBtn.selected = NO;
}
@end
