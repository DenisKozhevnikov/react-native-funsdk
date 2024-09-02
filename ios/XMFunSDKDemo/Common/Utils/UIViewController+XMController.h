//
//  UIViewController+XMController.h
//  XMUIKit
//
//  Created by coderXY on 2022/9/15.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XMController)

/** 获取广义mainWindow的rootViewController */
+ (UIViewController*)xm_rootViewController;
/** 获取window */
+ (UIWindow *)xm_window;
/** 获取Window当前显示的视图控制器 */
+ (UIViewController *)xm_currentViewController;
/** 获取window当前显示的视图控制器 vc：从哪个界面开始发查找 */
+ (UIViewController *)xm_currentViewControllerFromController:(UIViewController *)controller;
/** 通过视图获取该视图所在的控制器 */
+ (UIViewController *)xm_currentViewControllerWithCurrentView:(UIView *)currentView;

#pragma mark - 视图控制器跳转
/** 多次presentViewController后直接返回到根视图 场景：比如从A跳转到B，从B跳转到C，从C跳转到D，然后由D直接返回到A */
- (void)xm_dismissViewControllerToRootControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;
/** 多次presentViewController后直接返回到指定层 场景：比如从A跳转到B，从B跳转到C，从C跳转到D，然后由D直接返回到B */
- (void)xm_dismissViewControllerToController:(Class)vcClass animated:(BOOL)animated completion:(void(^)(void))completion;

@end

//NS_ASSUME_NONNULL_END
