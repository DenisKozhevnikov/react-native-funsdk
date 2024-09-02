//
//  AlarmAreaTypeView.m
//  XMEye
//
//  Created by 杨翔 on 2017/5/4.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "AlarmAreaTypeView.h"

@interface AlarmAreaTypeView ()

//MARK:便于撤销选择状态
@property (nonatomic,strong) NSMutableArray *arrayBtn;
@property (nonatomic,strong) NSMutableArray *arrayLabel;

@end

@implementation AlarmAreaTypeView

-(UIView *)detailView{
    if (!_detailView) {
        _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _detailView.backgroundColor = [UIColor whiteColor];
        if (self.alarmType == DrawType_PEA_Line) {
            [self createHelpViewWithDetail:TS("alert_line_trigger_direction")];
        }else if (self.alarmType == DrawType_PEA_Area){
            if (self.directArray.count > 1) {
            UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 40)];
            [leftBtn setTitle:TS("application_scenarios") forState:UIControlStateNormal];
            [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            
            UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 40)];
            [rightBtn setTitle:TS("alert_line_trigger_direction") forState:UIControlStateNormal];
            [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [rightBtn addTarget:self action:@selector(chooseAlarmOrientation) forControlEvents:UIControlEventTouchUpInside];
            rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 5, 1, 30)];
            line.backgroundColor = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1];
            
            [_detailView addSubview:leftBtn];
            [_detailView addSubview:rightBtn];
            [_detailView addSubview:line];
            }else{
                [self createHelpViewWithDetail:TS("application_scenarios")];
            }
        }else if (self.alarmType == DrawType_OSC_Stay){
            [self createHelpViewWithDetail:TS("application_scenarios")];
        }else if (self.alarmType == DrawType_OSC_Move){
            [self createHelpViewWithDetail:TS("application_scenarios")];
        }
    }
        return _detailView;
}

-(void)createHelpViewWithDetail:(NSString *)info{
    UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 40)];
    infoLab.text = info;
    [_detailView addSubview:infoLab];
    infoLab.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - 控件get方法
-(UIScrollView *)scenariosScrollView{
    if (!_scenariosScrollView) {
        _scenariosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, (SCREEN_WIDTH - 20)*33/113)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _scenariosScrollView.frame = CGRectMake(0, 50, SCREEN_WIDTH, 105);
        }
        UIView *contentView;
        if (self.alarmType == DrawType_PEA_Line) {
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, (SCREEN_WIDTH - 20)*33/113)];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
            }
            
            for (int i = 0; i < self.directArray.count; i++) {
                UIButton *scenariosBtn = [self creatPartViewWithIndex:i withScenariosCount:self.directArray.count];
                [contentView addSubview:scenariosBtn];
            }
        }else if (self.alarmType == DrawType_PEA_Area){
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,6*((SCREEN_WIDTH - 50)/4 +10) + 10,(SCREEN_WIDTH - 50)/4)];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
            }
            for (int i = 0; i < self.areaShapeArray.count; i++) {
                UIButton *scenariosBtn = [self creatPartViewWithIndex:i withScenariosCount:self.areaShapeArray.count];
                [contentView addSubview:scenariosBtn];
            }
        }else if (self.alarmType == DrawType_OSC_Stay){
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,(SCREEN_WIDTH - 50)/4)];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
            }
            for (int i = 0; i < 4; i++) {
                UIButton *scenariosBtn= [self creatPartViewWithIndex:i withScenariosCount:4];
                [contentView addSubview:scenariosBtn];
            }
        }else if (self.alarmType == DrawType_OSC_Move){
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,(SCREEN_WIDTH - 50)/4)];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
            }
            for (int i = 0; i < 4; i++) {
                UIButton *scenariosBtn = [self creatPartViewWithIndex:i withScenariosCount:4];
                [contentView addSubview:scenariosBtn];
            }
        }
        
        _scenariosScrollView.bounces = NO;
        _scenariosScrollView.showsHorizontalScrollIndicator = NO;
        [_scenariosScrollView addSubview:contentView];
        _scenariosScrollView.contentSize = contentView.frame.size;
    }
    return _scenariosScrollView;
}

#pragma mark - 对象初始化
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    }
    return self;
}

#pragma mark - 配置子视图
-(void)configSubView{
    [self addSubview:self.cancelBtn];
    [self addSubview:self.btnRollBack];
    [self addSubview:self.detailView];
    [self addSubview:self.completeBtn];
    [self addSubview:self.scenariosScrollView];
}

-(void)setAlarmType:(enum DrawType)alarmType{
    _alarmType = alarmType;
    [self configSubView];
}

