//
//  SharePermissionVC.h
//  FunSDKDemo
//
//  Created by yefei on 2022/10/20.
//  Copyright © 2022 yefei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharePermissionVC : UIViewController

@property (nonatomic, copy) NSString* devId;

@property (nonatomic, assign) BOOL isModify;

@property (nonatomic,strong) NSMutableArray *selectArray;

@property (nonatomic, copy) NSString* shareId;

@end

NS_ASSUME_NONNULL_END
