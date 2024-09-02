//
//  DeviceLoginTipsManager.m
//   
//
//  Created by Tony Stark on 2021/9/10.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "DeviceLoginTipsManager.h"
#import "NSString+Utils.h"
#import "UIView+Layout.h"
#import <FunSDK/FunSDK.h>

@interface DeviceLoginTipsManager () <UITextFieldDelegate>

//MARK: 等待展示的提示
@property (nonatomic,strong) NSMutableArray *dataSourceWaitForShow;
//MARK: 是否正在展示
@property (nonatomic,assign) BOOL showing;

@end
@implementation DeviceLoginTipsManager

+ (instancetype)shareInstance{
    static DeviceLoginTipsManager *loginTipsManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginTipsManager = [[DeviceLoginTipsManager alloc] init];
    });
    
    return loginTipsManager;
}

//MARK: 加入需要提示的错误信息
- (void)addTipsInfo:(DeviceLoginTipsType)type devID:(NSString *)devID channel:(int)channnel changePwd:(BOOL)changePwd{
    NSString *addInfo = [NSString stringWithFormat:@"%i_%@_%i_%@",type,devID,channnel,[NSNumber numberWithBool:changePwd]];
    //判断之前是否存在
    BOOL existTip = NO;
    for (int i = 0; i < self.dataSourceWaitForShow.count; i++) {
        NSString *info = [self.dataSourceWaitForShow objectAtIndex:i];
        if ([info isEqualToString:addInfo]) {
            existTip = YES;
            break;
        }
    }
    
    if (!existTip) {
        [self.dataSourceWaitForShow addObject:addInfo];
    }
}

//MARK: 继续展示下一个提示
- (void)nextTips{
    if (self.showing) {
        return;
    }
    
    NSString *tipsInfo = [self.dataSourceWaitForShow objectAtIndex:0];
    if (tipsInfo) {
        self.showing = YES;
        self.userNameChanged = NO;
        
        NSArray *arrayInfo = [tipsInfo componentsSeparatedByString:@"_"];
        DeviceLoginTipsType type = (DeviceLoginTipsType)[[arrayInfo objectAtIndex:0] intValue];
        NSString *devID = [arrayInfo objectAtIndex:1];
        
        DeviceObject *devObject = [[DeviceControl getInstance]GetDeviceObjectBySN:devID];
        
        NSString *errorTitle = @"";
        NSString *errorContent = @"";
        if (type == TIPS_PWD_ERROR) {
            errorTitle = TS("TR_INPUT_PASSWORD");
            errorContent = [NSString stringWithFormat:@"%@\n%@",devObject.deviceName,TS("forget_password_error_dialog_tip")];
        }else if (type == TIPS_USER_ERROR){
            errorTitle = TS("TR_Dlg_User_Pwd_Error_Title");
            errorContent = [NSString stringWithFormat:@"%@\n%@",devObject.deviceName,TS("TR_Dlg_Dev_Set_User_Pwd_Tips")];
        }
        
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:errorTitle message:errorContent preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.dataSourceWaitForShow removeObjectAtIndex:0];
            if (weakSelf.TipsManagerClickCancelAction) {
                weakSelf.TipsManagerClickCancelAction();
            }
            weakSelf.showing = NO;
        }];
        //[actionCancel setValue:ThemeColor forKey:@"titleTextColor"];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.dataSourceWaitForShow removeObjectAtIndex:0];
            UITextField *tfUser = [alertVC.textFields objectAtIndex:0];
            UITextField *tfPwd= [alertVC.textFields objectAtIndex:1];
            NSString *user = (NSString *)tfUser.text;
            NSString *pwd = (NSString *)tfPwd.text;
            if (type == TIPS_PWD_ERROR && !self.userNameChanged) {
                user = weakSelf.fullUserName;
            }
            if (weakSelf.TipsManagerClickOKAction) {
                weakSelf.TipsManagerClickOKAction(user,pwd);
            }
            weakSelf.showing = NO;
        }];
        
        UIAlertAction *actionFindPwd = [UIAlertAction actionWithTitle:TS("reset_dev_pwd") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.dataSourceWaitForShow removeObjectAtIndex:0];
            if (weakSelf.TipsManagerClickFindPwdAction) {
                weakSelf.TipsManagerClickFindPwdAction();
            }
            weakSelf.showing = NO;
        }];
        //[actionOK setValue:ThemeColor forKey:@"titleTextColor"];
        
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionOK];
        
        BOOL changePwd = [[arrayInfo objectAtIndex:3] boolValue];
        if (type == TIPS_PWD_ERROR && changePwd) {
            [alertVC addAction:actionFindPwd];
        }
        
        //用户名输入框
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            weakSelf.tfUser = textField;
            textField.placeholder = TS("TR_Dlg_User_Exit_Title");
            textField.delegate = self;
