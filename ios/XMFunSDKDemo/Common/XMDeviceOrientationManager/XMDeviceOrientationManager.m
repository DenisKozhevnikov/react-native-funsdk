//
//  XMDeviceOrientationManager.m
//   
//
//  Created by Tony Stark on 2022/8/15.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "XMDeviceOrientationManager.h"
#import "UIViewController+XMController.h"

@implementation XMDeviceOrientationManager

//MARK: 获取当前设备方向
+ (XMDeviceOrientation)deviceOrientatoin{
    XMDeviceOrientation curOrientation = XMDeviceOrientationPortrait;
    if (@available(iOS 16.0, *)){
        UIViewController *vc = [UIViewController xm_rootViewController];
        if ([vc respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]){
            [vc setNeedsUpdateOfSupportedInterfaceOrientations];
        }
        UIWindowScene *scene = (UIWindowScene *)[[[[UIApplication sharedApplication] connectedScenes] allObjects] firstObject];
        if (scene.interfaceOrientation ==  UIInterfaceOrientationPortraitUpsideDown){
            curOrientation = XMDeviceOrientationPortraitUpsideDown;
        }else if (scene.interfaceOrientation ==  UIInterfaceOrientationLandscapeLeft){
            curOrientation = XMDeviceOrientationLandscapeRight;
        }else if (scene.interfaceOrientation ==  UIInterfaceOrientationLandscapeRight){
            curOrientation = XMDeviceOrientationLandscapeLeft;
        }
    }else{
        NSNumber *orientation = [[UIDevice currentDevice] valueForKeyPath:@"orientation"];
        if ([orientation isEqualToNumber:[NSNumber numberWithInteger:UIDeviceOrientationPortraitUpsideDown]]) {
            curOrientation = XMDeviceOrientationPortraitUpsideDown;
        }else if ([orientation isEqualToNumber:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft]]) {
            curOrientation = XMDeviceOrientationLandscapeLeft;
        }else if ([orientation isEqualToNumber:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight]]) {
            curOrientation = XMDeviceOrientationLandscapeRight;
        }
    }
    
    return curOrientation;
}

//MARK: 强制改变当前设备方向
+ (void)changeDeviceOrientation:(XMDeviceOrientation)orientation{
    if (@available(iOS 16.0, *)){
        UIViewController *vc = [UIViewController xm_rootViewController];
        if ([vc respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]){
            [vc setNeedsUpdateOfSupportedInterfaceOrientations];
        }
        
        UIInterfaceOrientationMask setOrientation = UIInterfaceOrientationMaskPortrait;
        if (orientation == XMDeviceOrientationPortraitUpsideDown){
            setOrientation = UIInterfaceOrientationMaskPortraitUpsideDown;
        }else if (orientation == XMDeviceOrientationLandscapeLeft){
            setOrientation = UIInterfaceOrientationMaskLandscapeRight;
        }else if (orientation == XMDeviceOrientationLandscapeRight){
            setOrientation = UIInterfaceOrientationMaskLandscapeLeft;
        }
        
        UIWindowScene *scene = (UIWindowScene *)[[[[UIApplication sharedApplication] connectedScenes] allObjects] firstObject];
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:setOrientation];
        [scene requestGeometryUpdateWithPreferences:geometryPreferences
            errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"xmxm=：setorientatioin result:%@", error);
        }];
    }else{
        UIDeviceOrientation setOrientation = UIDeviceOrientationPortrait;
        if (orientation == XMDeviceOrientationPortraitUpsideDown){
            setOrientation = UIDeviceOrientationPortraitUpsideDown;
        }else if (orientation == XMDeviceOrientationLandscapeLeft){
            setOrientation = UIDeviceOrientationLandscapeLeft;
        }else if (orientation == XMDeviceOrientationLandscapeRight){
            setOrientation = UIDeviceOrientationLandscapeRight;
        }
        
        //避免有时执行失败 需要在正式设置方向前重置
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:setOrientation] forKey:@"orientation"];
    }
}

//MARK: 尝试竖屏
+ (BOOL)tryChangeDeviceOrientationPortrait{
    BOOL excute = NO;  //判断是否执行竖屏 返回yes表示执行
//    XMDeviceOrientation orientation = [self deviceOrientatoin];
//    if (orientation != XMDeviceOrientationPortrait){
//        excute = YES;
//        [self changeDeviceOrientation:XMDeviceOrientationPortrait];
//    }else{
//        excute = YES;
//        [self changeDeviceOrientation:XMDeviceOrientationPortrait];
//    }
    //个别手机平放在水平桌面获取到方向异常 统一强制切换竖屏
    excute = YES;
    [self changeDeviceOrientation:XMDeviceOrientationPortrait];
    
    return excute;
}

//MARK: 横竖屏切换
+ (void)deviceOrientationPortraitAndUpsideDownSwitching{
    XMDeviceOrientation orientation = [self deviceOrientatoin];
    if (orientation == XMDeviceOrientationPortrait){
        orientation = XMDeviceOrientationLandscapeLeft;
    }else{
        orientation = XMDeviceOrientationPortrait;
    }
    
    [self changeDeviceOrientation:orientation];
}

//MARK: VC属性发生变化 需要改变支持旋转方向时 提前调用 否则界面会异常
+ (void)preUpdateVCSupportedInterfaceOrientations:(UIViewController *)vc{
    if (@available(iOS 16.0, *)){
        if (!vc){
            vc = [UIViewController xm_rootViewController];
        }
        
        [vc setNeedsUpdateOfSupportedInterfaceOrientations];
    }
}

@end
