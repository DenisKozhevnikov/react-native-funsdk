//
//  UIAlertController+XMAlertController.m
//  XMUIKit
//
//  Created by coderXY on 2022/9/28.
//

#import "UIAlertController+XMAlertController.h"
#import "UIViewController+XMController.h"
#import <objc/runtime.h>
/** 操作按钮字体颜色 */
NSString *const TITLE_TEXT_COLOR = @"titleTextColor";

@implementation UIAlertController (XMAlertController)
#pragma mark - 可自定义操作按钮颜色
// 可自定义 actionTitle字体颜色
- (void)xm_showAlertWithActionTitle:(NSString *)actionTitle action:(void (^)(void))action{
    [self showAlertHandleWithSureTitle:actionTitle cancelTitle:nil sureAction:action cancelAction:nil];
}
// 可自定义 sureTitle、cancelTitle字体颜色
- (void)xm_showAlertWithSureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction{
    [self showAlertHandleWithSureTitle:sureTitle cancelTitle:cancelTitle sureAction:sureAction cancelAction:cancelAction];
}
#pragma mark -  无 title
// 自定义title
+ (void)xm_showAlertWithMessage:(NSString *)message actionTitle:(NSString *)actionTitle action:(void (^)(void))action{
    [UIAlertController showAlertHandleWithTitle:nil message:message sureTitle:actionTitle cancelTitle:nil sureAction:action cancelAction:nil];
}
// 无title ok alert
+ (void)xm_showAlertWithMessage:(NSString *)message sureTitle:(NSString *)sureTitle sureAction:(void(^)(void))sureAction{
    sureTitle = ISLEGALSTR(sureTitle)?sureTitle:@"确定";
    [UIAlertController showAlertHandleWithTitle:nil message:message sureTitle:sureTitle cancelTitle:nil sureAction:sureAction cancelAction:nil];
}
// 无title cancel alert
+ (void)xm_showAlertWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelAction:(void(^)(void))cancelAction{
    cancelTitle = ISLEGALSTR(cancelTitle)?cancelTitle:@"取消";
    [UIAlertController showAlertHandleWithTitle:nil message:message sureTitle:nil cancelTitle:cancelTitle sureAction:nil cancelAction:cancelAction];
}
// 无标题 确定和取消操作
+ (void)xm_showAlertWithMessage:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction{
    sureTitle = ISLEGALSTR(sureTitle)?sureTitle:@"确定";
    cancelTitle = ISLEGALSTR(cancelTitle)?cancelTitle:@"取消";
    [UIAlertController showAlertHandleWithTitle:nil message:message sureTitle:sureTitle cancelTitle:cancelTitle sureAction:sureAction cancelAction:cancelAction];
}
#pragma mark - 有title
// 自定义文本 无默认值
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle action:(void (^)(void))action{
    [UIAlertController showAlertHandleWithTitle:title message:message sureTitle:actionTitle cancelTitle:nil sureAction:action cancelAction:nil];
}
// 仅 确定 UIAlertActionStyle：UIAlertActionStyleDefault
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle sureAction:(void(^)(void))sureAction{
    title = ISLEGALSTR(title)?title:@"温馨提示";
    sureTitle = ISLEGALSTR(sureTitle)?sureTitle:@"确定";
    [UIAlertController showAlertHandleWithTitle:title message:message sureTitle:sureTitle cancelTitle:nil sureAction:sureAction cancelAction:nil];
}
// 仅 取消 UIAlertActionStyle：UIAlertActionStyleCancel
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelAction:(void(^)(void))cancelAction{
    title = ISLEGALSTR(title)?title:@"温馨提示";
    cancelTitle = ISLEGALSTR(cancelTitle)?cancelTitle:@"取消";
    [UIAlertController showAlertHandleWithTitle:title message:message sureTitle:nil cancelTitle:cancelTitle sureAction:nil cancelAction:cancelAction];
}
//
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction{
    title = ISLEGALSTR(title)?title:@"温馨提示";
    sureTitle = ISLEGALSTR(sureTitle)?sureTitle:@"确定";
    cancelTitle = ISLEGALSTR(cancelTitle)?cancelTitle:@"取消";
    [UIAlertController showAlertHandleWithTitle:title message:message sureTitle:sureTitle cancelTitle:cancelTitle sureAction:sureAction cancelAction:cancelAction];
}
#pragma mark - private method
#pragma mark - handle method
+ (void)showAlertHandleWithTitle:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction{
    if ((sureTitle.length <= 0 && cancelTitle.length <= 0)) return;
    dispatch_main_async_safe(^{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller showAlertHandleWithSureTitle:sureTitle cancelTitle:cancelTitle sureAction:sureAction cancelAction:cancelAction];
    });
}

#pragma mark - instance method
- (void)showAlertHandleWithSureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction{
    @XMWeakify(self)
    dispatch_main_async_safe(^{
        @XMStrongify(self)
        if ((sureTitle.length <= 0 && cancelTitle.length <= 0)) return;
        if (sureTitle.length > 0) {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (sureAction) {
                    sureAction();
                }
            }];
            // 配置字体颜色
            self.sureButtonTitleColor = self.sureButtonTitleColor?self.sureButtonTitleColor:(self.actionButtonTitleColor?self.actionButtonTitleColor:nil);
            // 设置字体颜色
            [self alertActionConfigWithAlertAction:okAction textColor:self.sureButtonTitleColor];
            [self addAction:okAction];
        }
        if (cancelTitle.length > 0) {
            UIAlertAction *canAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (cancelAction) {
                    cancelAction();
                }
            }];
            // 配置字体颜色
            self.cancelButtonTitleColor = self.cancelButtonTitleColor?self.cancelButtonTitleColor:(self.actionButtonTitleColor?self.actionButtonTitleColor:nil);
            // 设置字体颜色
            [self alertActionConfigWithAlertAction:canAction textColor:self.cancelButtonTitleColor];
            [self addAction:canAction];
        }
        [[UIViewController xm_currentViewController] presentViewController:self animated:YES completion:nil];
    });
}
// 处理修改操作按钮字体颜色
- (void)alertActionConfigWithAlertAction:(UIAlertAction *)alertAction textColor:(UIColor *)textColor{
    if(!textColor) return;
    [alertAction setValue:textColor forKey:TITLE_TEXT_COLOR];
}

#pragma mark - propeties

- (void)setActionButtonTitleColor:(UIColor *)actionButtonTitleColor{
    objc_setAssociatedObject(self, @selector(actionButtonTitleColor), actionButtonTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)actionButtonTitleColor{
    return objc_getAssociatedObject(self, @selector(actionButtonTitleColor));
}

- (void)setSureButtonTitleColor:(UIColor *)sureButtonTitleColor{
    objc_setAssociatedObject(self, @selector(sureButtonTitleColor), sureButtonTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)sureButtonTitleColor{
    return objc_getAssociatedObject(self, @selector(sureButtonTitleColor));
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor{
    objc_setAssociatedObject(self, @selector(cancelButtonTitleColor), cancelButtonTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)cancelButtonTitleColor{
    return objc_getAssociatedObject(self, @selector(cancelButtonTitleColor));
}

@end
