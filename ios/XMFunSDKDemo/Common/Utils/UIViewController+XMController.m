//
//  UIViewController+XMController.m
//  XMUIKit
//
//  Created by coderXY on 2022/9/15.
//

#import "UIViewController+XMController.h"

@implementation UIViewController (XMController)
// 获取当前根视图
+ (UIViewController *)xm_rootViewController{
    return [[UIViewController xm_window] rootViewController];
}
// 获取当前windwo 注意：keyWindow 和 delegate.window的区别
+ (UIWindow *)xm_window{
    return [UIApplication sharedApplication].delegate.window;
}
//获取当前控制器
+ (UIViewController *)xm_currentViewController{
    UIViewController *currentVC = nil;
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIViewController xm_window].rootViewController;
    currentVC = [UIViewController xm_currentViewControllerFromController:vc];
    return currentVC;
}
//
+ (UIViewController *)xm_currentViewControllerFromController:(UIViewController *)controller{
    UIViewController *currentVC = nil;
    UIViewController *tempVC = nil;
    if ([controller presentedViewController]) {
        // 优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        tempVC = [controller presentedViewController];
        currentVC = [self xm_currentViewControllerFromController:tempVC];
    }else if ([controller isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        tempVC = [(UITabBarController *)controller selectedViewController];
        currentVC = [self xm_currentViewControllerFromController:tempVC];
    }else if ([controller isKindOfClass:[UINavigationController class]]) {
        // 根视图为navigation
        tempVC = [(UINavigationController *)controller visibleViewController];
        currentVC = [self xm_currentViewControllerFromController:tempVC];
    }else{
        // 根视图为非导航类
        currentVC = controller;
    }
    return currentVC;
}

+ (UIViewController *)xm_currentViewControllerWithCurrentView:(UIView *)currentView{
    UIResponder *responder = currentView;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}
#pragma mark - action event
- (void)xm_dismissViewControllerToRootControllerAnimated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *tempVC = self;
    while (tempVC.presentingViewController) {
        tempVC = tempVC.presentingViewController;
    }
    [tempVC dismissViewControllerAnimated:animated completion:completion];
}

- (void)xm_dismissViewControllerToController:(Class)vcClass animated:(BOOL)animated completion:(void (^)(void))completion{
    if (!vcClass) return;
    UIViewController *tempVC = self.presentingViewController;
    while ([[tempVC.presentingViewController class] isEqual:vcClass]) {
        tempVC = tempVC.presentingViewController;
    }
    [tempVC dismissViewControllerAnimated:animated completion:completion];
}

@end
