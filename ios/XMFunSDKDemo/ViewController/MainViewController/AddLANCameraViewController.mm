//
//  AddLANCameraViewController.m
//  XMEye
//
//  Created by 杨翔 on 2020/5/20.
//  Copyright © 2020 Megatron. All rights reserved.
//

#import "AddLANCameraViewController.h"
#import "AddCameraTableViewCell.h"
#import <Masonry/Masonry.h>
#import <FunSDK/FunSDK.h>
#import "DeviceRandomPwdManager.h"
#import "DeviceManager.h"
#import "SystemInfoManager.h"

@interface AddLANCameraViewController ()<UITableViewDelegate,UITableViewDataSource, DeviceManagerDelegate>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) UIButton *addCameraBtn;

@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) UILabel *tipLab;

//密码强度提示框
@property (nonatomic, strong) UILabel *lbNewPwdTips;

@property (nonatomic, strong)SystemInfoManager *systemInfoManager;

@property (nonatomic, strong)DeviceManager *deviceManager;       //设备管理器

@end

@implementation AddLANCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    [self initData];
    
    [self configSubViews];
    
    if (JFConfigType_Wifi == self.configType) {
        //获取一下设备是不是随机密码和随机账户
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [[DeviceRandomPwdManager shareInstance] getDeviceRandomPwd:self.deviceInfo.deviceMac autoSetUserNameAndPassword:YES Completion:^(BOOL completion) {
            [SVProgressHUD dismiss];

            if (completion) {
                
                weakSelf.dataSourceDic = [[[DeviceRandomPwdManager shareInstance] getDeviceRandomPwdFromLocal:weakSelf.deviceInfo.deviceMac] mutableCopy];
                [weakSelf.tableview reloadData];
                [weakSelf configSubViews];
            }
        }];
    }
    [SVProgressHUD dismiss];
}

-(void)initData{
    self.titleArray = [@[@"Enter_Device_Name2",@"Serial_Number2",@"Enter_LoginName",@"Enter_LoginPassword"] mutableCopy];
    
    self.dataSourceDic = [[NSMutableDictionary alloc] initWithCapacity:0];
}

-(void)configSubViews{
    [self.view addSubview:self.tableview];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(NavHeight);
        make.left.equalTo(@25);
        make.centerX.equalTo(self);
        make.height.equalTo(@240);
    }];
    
    [self.view addSubview:self.addCameraBtn];
    [self.addCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-30);
        make.left.equalTo(@25);
        make.centerX.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    if ([[self.dataSourceDic objectForKey:@"random"] boolValue] == NO) {
        [self.view addSubview:self.tipLab];
        [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableview.mas_bottom).offset(10);
            make.left.equalTo(self.tableview).offset(5);
            make.centerX.equalTo(self);
            make.height.equalTo(@60);
        }];
        
        self.tipLab.text = [NSString stringWithFormat:@"*%@",TS("TR_Rules_Of_Dev_Pwd")];
        
        [self.view addSubview:self.lbNewPwdTips];
        [self.lbNewPwdTips mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipLab.mas_bottom).offset(5);
            make.left.equalTo(self.tipLab);
            make.right.equalTo(self.tipLab);
            make.height.equalTo(@20);
        }];
    }
}

