//
//  ShareDeviceVC.h
//  FunSDKDemo
//
//  Created by yefei on 2022/10/21.
//  Copyright © 2022 yefei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareDeviceVC : UIViewController
//分享权限
@property (nonatomic,copy) NSString *permissions;

@property (nonatomic, copy) NSString* devId;

@end

NS_ASSUME_NONNULL_END
