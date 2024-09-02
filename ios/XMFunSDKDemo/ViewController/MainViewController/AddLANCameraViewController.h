//
//  AddLANCameraViewController.h
//  XMEye
//
//  Created by 杨翔 on 2020/5/20.
//  Copyright © 2020 Megatron. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddLANCameraViewController : BaseViewController

@property (nonatomic, strong) DeviceObject *deviceInfo;
/** 是否自动添加流程 */
@property (nonatomic, assign) JFConfigType configType;
/** 配网model */
@property (nonatomic, strong) JFDevConfigServiceModel *model;

@end

NS_ASSUME_NONNULL_END
