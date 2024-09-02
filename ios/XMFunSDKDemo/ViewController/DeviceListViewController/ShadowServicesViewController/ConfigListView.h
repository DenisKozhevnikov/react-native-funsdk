//
//  ConfigListView.h
//  FunSDKDemo
//
//  Created by plf on 2023/4/27.
//  Copyright © 2023 plf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigListView : UIView

@property (nonatomic, copy) void (^addConfigBlock)(NSString *configStr);

-(void)showSelectView;
-(void)dismissView;

@end

NS_ASSUME_NONNULL_END
