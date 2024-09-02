//
//  SensorlistVCViewController.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/25.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "SensorlistVCViewController.h"
#import "SensorListCell.h"
#import <FunSDK/FunSDK.h>
#import <Masonry/Masonry.h>
#import "SensorDeviceModel.h"
#import "SensorInfo.h"
#import "XMLinkWallSwitchCell.h"
#import "SensorConfig.h"

static NSString *const kSensorListCell = @"kSensorListCell";
static NSString *const kXMLinkWallSwitchCell = @"kXMLinkWallSwitchCell";

@interface SensorlistVCViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,strong) NSMutableArray <SensorDeviceModel *>*dataSource;
@property (nonatomic,strong) UITableView *tbList;
@property (nonatomic,copy) NSString *curSceneID;            // 当前场景ID 默认@“001”

@property (nonatomic,assign) int tempRow;
@property (nonatomic,copy) NSString *tempName;

@property (nonatomic,strong) SensorConfig *sensorConfig;

@end

@implementation SensorlistVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.curSceneID = @"001";
    
    [self configNav];
    
    [self configSubviews];
    
    [self myLayout];
    
    [SVProgressHUD showWithStatus:@"Getting sensor list...."];
    
    [self.sensorConfig getSensorList];
}

#pragma mark - UIConfig
- (void)configNav{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.navigationItem.title = TS("Sensor_Config");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor whiteColor],
      NSFontAttributeName:[UIFont systemFontOfSize:17]};
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(btnNavLeftClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnNavLeft = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    self.navigationItem.leftBarButtonItem = btnNavLeft;
    
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnRight setBackgroundImage:[UIImage imageNamed:@"device_list_add"] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(btnNavRightClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnNavRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
    self.navigationItem.rightBarButtonItem = btnNavRight;
}

- (void)configSubviews{
    [self.view addSubview:self.tbList];
}

- (void)myLayout{
    [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - EventAction
- (void)btnNavLeftClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNavRightClicked{
    [SVProgressHUD showWithStatus:@"Adding sensor...."];
    
    [self.sensorConfig beginAddSensor];
}

- (void)longPressHappened:(UILongPressGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.tbList];
    NSIndexPath *indexPath = [self.tbList indexPathForRowAtPoint:point];
    
    if (indexPath.row >= self.dataSource.count || !indexPath) {
        return;
    }
    
    self.tempRow = (int)indexPath.row;
    
    __weak typeof(self)weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:TS("Delete") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDictionary *dicInfo = [weakSelf.dataSource objectAtIndex:self.tempRow].dicListInfo;
        
        [SVProgressHUD showWithStatus:@"Deleting sensor...."];
        
        [weakSelf.sensorConfig beginDeleteSensor:[dicInfo objectForKey:@"DevID"]];
    }];

    UIAlertAction *changeNameAction = [UIAlertAction actionWithTitle:TS("Change_Name") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf showNameInputView];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];

    [alert addAction:deleteAction];
    [alert addAction:changeNameAction];
    [alert addAction:cancelAction];

    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)showNameInputView{
    __weak typeof(self)weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("Change_Name") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *name = alert.textFields[0].text;
        if (name.length <= 0) {
            name = alert.textFields[0].placeholder;
        }
        
        self.tempName = name;
        NSDictionary *dicInfo = [weakSelf.dataSource objectAtIndex:self.tempRow].dicListInfo;
        
        [SVProgressHUD showWithStatus:@"Changing sensor name...."];
        
        [weakSelf.sensorConfig changeSensorName:name sensorID:[dicInfo objectForKey:@"DevID"]];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = TS("Input_Name");
    }];
    
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Delegate
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SensorDeviceModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if ([[model.dicListInfo objectForKey:@"DevType"] intValue] == DEV_TYPE_WALLSWITCH) {
        XMLinkWallSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kXMLinkWallSwitchCell];
        [cell configureCellWithModel:[self.dataSource objectAtIndex:indexPath.row]];
        __weak typeof(self) weakSelf = self;
        cell.WallSwitchClickedAction = ^(NSInteger index, BOOL selected) {
            int controlMask = 0;
            int ignoreMask = 0;
            
            if (selected) {
                if (index == 1) {
                    ignoreMask = ignoreMask | 6;
                    controlMask = controlMask | 1;

                }
                else if (index == 2){
                    ignoreMask = ignoreMask | 5;
                    controlMask = controlMask | 2;
                }
                else{
                    ignoreMask = ignoreMask | 3;
                    controlMask = controlMask | 4;
                }
            }
            else{
                if (index == 1) {
                    ignoreMask = ignoreMask | 6;
                }
                else if (index == 2){
                    ignoreMask = ignoreMask | 5;
                }
                else{
                    ignoreMask = ignoreMask | 3;
                }
            }
            
            
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
            
            /*
             控制墙壁开关状态 具体参数意思查阅传感器文档
             */
            char cfg[1024];
            sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"ChangeSwitchState\", \"Arg1\" : \"%s\", \"SensorState\" : {\"ControlMask\":%d,\"IgnoreMask\":%d}} }", [[model.dicListInfo objectForKey:@"DevID"] UTF8String], controlMask,ignoreMask);
            FUN_DevCmdGeneral(weakSelf.msgHandle, [channel.deviceMac UTF8String], 2046, "ChangeSwitchState", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, (int)indexPath.row);
        };
        
        return cell;
    }else{
        SensorListCell *cell = [tableView dequeueReusableCellWithIdentifier:kSensorListCell];
        cell.indexRow = indexPath.row;
        
        [cell listenStatue:^(int statue, int indexRow) {
            __weak typeof(self)weakSelf = self;
            NSDictionary *info = [self.dataSource objectAtIndex:indexRow].dicListInfo;
            
            if ([[info objectForKey:@"DevType"] intValue] == DEV_TYPE_SOCKET) {
                ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
                
                char cfg[1024];
                
                /*
                 控制插座开关状态 具体参数意思查阅传感器文档
                 */
                
                sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"ChangeSocketState\", \"Arg1\" : \"%s\", \"SensorState\" : {\"Command\":%d}} }", [[model.dicListInfo objectForKey:@"DevID"] UTF8String], statue);
                FUN_DevCmdGeneral(weakSelf.msgHandle, [channel.deviceMac UTF8String], 2046, "ChangeSocketState", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, (int)indexPath.row);
            }else{
                [weakSelf.sensorConfig beginChangeStatueOpen:statue devID:[info objectForKey:@"DevID"]];
            }
            
        }];
        
        cell.lbTitle.text = [NSString stringWithFormat:@"Name:%@Type:%i",[model.dicListInfo objectForKey:@"DevName"],[[model.dicListInfo objectForKey:@"DevType"] intValue]];
        
         if ([[model.dicListInfo objectForKey:@"DevType"] intValue] == DEV_TYPE_SOCKET) {
             int status = [[model.dicStatusInfo objectForKey:@"DevStatus"] intValue];
             cell.statueSwitch.on = status == 1 ? YES : NO;
         }else{
             cell.statueSwitch.on = [[model.dicListInfo objectForKey:@"Status"] boolValue];
         }
        
        
        return cell;
    }
}

