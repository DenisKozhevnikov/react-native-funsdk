//
//  DeviceLoginTipsManager.h
//   
//
//  Created by Tony Stark on 2021/9/10.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int,DeviceLoginTipsType){
    TIPS_PWD_ERROR = 0,     // 密码错误提示
    TIPS_USER_ERROR,    // 用户名错误
};

NS_ASSUME_NONNULL_BEGIN

/*
 设备登录提示管理者 密码错误 用户名错误都可以使用
 */
@interface DeviceLoginTipsManager : NSObject

@property (nonatomic,copy) void (^TipsManagerClickOKAction)(NSString *user,NSString *password);
@property (nonatomic,copy) void (^TipsManagerClickCancelAction)();

@property (nonatomic,copy) void (^TipsManagerClickFindPwdAction)();

//MARK: 密码模式切换按钮和输入框
@property (nonatomic,strong) UIButton *btnSecurityUser;
@property (nonatomic,weak) UITextField *tfUser;
@property (nonatomic,assign) BOOL userNameChanged; //检测用户名是否变化 如果是密码错且变化 就是用变化的用户名
@property (nonatomic,copy) NSString *fullUserName;
@property (nonatomic,strong) UIButton *btnSecurityPassword;
@property (nonatomic,weak) UITextField *tfPassword;

+ (instancetype)shareInstance;

//MARK: 加入需要提示的错误信息
- (void)addTipsInfo:(DeviceLoginTipsType)type devID:(NSString *)devID channel:(int)channnel changePwd:(BOOL)changePwd;;
//MARK: 继续展示下一个提示
- (void)nextTips;

@end

NS_ASSUME_NONNULL_END