-(UIButton *)creatPartViewWithIndex:(int)index withScenariosCount:(int)scenariosCount{
    BOOL chinese =  NO;
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage hasPrefix:@"zh-Hans"] || [currentLanguage hasPrefix:@"zh-Hant"]) {
        chinese = YES;
    }
    UIButton *sceneBtn = [[UIButton alloc] init];
    [sceneBtn.layer setBorderColor:[UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1].CGColor];
    int indexTag = index;
    if (self.alarmType == DrawType_PEA_Line) {
        indexTag = [[self.directArray objectAtIndex:index] intValue];
    }else if (self.alarmType == DrawType_PEA_Area){
        indexTag = [[self.areaShapeArray objectAtIndex:index] intValue];
        indexTag = indexTag -2;
    }
    
    sceneBtn.tag =  ((int)self.alarmType + 1) * 100 + indexTag + 1;
    [sceneBtn.layer setMasksToBounds:YES];
    [sceneBtn.layer setBorderWidth:1];
    [sceneBtn addTarget:self action:@selector(didSelectScene:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *textLable;
    UIButton *backBtn;
    if (self.alarmType == DrawType_PEA_Line) {
        if (scenariosCount == 1) {
            index = 1;
        }
        sceneBtn.frame = CGRectMake(20 +((SCREEN_WIDTH - 80)/3 +20) * index, (((SCREEN_WIDTH - 20)*33/113) -(SCREEN_WIDTH - 80)*33/113)/2, (SCREEN_WIDTH - 80)/3, (SCREEN_WIDTH - 80)*33/113);
        backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, (SCREEN_WIDTH - 80)/3 - 40,(SCREEN_WIDTH - 80)/3 - 40)];
        textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_WIDTH - 80)/3 - 40, (SCREEN_WIDTH - 80)/3, (SCREEN_WIDTH - 80)*33/113 - ((SCREEN_WIDTH - 80)/3 - 30))];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            sceneBtn.frame = CGRectMake(20 + (98 + (SCREEN_WIDTH - 40 - 98*3)/2)* index ,8.7 ,98,86);
            backBtn.frame = CGRectMake(19.9, 0,58.33 ,58.33);
            textLable.frame = CGRectMake(19.9, 58.33, 58.33, 17.67);
        }

        NSString *preImageName = [NSString stringWithFormat:@"ic_pre%d.png",indexTag];
        NSString *selectImageName = [NSString stringWithFormat:@"ic_select%d.png",indexTag];
        if (preImageName) {
            [backBtn setBackgroundImage:[UIImage imageNamed:preImageName] forState:UIControlStateNormal];
            [backBtn setBackgroundImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
        }else{
            [backBtn setBackgroundColor:[UIColor grayColor]];
        }
        
        [sceneBtn addSubview:backBtn];


        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = [UIFont systemFontOfSize:14];
        if (indexTag == 0) {
            textLable.text = TS("smart_analyze_line_left");
        }else if (indexTag == 1){
            textLable.text = TS("smart_analyze_line_right");
        }else if (indexTag == 2){
            textLable.text = TS("smart_analyze_line_middle");
        }
        
        [self.arrayBtn addObject:backBtn];
        [self.arrayLabel addObject:textLable];
    }else if (self.alarmType == DrawType_PEA_Area){
        sceneBtn.frame = CGRectMake(10 + ((SCREEN_WIDTH - 50)/4 + 10)*index, 10, (SCREEN_WIDTH - 50)/4,(SCREEN_WIDTH - 50)/4);
        backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,0,(SCREEN_WIDTH - 50)/4 - 20,(SCREEN_WIDTH - 50)/4 - 20)];
        textLable = [[UILabel alloc] initWithFrame:CGRectMake(10, (SCREEN_WIDTH - 50)/4 - 20, (SCREEN_WIDTH - 50)/4 - 20, 20)];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            sceneBtn.frame = CGRectMake(20 + (((SCREEN_WIDTH - 40 - 81.25*6)/5 + 81.25)*index), 10, 81.25, 81.25);
            backBtn.frame = CGRectMake(10, 0,61.25 ,61.25);
            textLable.frame = CGRectMake(10, 61.25, 61.25, 20);
        }
        NSString *preImageName = [NSString stringWithFormat:@"ic_Area%d.png",indexTag];
        NSString *selectImageName = [NSString stringWithFormat:@"ic_Area_select%d.png",indexTag];
        if (preImageName) {
            [backBtn setBackgroundImage:[UIImage imageNamed:preImageName] forState:UIControlStateNormal];
            [backBtn setBackgroundImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
        }else{
            [backBtn setBackgroundColor:[UIColor grayColor]];
        }
        
        [sceneBtn addSubview:backBtn];

        
        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = [UIFont systemFontOfSize:12];
        if (chinese) {
            textLable.font = [UIFont systemFontOfSize:14];
        }
        if (indexTag == 0) {
            textLable.text = TS("smart_analyze_shape_triangle");
        }else if (indexTag == 1){
            textLable.text = TS("smart_analyze_shape_rectangle");
        }else if (indexTag == 2){
            textLable.text = TS("smart_analyze_shape_pentagram");
        }else if (indexTag == 3){
            textLable.text = TS("smart_analyze_shape_l_sel");
        }else if (indexTag == 4){
            textLable.text = TS("smart_analyze_shape_concave");
        }else if (indexTag == 5){
            textLable.text = TS("smart_analyze_shape_customize");
        }
        
        [self.arrayBtn addObject:backBtn];
        [self.arrayLabel addObject:textLable];
    }else if (self.alarmType == DrawType_OSC_Stay){
        sceneBtn.frame = CGRectMake(10 + ((SCREEN_WIDTH - 50)/4 + 10)*index, 10, (SCREEN_WIDTH - 50)/4,(SCREEN_WIDTH - 50)/4);
        backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,(SCREEN_WIDTH - 50)/4,(SCREEN_WIDTH - 50)/4 - 20)];
        textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_WIDTH - 50)/4 - 20, (SCREEN_WIDTH - 50)/4, 20)];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            sceneBtn.frame = CGRectMake(20 + ((SCREEN_WIDTH - 81.25 * 4 - 40)/3 + 81.25)* index , 10, 81.25, 81.25);
            backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,81.25,61.25)];
            textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 61.25, 81.25, 20)];
            
        }

        NSString *preImageName;
        if (index != 3) {
            preImageName = [NSString stringWithFormat:@"stay%d.png",index];
        }else{
            preImageName = @"ic_Area5.png";
            [backBtn setBackgroundColor:[UIColor grayColor]];
        }
        [backBtn setBackgroundImage:[UIImage imageNamed:preImageName] forState:UIControlStateNormal];
        
        [sceneBtn addSubview:backBtn];
        
        
        textLable.backgroundColor = [UIColor blackColor];
        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = [UIFont systemFontOfSize:12];
        if (chinese) {
            textLable.font = [UIFont systemFontOfSize:14];
        }
        textLable.textColor = [UIColor whiteColor];
        if (index == 0) {
            textLable.text = TS("smart_analyze_store_car");
        }else if (index == 1){
            textLable.text = TS("smart_analyze_forbidden_parking");
        }else if (index == 2){
            textLable.text = TS("smart_analyze_corridor");
        }else if (index == 3){
            textLable.text = TS("smart_analyze_shape_customize");
        }
    }else if (self.alarmType == DrawType_OSC_Move){
        sceneBtn.frame = CGRectMake(10 + ((SCREEN_WIDTH - 50)/4 + 10)*index, 10, (SCREEN_WIDTH - 50)/4,(SCREEN_WIDTH - 50)/4);
        backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,(SCREEN_WIDTH - 50)/4,(SCREEN_WIDTH - 50)/4 - 20)];
        textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_WIDTH - 50)/4 - 20, (SCREEN_WIDTH - 50)/4, 20)];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            sceneBtn.frame = CGRectMake(20 + ((SCREEN_WIDTH - 81.25 * 4 - 40)/3 + 81.25)* index , 10, 81.25, 81.25);
            backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,81.25,61.25)];
            textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 61.25, 81.25, 20)];
            
        }

        NSString *preImageName;
        if (index != 3) {
            preImageName = [NSString stringWithFormat:@"remove%d.png",index];
        }else{
            preImageName = @"ic_Area5.png";
            [backBtn setBackgroundColor:[UIColor grayColor]];
        }
        [backBtn setBackgroundImage:[UIImage imageNamed:preImageName] forState:UIControlStateNormal];
        
        [sceneBtn addSubview:backBtn];
        
        
        textLable.backgroundColor = [UIColor blackColor];
        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = [UIFont systemFontOfSize:12];
        if (chinese) {
            textLable.font = [UIFont systemFontOfSize:14];
        }
        textLable.textColor = [UIColor whiteColor];
        if (index == 0) {
            textLable.text = TS("smart_analyze_jewelry");
        }else if (index == 1){
            textLable.text = TS("smart_analyze_baby_room");
        }else if (index == 2){
            textLable.text = TS("smart_analyze_book_room");
        }else if (index == 3){
            textLable.text = TS("smart_analyze_shape_customize");
        }
    }
    textLable.tag = (self.alarmType + 1) * 100 + indexTag + 2001;
    backBtn.tag =  (self.alarmType + 1) * 100 + indexTag + 1001;
    [backBtn addTarget:self action:@selector(didSelectScene:) forControlEvents:UIControlEventTouchUpInside];
    [sceneBtn addSubview:textLable];
    return sceneBtn;
}

