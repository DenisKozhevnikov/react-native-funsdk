//
//  IntelViewController.m
//  XMEye
//
//  Created by XM on 2017/4/21.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "IntelViewController.h"
#import "DisplayView.h"
#import <Masonry/Masonry.h>
#import <FunSDK/FunSDK.h>

#define SCALEWIDEH 8194.0
@interface IntelViewController () <UITableViewDelegate,SuperViewSelectPointDelegate,AlarmAreaTypeViewDelegate>
{
    DisplayView *_disPlayView;
    SuperView *superView;
    InterInterfaceControl *control;
}

@property (nonatomic, assign) int directionLimit;
@property (nonatomic,strong) UIBarButtonItem *addBtn;
@property (nonatomic,assign) int msgHandle;
@property (nonatomic,assign) int playHandle;

@end

@implementation IntelViewController

-(AlarmAreaTypeView *)alarmView{
    if (!_alarmView) {
        _alarmView = [[AlarmAreaTypeView alloc] initWithFrame:CGRectZero];
        _alarmView.directArray = [self.directArray mutableCopy];
        if (self.drawType == DrawType_PEA_Area) {
            _alarmView.areaShapeArray = [self.areaShapeArray mutableCopy];
        }
        _alarmView.alarmType = self.drawType;
        _alarmView.delegate = self;
    }
    return _alarmView;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
-(void)setInterfaceControl:(InterInterfaceControl*)interControl
{
    control = interControl;
    if (self.drawType == DrawType_PEA_Line) {
        control.intelData.ModuleType = 0;
        control.intelData.TripWireEnable = YES;
        control.intelData.PerimeterEnable = NO;
    }else if (self.drawType == DrawType_PEA_Area)
    {
        control.intelData.ModuleType = 0;
        control.intelData.TripWireEnable = NO;
        control.intelData.PerimeterEnable = YES;
    }else if (self.drawType == DrawType_OSC_Move){
        control.intelData.ModuleType = 1;
        control.intelData.AbandumEnable = NO;
        control.intelData.StolenEnable = YES;
    }else if (self.drawType == DrawType_OSC_Stay){
        control.intelData.ModuleType = 1;
        control.intelData.AbandumEnable = YES;
        control.intelData.StolenEnable = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //创建导航栏
    [self configNav];
    [self createPlayView];
    
    // 进入界面给报警方向和报警区域赋值
    if (self.alarmDirection != -1) {
        superView.lastType = (DefaultPoint_Type)(self.alarmDirection + 101);
    }else{
        superView.lastType = (DefaultPoint_Type)(self.areaPointNum + 198);
    }
}

-(void)createPlayView
{
    if (_disPlayView == nil) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:backView];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.mas_equalTo(ScreenWidth);
            make.height.mas_equalTo(ScreenWidth);
        }];
        
        _disPlayView = [[DisplayView alloc] initWithFrame:CGRectZero];
        [backView addSubview:_disPlayView];
        
        [_disPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(backView);
        }];
        
        superView = [[SuperView alloc] initWithFrame:CGRectZero];
        superView.delegate = self;
        [superView setDrawType:self.drawType];
        [self setSuperViewInitData];
        [backView addSubview:superView];
        
        [superView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        superView.control.validFrame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    }
    
    [_disPlayView setDispStatus:DisplayViewStatusBuffering];
    FUN_MediaRealPlay(self.msgHandle, [self.devID UTF8String], self.channelNum, self.stream, (__bridge void*)_disPlayView);
    
    [self.view addSubview:self.alarmView];
    
    [self.alarmView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.top.equalTo(_disPlayView.mas_bottom);
    }];
}

