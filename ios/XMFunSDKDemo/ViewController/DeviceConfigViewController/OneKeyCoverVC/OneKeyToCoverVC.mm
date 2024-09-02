//
//  OneKeyToCoverVC.m
//  XWorld_Xiongmai
//
//  Created by SaturdayNight on 2018/7/4.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "OneKeyToCoverVC.h"
#import <FunSDK/FunSDK.h>
#import <Masonry/Masonry.h>
#import "AlarmSwitchCell.h"
#import "MessageUI.h"

@interface OneKeyToCoverVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UITableView *tbFunList;       // 功能列表
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) UI_HANDLE msgHandle;

@end

static NSString *const kAlarmSwitchCellIdentifier = @"switchCell";

@implementation OneKeyToCoverVC

-(instancetype)init{
    self= [super init];
    self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    
    return self;
}

-(void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNav];
    [self configSubview];
    [self myLayout];
    
    [self requestSettingConfig];
}

#pragma mark - UI Config
-(void)configNav{
    self.navigationItem.title = TS("One_Key_To_Cover");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:TS("ad_save") forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 48, 32);
    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    //self.navigationItem.rightBarButtonItems = @[rightBarBtn];
}

-(void)configSubview{
    [self.view addSubview:self.tbFunList];
}

-(void)myLayout{
    [self.tbFunList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - Network API
-(void)requestSettingConfig{
    [SVProgressHUD show];
    
    FUN_DevGetConfig_Json(self.msgHandle, [self.devId UTF8String], "General.OneKeyMaskVideo", 1024,0);
}

#pragma mark - EventAction
-(void)leftBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)oneKeyToCoverOpen:(BOOL)ifOpen{
    [SVProgressHUD show];
    
    NSDictionary* jsonDic = @{@"Enable":[NSNumber numberWithBool:ifOpen]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devId), "General.OneKeyMaskVideo", [pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), 0, 10000, ifOpen ? 1 : 0);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dicTemp = self.dataSource[0];
    
    if ([[dicTemp objectForKey:@"enable"] boolValue]) {
        return self.dataSource.count;
    }
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmSwitchCell *cell = (AlarmSwitchCell *)[tableView dequeueReusableCellWithIdentifier:kAlarmSwitchCellIdentifier];
    if (!cell) {
        cell = [[AlarmSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAlarmSwitchCellIdentifier];
    }
    
    cell.toggleSwitchStateChangedAction = ^(BOOL on) {
        [self oneKeyToCoverOpen:on];
    };
    
    NSDictionary *dicInfo = [self.dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = [dicInfo objectForKey:@"title"];
    cell.detailLabel.text = [dicInfo objectForKey:@"detail"];
    cell.toggleSwitch.on = [[dicInfo objectForKey:@"enable"] boolValue];
    
    return cell;
}

#pragma mark - FunSDK Callback
- (void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    NSString *paramName = OCSTR(msg -> szStr);
    switch (msg->id) {
            case EMSG_DEV_GET_CONFIG_JSON:
        {
            if ([paramName isEqualToString:@"General.OneKeyMaskVideo"]) {
                if (msg->param1 < 0) {
                    [MessageUI ShowErrorInt:msg->param1];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    return;
                }
                
                BOOL enable = [[[retDic objectForKey:@"General.OneKeyMaskVideo.[0]"] objectForKey:@"Enable"] boolValue];
                
                NSMutableDictionary *dicTemp = [self.dataSource[0] mutableCopy];
                [dicTemp setObject:[NSNumber numberWithBool:enable] forKey:@"enable"];
                [self.dataSource replaceObjectAtIndex:0 withObject:dicTemp];
                
                [self.tbFunList reloadData];
                
                [SVProgressHUD dismiss];
            }
        }
            break;
            case EMSG_DEV_SET_CONFIG_JSON:
        {
            if ([paramName isEqualToString:@"General.OneKeyMaskVideo"]) {
                if (msg->param1 < 0) {
                    NSMutableDictionary *dicTemp = [self.dataSource[0] mutableCopy];
                    [dicTemp setObject:[NSNumber numberWithBool:msg->seq == 1 ? NO : YES] forKey:@"enable"];
                    [self.dataSource replaceObjectAtIndex:0 withObject:dicTemp];
                    
                    [self.tbFunList reloadData];
                    
                   [MessageUI ShowErrorInt:msg->param1];
                }
                else
                {
                    NSMutableDictionary *dicTemp = [self.dataSource[0] mutableCopy];
                    [dicTemp setObject:[NSNumber numberWithBool:msg->seq == 0 ? NO : YES] forKey:@"enable"];
                    [self.dataSource replaceObjectAtIndex:0 withObject:dicTemp];
                    
                    [self.tbFunList reloadData];
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }
        }
            break;
    }
}

#pragma mark - LazyLoad
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [_dataSource addObject:@{@"title":TS("Open_One_Key_Cover"),@"detail":TS("Open_One_Key_Cover_Tip"),@"enable":[NSNumber numberWithBool:NO]}];
    }
    
    return _dataSource;
}

-(UITableView *)tbFunList{
    if (!_tbFunList) {
        _tbFunList = [[UITableView alloc] init];
        _tbFunList.rowHeight = 60;
        _tbFunList.delegate = self;
        _tbFunList.dataSource = self;
        
        _tbFunList.tableFooterView = [UIView new];
    }
    
    return _tbFunList;
}

@end