//            textField.secureTextEntry = YES;
//            weakSelf.btnSecurityUser.selected = NO;
//            weakSelf.btnSecurityUser.frame = CGRectMake(0, 0, 30, 30);
//            [textField setRightView:weakSelf.btnSecurityUser];
//            [textField setRightViewMode:UITextFieldViewModeAlways];
        }];
        
        //密码输入框
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            weakSelf.tfPassword = textField;
            textField.placeholder = TS("Please input password");
            textField.secureTextEntry = YES;
            weakSelf.btnSecurityPassword.selected = NO;
            weakSelf.btnSecurityPassword.frame = CGRectMake(0, 0, 30, 30);
            [textField setRightView:weakSelf.btnSecurityPassword];
            [textField setRightViewMode:UITextFieldViewModeAlways];
        }];
        
        [[self getCurrentVC] presentViewController:alertVC animated:YES completion:^{
            if (type == TIPS_PWD_ERROR) {//如果密码错误 自动填充用户名
                char szUser[128] = {0};
                FUN_DevGetLocalUserName(devID.UTF8String, szUser);
                weakSelf.fullUserName = OCSTR(szUser);
                if (OCSTR(szUser).length <= 0) {
                    weakSelf.fullUserName = @"admin";
                }
                weakSelf.tfUser.text = weakSelf.fullUserName;
                [weakSelf.tfPassword becomeFirstResponder];
            }else if (type == TIPS_USER_ERROR){//如果是用户名错误
                [weakSelf.tfUser becomeFirstResponder];
            }
        }];
    }
    
}

//MARK: - EventAction
- (void)btnSecurityUserClicked{
    self.btnSecurityUser.selected = !self.btnSecurityUser.selected;
    self.tfUser.secureTextEntry = !self.btnSecurityUser.selected;
}

- (void)btnSecurityPasswordClicked{
    self.btnSecurityPassword.selected = !self.btnSecurityPassword.selected;
    self.tfPassword.secureTextEntry = !self.btnSecurityPassword.selected;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.userNameChanged = YES;
    return YES;
}

//MARK: - 获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController == nil) {
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        rootViewController = delegate.window.rootViewController;
    }
    UIViewController *currentVC = [UIView getCurrentVCFrom:rootViewController];
    return currentVC;
}

//MARK: - LazyLoad
- (NSMutableArray *)dataSourceWaitForShow{
    if (!_dataSourceWaitForShow) {
        _dataSourceWaitForShow = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSourceWaitForShow;
}

- (UIButton *)btnSecurityUser{
    if (!_btnSecurityUser) {
        _btnSecurityUser = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSecurityUser setBackgroundImage:[UIImage imageNamed:@"hidden_pwd"] forState:UIControlStateNormal];
        [_btnSecurityUser setBackgroundImage:[UIImage imageNamed:@"show.png"] forState:UIControlStateSelected];
        [_btnSecurityUser addTarget:self action:@selector(btnSecurityUserClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnSecurityUser;
}

- (UIButton *)btnSecurityPassword{
    if (!_btnSecurityPassword) {
        _btnSecurityPassword = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSecurityPassword setBackgroundImage:[UIImage imageNamed:@"hidden_pwd"] forState:UIControlStateNormal];
        [_btnSecurityPassword setBackgroundImage:[UIImage imageNamed:@"show.png"] forState:UIControlStateSelected];
        [_btnSecurityPassword addTarget:self action:@selector(btnSecurityPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnSecurityPassword;
}

@end