#pragma mark -- UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCameraTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[AddCameraTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *string = [self.titleArray objectAtIndex:indexPath.row];
    cell.textfield.placeholder = TS([string UTF8String]);
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    image.image = [UIImage imageNamed:string];
    if ([string isEqualToString:@"UserName"]) {
        image.image = [UIImage imageNamed:@"Enter_LoginName.png"];
    }
    cell.textfield.leftView = image;
    cell.textfield.leftViewMode = UITextFieldViewModeAlways;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([string isEqualToString:@"Enter_Device_Name2"]) {
        cell.textfield.text = [NSString converSN:self.deviceInfo.deviceMac];
        image.image = [UIImage imageNamed:@"TR_Please_Input_Dev_Name"];
    }
    
    if ([string isEqualToString:@"Serial_Number2"]) {
        cell.textfield.text = self.deviceInfo.deviceMac;
        image.image = [UIImage imageNamed:@"TR_Input_Dev_Serial_Num"];
    }
    
    if ([string isEqualToString:@"Enter_LoginName"]) {
        cell.textfield.text = @"";
    }
    
    if([string isEqualToString:@"Enter_LoginPassword"])
    {
        cell.textfield.text = @"";
    }
    
    //如果设备支持随机用户名密码功能，那他的初始登录用户名和密码是随机的，通过GetRandomUser可以获取到
    if ([[self.dataSourceDic objectForKey:@"random"] boolValue]) {
        if ([string isEqualToString:@"Enter_LoginName"]) {
            //支持随即用户名密码的设备可以修改登录用户名，所以用户名要支持修改
            cell.textfield.placeholder = TS("TR_Set_Dev_User_Tip");
            cell.textfield.text = @"";
            cell.textfield.userInteractionEnabled = YES;
        }
        
        if ([string isEqualToString:@"Enter_LoginPassword"]) {
            cell.textfield.placeholder = TS("TR_Set_Dev_Pwd_Tip");
            cell.textfield.text = @"";
            
            [cell.textfield addTarget:self action:@selector(editChanged:) forControlEvents:UIControlEventEditingChanged];
        }
    }
    else
    {
        //不支持随即用户名密码的设备不可以修改登录用户名，只能是默认admin
        if ([string isEqualToString:@"Enter_LoginName"]) {
            cell.textfield.text = @"admin";
            cell.textfield.userInteractionEnabled = NO;
        }
        if ([string isEqualToString:@"Enter_LoginPassword"]) {
            [cell.textfield addTarget:self action:@selector(editChanged:) forControlEvents:UIControlEventEditingChanged];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCameraTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textfield becomeFirstResponder];
}


- (void)editChanged:(UITextField *)textField{
}