#pragma mark - FunSDK Result
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->param1 < 0) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",(int)msg->param1]];
            } else{
                if (msg->param3 == 2046) {
                    [SVProgressHUD dismiss];
                    
                    NSString *cmdName = [NSString stringWithUTF8String:msg->szStr];
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        return;
                    }
                    
                    int ret = [retDic[@"Ret"] intValue];
                    if (ret != 100) {
                        // operation failed
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"ret%i",ret]];
                    } else {
                        if ([cmdName isEqualToString:@"StartAddDev"]) {// 添加传感器
                            NSDictionary *startAddDevDic = retDic[@"StartAddDev"];
                            if (startAddDevDic) {
                                [SVProgressHUD showSuccessWithStatus:@"Add Success"];
                                
                                // startAddDevDic contains sensor device info
                                // key @"DevID" use this to modify sensor info like change DevName or Status
                                // key @"DevName"
                                // key @"DevType" distinguish device type just like gass or smoke sensor ,they have different DevType
                                // key @"Status" this value meas alarm message will send to camera .Only keep it open (Status = 1) ,you can get push message.
                                SensorDeviceModel *device = [[SensorDeviceModel alloc] init];
                                device.dicListInfo = [startAddDevDic mutableCopy];
                                [self.dataSource addObject:device];
                                [self.tbList reloadData];
                            }
                        }else if ([cmdName isEqualToString:@"ChangeDevName"]){// 修改传感器名字
                            NSMutableDictionary *dicChange = [[self.dataSource objectAtIndex:self.tempRow] mutableCopy];
                            [dicChange setObject:self.tempName forKey:@"DevName"];
                            //[self.dataSource replaceObjectAtIndex:self.tempRow withObject:dicChange];
                            
                            [self.tbList reloadData];
                        }else if ([cmdName isEqualToString:@"GetAllDevList"]){// 获取传感器列表
                            NSArray *arr = [retDic objectForKey:@"GetAllDevList"];
                            if (arr && ![[NSNull null] isEqual:arr]) {
                                [self.dataSource removeAllObjects];
                                for (int i = 0; i < arr.count; i ++) {
                                    SensorDeviceModel *device = [[SensorDeviceModel alloc] init];
                                    device.dicListInfo = [[arr objectAtIndex:i] mutableCopy];
                                    [self.dataSource addObject:device];
                                    
                                    [self.sensorConfig requestSensorState:[device.dicListInfo objectForKey:@"DevID"]];
                                }
                            }
                            
                            [self.tbList reloadData];
                        }else if ([cmdName isEqualToString:@"GetLinkState"]){// 判断传感器是否连接 如果已经连接去请求具体状态
                            NSDictionary *linkStateDic = retDic[@"GetLinkState"];
                            if (linkStateDic) {
                                NSString *sensorID = linkStateDic[@"DevID"];
                                int num = [linkStateDic[@"LinkState"] intValue];
                                BOOL bOnline = num == 1 ? YES : NO;
                                
                                for (int i = 0; i < self.dataSource.count; i ++) {
                                    SensorDeviceModel *linkDev = self.dataSource[i];
                                    if ([[linkDev.dicListInfo objectForKey:@"DevID"] isEqualToString:sensorID]) {
                                        linkDev.ifOnline = bOnline;
                                        if (bOnline) {
                                            [self.sensorConfig requestSensorDetailStatus:sensorID];
                                        }
                                        
                                        break;
                                    }
                                }
                                
                                [self.tbList reloadData];
                            }
                        }else if ([cmdName isEqualToString:@"InquiryStatus"]){// 传感器具体状态
                            NSDictionary *inquiryStatusDic = retDic[@"InquiryStatus"];
                            if (inquiryStatusDic) {
                                NSString *sensorID = inquiryStatusDic[@"DevID"];
                                
                                for (int i = 0; i < self.dataSource.count; i ++) {
                                    SensorDeviceModel *linkDev = self.dataSource[i];
                                    if ([[linkDev.dicListInfo objectForKey:@"DevID"] isEqualToString:sensorID]) {
                                        linkDev.dicStatusInfo = [inquiryStatusDic mutableCopy];
                                    }
                                }
                            }
                            
                            [self.tbList reloadData];
                        }else if ([cmdName isEqualToString:@"DeleteDev"]){// 删除成功
                            [self.dataSource removeObjectAtIndex:self.tempRow];
                            
                            [self.tbList reloadData];
                        }else if ([cmdName isEqualToString:@"ChangeSwitchState"]){// 修改push状态成功
                            if (msg->seq < self.dataSource.count) {
                                SensorDeviceModel *model = [self.dataSource objectAtIndex:msg->seq];
                                NSString *sensorID = [model.dicListInfo objectForKey:@"DevID"];
                                [self.sensorConfig requestSensorDetailStatus:sensorID];
                            }
                        }else if ([cmdName isEqualToString:@"ChangeSocketState"]){// 改变插座状态成功
                            if (msg->seq < self.dataSource.count) {
                                SensorDeviceModel *model = [self.dataSource objectAtIndex:msg->seq];
                                NSString *sensorID = [model.dicListInfo objectForKey:@"DevID"];
                                [self.sensorConfig requestSensorDetailStatus:sensorID];
                            }
                        }else if ([cmdName isEqualToString:@"GetModeConfig"]) {// 获取场景模式
                            NSDictionary *modeConfigDic = retDic[@"GetModeConfig"];
                            
                            NSString *sceneId = modeConfigDic[@"CurMode"];
                            
                            self.curSceneID = sceneId;
                        }else if ([cmdName isEqualToString:@"StopAddDev"]){//停止配对
                            
                        }
                    }
            }
        }
    }
    }
}

#pragma mark - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbList.delegate = self;
        _tbList.dataSource = self;
        [_tbList registerClass:[SensorListCell class] forCellReuseIdentifier:kSensorListCell];
        [_tbList registerClass:[XMLinkWallSwitchCell class] forCellReuseIdentifier:kXMLinkWallSwitchCell];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHappened:)];
        longPress.minimumPressDuration = 0.5;
        
        [_tbList addGestureRecognizer:longPress];
        
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSource;
}

- (SensorConfig *)sensorConfig{
    if (!_sensorConfig) {
        _sensorConfig = [[SensorConfig alloc] init];
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        _sensorConfig.msgHandle = self.msgHandle;
    }
    
    return _sensorConfig;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
}

@end
