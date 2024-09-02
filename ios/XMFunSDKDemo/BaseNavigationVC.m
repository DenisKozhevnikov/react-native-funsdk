//
//  BaseNavigationVC.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/7/19.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "BaseNavigationVC.h"
#import "PlayViewController.h"

@interface BaseNavigationVC ()

@end

@implementation BaseNavigationVC

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