-(void)didSelectScene:(UIButton *)sender{
    
    int btnTag;
    if (sender.tag < 1000) {
        btnTag = sender.tag + 1000;
    }else{
        btnTag = sender.tag;
    }
    
    for (int i = 1101 + self.alarmType * 100; i<1101 + self.alarmType * 100 + 6; i++) {
        UIButton *btn = [self viewWithTag:i];
        UILabel *textLab = (UILabel *)[self viewWithTag: i+ 1000];
        if (btn) {
            if (i != btnTag) {
                btn.selected = NO;
                if (self.alarmType == DrawType_PEA_Line || self.alarmType == DrawType_PEA_Area) {
                    textLab.textColor = [UIColor blackColor];
                }else{
                    textLab.textColor = [UIColor whiteColor];
                }
                
            }else{
                btn.selected = !btn.selected;
                if (btn.selected) {
                    textLab.textColor = [UIColor colorWithRed:47/255.0 green:169/255.0 blue:1 alpha:1];;
                }else{
                    if (self.alarmType == DrawType_PEA_Line || self.alarmType == DrawType_PEA_Area) {
                        textLab.textColor = [UIColor blackColor];
                    }else{
                        textLab.textColor = [UIColor whiteColor];
                    }
                }
            }
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(selectScenarios:)]) {
        [self.delegate selectScenarios:sender.tag>1000?sender.tag - 1000:sender.tag];
        self.cancelBtn.selected = NO;
        self.cancelBtn.userInteractionEnabled = YES;
    }
}


