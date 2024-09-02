//
//  UIView+Layout.h
//
//  Created by XM on 18/2/24.
//  Copyright © 2018年 XM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceLoginTipsManager.h"

typedef enum : NSUInteger {
    TZOscillatoryAnimationToBigger,
    TZOscillatoryAnimationToSmaller,
} TZOscillatoryAnimationType;


@protocol XMUIAlertVCDelegate <NSObject>

@optional
- (void)xmAlertVCClickIndex:(int)index tag:(int)tag content:(NSString *)content msg:(NSString *)msg name:(NSString *)name;

@end

@interface UIView (Layout)

@property (nonatomic) CGFloat tz_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat tz_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat tz_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat tz_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat tz_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat tz_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat tz_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat tz_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint tz_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  tz_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(TZOscillatoryAnimationType)type;

// 通用的错误密码输入框
+ (UIAlertView *) allocPwdInputAlert:(NSString *)msg delegate:(nullable id)delegate;

+(void)showUserOrPasswordErrorTips:(int)type delegate:(id)delegate presentedVC:(UIViewController *)vc tag:(int)tag devID:(NSString *)devID changePwd:(BOOL)changePwd ;

//获取当前显示的vc
+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC;
@end