#pragma mark -- lazyload
-(UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 60;
        [_tableview registerClass:[AddCameraTableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableview.tableFooterView = [UIView new];
    }
    return _tableview;
}

-(UIButton *)addCameraBtn{
    if (!_addCameraBtn) {
        _addCameraBtn = [[UIButton alloc] init];
        [_addCameraBtn setTitle:TS("Add") forState:UIControlStateNormal];
        [_addCameraBtn addTarget:self action:@selector(addLANCamera) forControlEvents:UIControlEventTouchUpInside];
        [_addCameraBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_addCameraBtn setBackgroundColor:GlobalMainColor];
    }
    return _addCameraBtn;
}

- (void)devConfigWifiHandle{
    
}

-(void)addLANCamera{
    //不允许设备登录名和设备密码相同
    if ([[self getCameraLoginName] isEqual:[self getCameraLoginPassword]]) {
        [SVProgressHUD showErrorWithStatus:TS("TR_Pwd_Same_Username") duration:2.0];
        return;
    }
    
    NSString *devName = [self getCameraName];
    if (![NSString isValidateUserName:devName]){
        [SVProgressHUD showErrorWithStatus:TS("Invalid_DeviceName") duration:3.0];
        return;
    }
    
    if ([devName isEqualToString:self.deviceInfo.deviceMac]) {
        devName = [NSString converSN:devName];
    }
    
    NSString *devUser = [self getCameraLoginName];
    NSString *devPwd = [self getCameraLoginPassword];
    if (JFConfigType_Wifi == self.configType || !self.deviceInfo.devTokenEnable) {
        if ([[self.dataSourceDic objectForKey:@"random"] boolValue]){
            //修改随即用户名密码设备需要用到ChangeRandomUser接口，和普通设备的接口不同
            //校验一下设备账户名是否符合要求
            if (devUser.length <= 0) {
                [SVProgressHUD showErrorWithStatus:TS("TR_Set_Dev_User_Not_Empty")];
                return;
            }
            
            DevicePasswordErrorType errorNameType = [NSString matchDeviceUserNameRule:devUser];
            NSString *containsNameStr = [NSString containsSpecialCharacterWithUserName:devUser];
            if (errorNameType != DPErrorTypeNone){
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString getDeviceUserNameErrorTips:errorNameType contains:containsNameStr] message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertVC addAction:actionOK];
                
                [self presentViewController:alertVC animated:YES completion:nil];
                return;
            }
            
            //检查设备密码是否合法
            if (![NSString deviceIsValidatePassword:devPwd]) {
                [SVProgressHUD showErrorWithStatus:TS("TR_Dev_Pwd_Edit_Error")];
                return;
            }
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            //如果是随机用户和随机密码需要先去修改设备用户名和密码
            __weak typeof(self) weakSelf = self;
            [[DeviceRandomPwdManager shareInstance] ChangeRandomUserWithDevID:self.deviceInfo.deviceMac newUser:devUser newPassword:devPwd result:^(int result, NSString *adminToken, NSString *guestToken) {
                if (result >= 0) {
                    
                    weakSelf.deviceManager.loginToken = adminToken;
                    
                    [weakSelf addDeviceWithDeviceName:devName];
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%d",result]];
                }
            }];
        }
        else{
            if (devPwd.length == 0 ) {
                [self addDeviceWithDeviceName:devName];
            }
            else
            {
                //检查设备密码是否合法
                if (![NSString deviceIsValidatePassword:devPwd]) {
                    [SVProgressHUD showErrorWithStatus:TS("TR_Dev_Pwd_Edit_Error")];
                    return;
                }
                
                signed char  OLdPsw[32] = {0};
                MD5Encrypt(OLdPsw,(unsigned char*)[@"" UTF8String]);
                
                signed char  encryNewPsw[32] = {0};
                MD5Encrypt(encryNewPsw,(unsigned char*)[devPwd UTF8String]);
                NSDictionary* dictNewUserInfo = @{ @"UserName":@"admin", @"PassWord":[NSString stringWithUTF8String_OutNil: (const char*)OLdPsw], @"NewPassWord":[NSString stringWithUTF8String_OutNil: (const char*)encryNewPsw], @"EncryptType":@"MD5" };
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:dictNewUserInfo options:NSJSONWritingPrettyPrinted error:&error];
                NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                
                
                FUN_DevSetLocalPwd(SZSTR(self.deviceInfo.deviceMac), "admin", "");
                FUN_DevSetConfig_Json(SELF, SZSTR(self.deviceInfo.deviceMac), "ModifyPassword",
                                      [strValues UTF8String],[strValues length]+1);
            }
        }
    }
    if (JFConfigType_Wifi != self.configType && self.deviceInfo.devTokenEnable) {
        SDBDeviceInfo devInfo = {0};
        STRNCPY(devInfo.Devname, SZSTR(devName));
        STRNCPY(devInfo.Devmac, SZSTR(self.deviceInfo.deviceMac));
        if ([self getCameraLoginName].length <= 0) {
            STRNCPY(devInfo.loginName, SZSTR(@"admin"));
        }else{
            STRNCPY(devInfo.loginName, SZSTR([self getCameraLoginName]));
        }
        STRNCPY(devInfo.loginPsw, SZSTR([self getCameraLoginPassword]));
        devInfo.nType = self.deviceInfo.nType;
        // 添加设备
        [self.deviceManager addTokenDevWithDevSerialNumber:self.deviceInfo.deviceMac deviceName:devName loginName:OCSTR(devInfo.loginName) loginPassword:OCSTR(devInfo.loginPsw) devType:devInfo.nType configModel:self.model];
    }
}