#pragma mark - 控件get方法
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 165, 80, 40)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _cancelBtn.frame = CGRectMake(20, 150, 80, 40 );
        }
        [_cancelBtn setTitle:TS("smart_analyze_restore") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        _cancelBtn.selected = YES;
        _cancelBtn.userInteractionEnabled = NO;
        [_cancelBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_cancelBtn addTarget:self action:@selector(cancelOperations) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)btnRollBack{
    if (!_btnRollBack) {
        _btnRollBack = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cancelBtn.frame) + 30, 165, 80, 40)];
        
        [_btnRollBack setTitle:TS("smart_analyze_revoke") forState:UIControlStateNormal];
        [_btnRollBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [_btnRollBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_btnRollBack addTarget:self action:@selector(rollBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnRollBack;
}
-(void)cancelOperations{
    if (self.cancelBtn.selected) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelSelectScene)] ) {
        [self.delegate cancelSelectScene];
    }
}

- (void)rollBackClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rollBackAction)]) {
        [self.delegate rollBackAction];
    }
}

-(void)chooseAlarmOrientation{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectAlarmOrientation)] ) {
        [self.delegate selectAlarmOrientation];
    }
}

#pragma mark - 控件get方法
-(UIButton *)completeBtn{
    if (!_completeBtn) {
        _completeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 165, 60, 40)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _completeBtn.frame = CGRectMake(SCREEN_WIDTH - 80, 150, 60, 40 );
        }
        
        [_completeBtn setTitle:TS("Done") forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_completeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_completeBtn addTarget:self action:@selector(completeOperations) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

-(void)completeOperations{
    if (self.delegate && [self.delegate respondsToSelector:@selector(compliteSelectScene)] ) {
        [self.delegate compliteSelectScene];
    }
}

- (NSMutableArray *)arrayBtn{
    if (!_arrayBtn) {
        _arrayBtn = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayBtn;
}

- (NSMutableArray *)arrayLabel{
    if (!_arrayLabel) {
        _arrayLabel = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayLabel;
}

//MARK:取消选中状态
- (void)unSelectedButton{
    for (int i = 0; i < self.arrayBtn.count; i ++) {
        UIButton *btn = [self.arrayBtn objectAtIndex:i];
        btn.selected = NO;
    }
    
    for (int i = 0; i < self.arrayLabel.count; i ++) {
        UILabel *lb = [self.arrayLabel objectAtIndex:i];
        lb.textColor = [UIColor blackColor];
    }

}

@end
