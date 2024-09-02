//
//  XMDeviceOrientationManager.h
//   
//
//  Created by Tony Stark on 2022/8/15.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备方向
typedef NS_ENUM(NSUInteger, XMDeviceOrientation) {
    XMDeviceOrientationPortrait = 0,  //竖屏
    XMDeviceOrientationLandscapeLeft,
    XMDeviceOrientationLandscapeRight,
    XMDeviceOrientationPortraitUpsideDown,
};

NS_ASSUME_NONNULL_BEGIN

@interface XMDeviceOrientationManager : NSObject

//MARK: 获取当前设备方向
+ (XMDeviceOrientation)deviceOrientatoin;
//MARK: 强制改变当前设备方向
+ (void)changeDeviceOrientation:(XMDeviceOrientation)orientation;

//MARK: 尝试竖屏
+ (BOOL)tryChangeDeviceOrientationPortrait;
//MARK: 横竖屏切换
+ (void)deviceOrientationPortraitAndUpsideDownSwitching;

//MARK: VC属性发生变化 需要改变支持旋转方向时 提前调用 否则界面会异常
+ (void)preUpdateVCSupportedInterfaceOrientations:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