-(void)addDeviceWithDeviceName:(NSString *)devName{
    SDBDeviceInfo devInfo = {0};
    STRNCPY(devInfo.Devname, SZSTR(devName));
    STRNCPY(devInfo.Devmac, SZSTR(self.deviceInfo.deviceMac));
    
    if ([self getCameraLoginName].length <= 0) {
        STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    }else{
        STRNCPY(devInfo.loginName, SZSTR([self getCameraLoginName]));
    }
    
    STRNCPY(devInfo.loginPsw, SZSTR([self getCameraLoginPassword]));
    devInfo.nType = self.deviceInfo.nType;
    
    
    [SVProgressHUD show];
    
    //修改设备名称和设备密码
    [self.deviceManager changeDevicePsw:OCSTR(devInfo.Devmac) loginName:OCSTR(devInfo.loginName) password:OCSTR(devInfo.loginPsw)];
    //通过序列号添加
    [self.deviceManager addDeviceByWiFiConfig:OCSTR(devInfo.Devmac) deviceName:OCSTR(devInfo.Devname) loginName:OCSTR(devInfo.loginName) loginPassword:OCSTR(devInfo.loginPsw) devType:devInfo.nType];
}
#pragma mark - DeviceManagerDelegate
- (void)addDeviceResult:(int)result{
    if (result >= 0) {
        
    }else{
        [MessageUI ShowErrorInt:result];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

#pragma mark - FunSDK 回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_SYS_ADD_DEVICE:{         // 添加设备
            
            SDBDeviceInfo *pDevInfo = (SDBDeviceInfo *)msg->pObject;
            if (msg->param1 < 0) {
                if (msg->param1 == -99992 || msg->param1 == -604101) {
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showErrorWithStatus:TS("Device_Exist") duration:1];
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%d",msg->param1] duration:3];
                }
            }else{
//                [GUI SendMessag:@"NFOnAddDev" obj:pDevInfo p1:msg->param1];
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                    [[NSNotificationCenter defaultCenter]postNotificationName:SEARCHDEVSTATE object:nil];
//                });
            }
            
            break;
        }
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (msg->param1 < 0) {
//                [SVProgressHUD showErrorWithStatus:[SDKParser parseError:msg->param1] duration:3];
            }else{
            
                [self addDeviceWithDeviceName:[self getCameraName]];
            }
        }
            break;
        default:
            break;
    }
}

-(NSString *)getCameraName{
    AddCameraTableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.textfield.text.length <= 0) {
        return self.deviceInfo.deviceMac;
    }else{
        return cell.textfield.text;
    }
}

-(NSString *)getCameraLoginName{
    AddCameraTableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    NSString *userName = [cell.textfield.text lowercaseString];
    if ([userName isEqualToString:@"guest"] ||
        [userName isEqualToString:@"default"] ||
        [userName isEqualToString:@"666666"]) {
        NSString *error = [NSString stringWithFormat:@"%@%@",cell.textfield.text,TS("UserName_illegal")];
        [SVProgressHUD showErrorWithStatus:error];
        return @"";
    }
    
    return cell.textfield.text;
}

-(NSString *)getCameraLoginPassword{
    AddCameraTableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    return cell.textfield.text;
}

-(void)createNavigationBar{
    self.title = self.deviceInfo.deviceMac;
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnLeft setBackgroundColor:[UIColor clearColor]];
    [btnLeft setBackgroundImage:[[UIImage imageNamed:@"nav_back"] imageWithRenderingMode:UIImageRenderingModeAutomatic] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:14];
        _tipLab.text = [NSString stringWithFormat:@"*%@\n*%@",TS("TR_Dev_User_Input_Tip"),TS("TR_Rules_Of_Dev_Pwd")];
        _tipLab.textColor = [UIColor grayColor];
        _tipLab.numberOfLines = 3;
    }
    return _tipLab;
}

void MD5Encrypt(signed char *strOutput, unsigned char *strInput);

-(UILabel *)lbNewPwdTips{
    if (!_lbNewPwdTips) {
        _lbNewPwdTips = [[UILabel alloc] init];
        _lbNewPwdTips.font = [UIFont systemFontOfSize:14];
    }
    return _lbNewPwdTips;
}

-(SystemInfoManager *)systemInfoManager{
    if (!_systemInfoManager) {
        _systemInfoManager = [[SystemInfoManager alloc] init];
    }
    return _systemInfoManager;
}

-(DeviceManager *)deviceManager{
    if (!_deviceManager) {
        _deviceManager = [[DeviceManager alloc] init];
        _deviceManager.delegate = self;
    }
    return _deviceManager;
}
@end