-(void)setSuperViewInitData
{
    //设置大的警戒类型
    [superView setDrawType:self.drawType];
    if (self.humanDetection) {
        //人形检测
        if (self.drawType == DrawType_PEA_Line) {
            NSDictionary *PedRuleDic = [[self.humanDetectionDic objectForKey:@"PedRule"] firstObject];
            NSDictionary *RuleLineDic = [PedRuleDic objectForKey:@"RuleLine"];
            
            NSDictionary *PtsDic = [RuleLineDic objectForKey:@"Pts"];
            CGPoint pointStart = CGPointMake([[PtsDic objectForKey:@"StartX"] intValue]/SCALEWIDEH*SCREEN_WIDTH, [[PtsDic objectForKey:@"StartY"] intValue]/SCALEWIDEH*SCREEN_WIDTH);
            CGPoint pointStop = CGPointMake([[PtsDic objectForKey:@"StopX"] intValue]/SCALEWIDEH*SCREEN_WIDTH, [[PtsDic objectForKey:@"StopY"] intValue]/SCALEWIDEH*SCREEN_WIDTH);
            superView.control.pointArray = [@[[NSNumber valueWithCGPoint:pointStart],[NSNumber valueWithCGPoint:pointStop]] mutableCopy];
            superView.control.shedArray = [@[[@[[NSNumber valueWithCGPoint:pointStart],[NSNumber valueWithCGPoint:pointStop]] mutableCopy]] mutableCopy];
            
            int alarmDirect = [[RuleLineDic objectForKey:@"AlarmDirect"] intValue];
            if (alarmDirect == 0) {
                superView.control.dPoint.type = DefaultPoint_Type_LeftToRight;
                superView.control.firstPointType = DefaultPoint_Type_LeftToRight;
            }else if (alarmDirect == 1){
                superView.control.dPoint.type = DefaultPoint_Type_RightToLeft;
                superView.control.firstPointType = DefaultPoint_Type_RightToLeft;
            }else if (alarmDirect == 2){
                superView.control.dPoint.type = DefaultPoint_Type_Mutual;
                superView.control.firstPointType = DefaultPoint_Type_Mutual;
            }else{
                [superView.control getDirection];
            }
        }
        if (self.drawType == DrawType_PEA_Area) {
            NSMutableDictionary *PedRuleDic = [[[self.humanDetectionDic objectForKey:@"PedRule"] firstObject] mutableCopy];
            NSArray *currentPoint = [[PedRuleDic objectForKey:@"RuleRegion"] objectForKey:@"Pts"];
            int pointNumb = [[[PedRuleDic objectForKey:@"RuleRegion"] objectForKey:@"PtsNum"] intValue];
            NSMutableArray *pointArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i<pointNumb; i++) {
                NSDictionary *pointDic = [currentPoint objectAtIndex:i];
                CGPoint point = CGPointMake([[pointDic objectForKey:@"X"] intValue]/SCALEWIDEH*SCREEN_WIDTH, [[pointDic objectForKey:@"Y"] intValue]/SCALEWIDEH*SCREEN_WIDTH);
                [pointArray addObject:[NSNumber valueWithCGPoint:point]];
            }
            superView.control.pointArray = pointArray;
            superView.control.shedArray = [@[[pointArray mutableCopy]] mutableCopy];
        }
    }else{
        //智能分析
        if (self.drawType == DrawType_PEA_Line) {
            superView.control.pointArray = [control.intelData.TripWireArray mutableCopy];
            if (control.intelData.IsDoubleDir == YES) {
                superView.control.dPoint.type = DefaultPoint_Type_Mutual;
            }else{
                [superView.control getDirection];
            }
        }
        if (self.drawType == DrawType_PEA_Area) {
            superView.control.pointArray = [control.intelData.PerimeterArray mutableCopy];
        }
        if (self.drawType == DrawType_OSC_Stay) {
            superView.control.pointArray = [control.intelData.AbandumArray mutableCopy];
        }
        if (self.drawType == DrawType_OSC_Move) {
            superView.control.pointArray = [control.intelData.StolenArray mutableCopy];
        }
    }
}
#pragma mark - OnFunSDKResult
- (void)OnFunSDKResult:(NSNumber *) pParam
{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch ( msg->id ) {
#pragma mark 收到开始直播结果消息
        case EMSG_START_PLAY:
        {
            [_disPlayView setDispStatus:DisplayViewStatusBuffering];
        }
            break;
#pragma mark 收到开始缓存数据结果消息
        case EMSG_ON_PLAY_BUFFER_BEGIN:
        {
            [_disPlayView setDispStatus:DisplayViewStatusBuffering];
        }
            break;
#pragma mark 收到缓冲结束开始有画面结果消息
        case EMSG_ON_PLAY_BUFFER_END:
        {
            [_disPlayView setDispStatus:DisplayViewStatusPlaying];
        }
            break;
        case EMSG_ON_PLAY_INFO:
        {
            
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            [SVProgressHUD dismiss];
            if (msg->param1 < 0) {
                [SVProgressHUD showErrorWithStatus:TS("Save_Failed")];
            }else{
                if( strcmp(msg->szStr, [[NSString stringWithFormat:@"Detect.HumanDetection"] UTF8String])==0 ){
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }
        }
            break;
        default:
            break;
    }
}
//选择点完成之后的代理
-(void)SuperViewSelectPointArray:(NSMutableArray*)array
{
    
}

- (void)superViewUserChangedPoint{
    _alarmView.cancelBtn.userInteractionEnabled = YES;
    _alarmView.cancelBtn.selected = NO;
}

-(void)btnSaveClicked{
    if (superView.control.pointArray.count <= 1) {
        [SVProgressHUD showErrorWithStatus:TS("Data_exception")];
        return;
    }
    if (self.humanDetection) {
        if (superView.control.drawType == DrawType_PEA_Line) {
            CGPoint startPoint = [[superView.control.pointArray firstObject] CGPointValue];
            CGPoint stopPoint = [[superView.control.pointArray lastObject] CGPointValue];
            NSDictionary *dic = @{@"StartX":[NSNumber numberWithInt:(startPoint.x/SCREEN_WIDTH*SCALEWIDEH)],
                                  @"StartY":[NSNumber numberWithInt:(startPoint.y/SCREEN_WIDTH*SCALEWIDEH)],
                                  @"StopX":[NSNumber numberWithInt:(stopPoint.x/SCREEN_WIDTH*SCALEWIDEH)],
                                  @"StopY":[NSNumber numberWithInt:(stopPoint.y/SCREEN_WIDTH*SCALEWIDEH)]
                                  };
            
            NSMutableArray *pedRuleArray = [[self.humanDetectionDic objectForKey:@"PedRule"] mutableCopy];
            NSMutableDictionary *pedRuleDic = [[pedRuleArray firstObject] mutableCopy];
            NSMutableDictionary *RuleLineDic = [[pedRuleDic objectForKey:@"RuleLine"] mutableCopy];
            [RuleLineDic setObject:dic forKey:@"Pts"];
            [pedRuleDic setObject:RuleLineDic forKey:@"RuleLine"];
            [pedRuleDic setObject:[NSNumber numberWithInt:0] forKey:@"RuleType"];
            [pedRuleArray replaceObjectAtIndex:0 withObject:pedRuleDic];
            [self.humanDetectionDic setObject:pedRuleArray forKey:@"PedRule"];
        }
        if ([superView.control checkGraphValidated]) {
            [SVProgressHUD show];
            [SVProgressHUD showErrorWithStatus:TS("Data_exception")];
            return;
        }
        if (superView.control.drawType == DrawType_PEA_Area) {
            NSMutableArray *pointArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < superView.control.pointArray.count; i++) {
                CGPoint point = [[superView.control.pointArray objectAtIndex:i] CGPointValue];
                NSDictionary *dic = @{@"X":[NSNumber numberWithInt:(point.x/SCREEN_WIDTH*SCALEWIDEH)],@"Y":[NSNumber numberWithInt:(point.y/SCREEN_WIDTH*SCALEWIDEH)]};
                [pointArray addObject:dic];
            }
            
            NSMutableArray *pedRuleArray = [[self.humanDetectionDic objectForKey:@"PedRule"] mutableCopy];
            NSMutableDictionary *dic = [[pedRuleArray firstObject] mutableCopy];
            NSMutableDictionary *pedRuleDic = [[dic objectForKey:@"RuleRegion"] mutableCopy];
            [pedRuleDic setObject:[NSNumber numberWithInt:superView.control.pointArray.count] forKey:@"PtsNum"];
            [pedRuleDic setObject:[NSNumber numberWithInt:self.directionLimit] forKey:@"AlarmDirect"];
            [pedRuleDic setObject:pointArray forKey:@"Pts"];
            [dic setObject:pedRuleDic forKey:@"RuleRegion"];
            [dic setObject:[NSNumber numberWithInt:1] forKey:@"RuleType"];
            [pedRuleArray replaceObjectAtIndex:0 withObject:dic];
            [self.humanDetectionDic setObject:pedRuleArray forKey:@"PedRule"];
        }
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.humanDetectionDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"Detect.HumanDetection",[strValues UTF8String] ,[strValues length]+1,self.channelNum);
        [SVProgressHUD showWithStatus:TS("Saving")];
    }else{
        if (superView.control.drawType == DrawType_PEA_Line) {
            [superView.control checkLineDirection];
            control.intelData.TripWireArray = [superView.control.pointArray mutableCopy];
            [superView setNeedsDisplay];
        }
        if ([superView.control checkGraphValidated]) {
            [SVProgressHUD showErrorWithStatus:TS("Data_exception")];
            return;
        }
        if (superView.control.drawType == DrawType_PEA_Area) {
            control.intelData.PerimeterArray = [superView.control.pointArray mutableCopy];
        }
        if (superView.control.drawType == DrawType_OSC_Move) {
            control.intelData.StolenArray = [superView.control.pointArray mutableCopy];
        }
        if (superView.control.drawType == DrawType_OSC_Stay) {
            control.intelData.AbandumArray = [superView.control.pointArray mutableCopy];
        }
        [control setAnalyzePointArrayWithType:superView.control.drawType];
        [control saveAnalyzeConfig];
    }
}
// 返回 按钮
-(void)btnBackClicked
{
    if ([SVProgressHUD isVisible]) {
        return;
    }
    FUN_MediaStop(self.playHandle);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configNav
{
    self.navigationItem.title = self.navTitle;
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(btnBackClicked)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItems = @[self.addBtn];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

#pragma mark - 还原
-(void)cancelSelectScene{
    [superView removeAllStep];
    [self.alarmView unSelectedButton];
}

//MARK:回退到上一步
- (void)rollBackAction{
    [superView rollBackLastStep];
}

#pragma mark - 完成选择应用场景
-(void)compliteSelectScene{
    [self btnSaveClicked];
}

#pragma mark - 选择警戒方向
-(void)selectAlarmOrientation{
    UIAlertActionStyle style0= UIAlertActionStyleDefault;
    UIAlertActionStyle style1= UIAlertActionStyleDefault;
    UIAlertActionStyle style2= UIAlertActionStyleDefault;
    if (self.humanDetection) {
        NSDictionary *RuleRegioDic = [[self.humanDetectionDic objectForKey:@"PedRule"] firstObject];
        int alarmDirect = [[[RuleRegioDic objectForKey:@"RuleRegion"] objectForKey:@"AlarmDirect"] intValue];
        switch (alarmDirect) {
            case 0:
                style1 = UIAlertActionStyleDestructive;
                break;
            case 1:
                style2 = UIAlertActionStyleDestructive;
                break;
            case 2:
                style0 = UIAlertActionStyleDestructive;
                break;
            default:
                break;
        }
    }else{
        if (control.intelData.DirectionLimit == 0) {
            style0 = UIAlertActionStyleDestructive;
        }
        if (control.intelData.DirectionLimit == 1) {
            style1 = UIAlertActionStyleDestructive;
        }
        if (control.intelData.DirectionLimit == 2) {
            style2 = UIAlertActionStyleDestructive;
        }
        
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("alert_line_trigger_direction") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *douAction = [UIAlertAction actionWithTitle:TS("Two-way_alert") style:style0 handler:^(UIAlertAction *action){
        if (self.humanDetection) {
            self.directionLimit = 2;
        }else{
            control.intelData.DirectionLimit = 0;
        }
    }];
    UIAlertAction *inAction = [UIAlertAction actionWithTitle:TS("Into_alert") style:style1 handler:^(UIAlertAction *action){
        if (self.humanDetection) {
            self.directionLimit = 0;
        }else{
            control.intelData.DirectionLimit = 1;
        }
    }];
    UIAlertAction *outAction = [UIAlertAction actionWithTitle:TS("Leave_alert") style:style2 handler:^(UIAlertAction *action){
        if (self.humanDetection) {
            self.directionLimit = 1;
        }else{
            control.intelData.DirectionLimit = 2;
        }
    }];
    [alertController addAction:douAction];
    [alertController addAction:inAction];
    [alertController addAction:outAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 选择应用场景
-(void)selectScenarios:(DefaultPoint_Type)type{
    [superView setDrawType:self.drawType];
    [superView setSelectSceneType:type];
    if (self.humanDetection) {
        if (type == DefaultPoint_Type_LeftToRight ||
            type == DefaultPoint_Type_RightToLeft ||
            type == DefaultPoint_Type_Mutual) {
            NSMutableArray *pedRuleArray = [[self.humanDetectionDic objectForKey:@"PedRule"] mutableCopy];
            NSMutableDictionary *pedRuleDic = [[pedRuleArray firstObject] mutableCopy];
            NSMutableDictionary *ruleLineDic = [[pedRuleDic objectForKey:@"RuleLine"] mutableCopy];
            if (type == DefaultPoint_Type_LeftToRight) {
                [ruleLineDic setObject:[NSNumber numberWithInt:0] forKey:@"AlarmDirect"];
            }else if(type == DefaultPoint_Type_RightToLeft) {
                [ruleLineDic setObject:[NSNumber numberWithInt:1] forKey:@"AlarmDirect"];
            }else{
                [ruleLineDic setObject:[NSNumber numberWithInt:2] forKey:@"AlarmDirect"];
            }
            [pedRuleDic setObject:ruleLineDic forKey:@"RuleLine"];
            [pedRuleArray replaceObjectAtIndex:0 withObject:pedRuleDic];
            [self.humanDetectionDic setObject:pedRuleArray forKey:@"PedRule"];
        }
        
    }else{
        if (type == DefaultPoint_Type_Mutual) {
            control.intelData.IsDoubleDir = YES;
        }else if (type == DefaultPoint_Type_RightToLeft || type == DefaultPoint_Type_LeftToRight){
            control.intelData.IsDoubleDir = NO;
        }
    }
}

//MARK: -LazyLoad
-(UIBarButtonItem *)addBtn {
    if (!_addBtn) {
        _addBtn = [[UIBarButtonItem alloc] initWithTitle:TS("ad_save") style:UIBarButtonItemStyleDone target:self action:@selector(btnSaveClicked)];
        
        _addBtn.tintColor = [UIColor whiteColor];
    }
    
    return _addBtn;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
