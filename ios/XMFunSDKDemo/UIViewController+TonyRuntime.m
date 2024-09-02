//
//  UIViewController+TonyRuntime.m
//  XWorld_General
//
//  Created by Megatron on 2019/10/10.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "UIViewController+TonyRuntime.h"
#import <objc/runtime.h>

@implementation UIViewController (TonyRuntime)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method sourceMethod = class_getInstanceMethod(objc_getClass("UIViewController"), @selector(presentViewController:animated:completion:));
        Method destMethod = class_getInstanceMethod(objc_getClass("UIViewController"), @selector(specialPresentViewController:animated:completion:));
        
        method_exchangeImplementations(sourceMethod, destMethod);
    });
}

- (void)specialPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self specialPresentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
