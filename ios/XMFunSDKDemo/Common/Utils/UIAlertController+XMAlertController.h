//
//  UIAlertController+XMAlertController.h
//  XMUIKit
//
//  Created by coderXY on 2022/9/28.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (XMAlertController)
/** action button title color */
@property (nonatomic, strong) UIColor *actionButtonTitleColor;
/** sure button title color */
@property (nonatomic, strong) UIColor *sureButtonTitleColor;
/** cancel button title color */
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;
#pragma mark - 可自定义操作按钮字体颜色
/** 可自定义 actionTitle 字体颜色 【使用此方法且需改变字体颜色时，可设置actionButtonTitleColor或sureButtonTitleColor】
 @param actionTitle actionTitle 【必传】
 @param action action
 */
- (void)xm_showAlertWithActionTitle:(NSString *)actionTitle action:(void (^)(void))action;
/** 可自定义 sureTitle、cancelTitle字体颜色，且两参数不可同时为nil，否则无响应
 @param sureTitle sureTitle
 @param cancelTitle cancelTitle 【必传】
 @param sureAction sureAction   【必传】
 @param cancelAction cancelAction
 */
- (void)xm_showAlertWithSureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction;

#pragma mark - 无title alert 操作框
/** 高度自定义alter
 @param message message
 @param actionTitle actionTitle 【必传】，否则无响应
 @param action action
 */
+ (void)xm_showAlertWithMessage:(NSString *)message actionTitle:(NSString *)actionTitle action:(void (^)(void))action;
/** alert single operation action [sure]
 @param message message
 @param sureTitle sureTitle 若为nil，默认为 中文 确定
 @param sureAction sureAction
 */
+ (void)xm_showAlertWithMessage:(NSString *)message sureTitle:(NSString *)sureTitle sureAction:(void(^)(void))sureAction;
/** alert single operation action [cancel]
 @param message message
 @param cancelTitle cancelTitle 若为nil，默认为 中文 取消
 @param cancelAction cancelAction
 */
+ (void)xm_showAlertWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelAction:(void(^)(void))cancelAction;
/** alert
 @param message message
 @param sureTitle sureTitle 若为nil，默认为 中文 确定
 @param cancelTitle cancelTitle 若为nil，默认为 中文 取消
 @param sureAction sureAction
 @param cancelAction cancelAction
 */
+ (void)xm_showAlertWithMessage:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction;
#pragma mark - 有title alert 操作框
/** 自定义文本 无默认值
 @param title title
 @param message message
 @param actionTitle actionTitle 【必传】
 @param action action
 */
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle action:(void (^)(void))action;
/** alert
 @param title title 若为nil，默认为 中文 温馨提示
 @param message message
 @param sureTitle sureTitle 若为nil，默认为 中文 确定
 @param sureAction sureAction
 */
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle sureAction:(void(^)(void))sureAction;
/** alert
 @param title title 若为nil，默认为 中文 温馨提示
 @param message message
 @param cancelTitle cancelTitle 若为nil，默认为 中文 取消
 @param cancelAction cancelAction
 */
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelAction:(void(^)(void))cancelAction;
/** alert
 @param title title 若为nil，默认为 中文 温馨提示
 @param message message
 @param sureTitle sureTitle 若为nil，默认为 中文 确定
 @param cancelTitle cancelTitle 若为nil，默认为 中文 取消
 @param sureAction sureAction
 @param cancelAction cancelAction
 */
+ (void)xm_showAlertWithTitle:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sureAction:(void(^)(void))sureAction cancelAction:(void(^)(void))cancelAction;

@end

//NS_ASSUME_NONNULL_END
