//
//  JFBluetoothSearchResultAlertView.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/** 代理 */
@protocol JFBluetoothSearchResultAlertViewDelegate <NSObject>

@optional
/** 选择数据 */
- (void)jf_didSelectedDevModel:(id)devModel;

@end

@interface JFBluetoothSearchResultAlertView : UIView
/** 设备列表 */
@property (nonatomic, strong, readonly) UITableView *devTabList;
/** 设备数据源 */
@property (nonatomic, strong, readonly) NSMutableArray *dataSource;
/** JFBluetoothSearchResultAlertViewDelegate */
@property (nonatomic, weak, readonly) id<JFBluetoothSearchResultAlertViewDelegate>delegate;
/** showView */
+ (void)jf_showResultViewWithDataSource:(NSMutableArray *)dataSource delegate:(id<JFBluetoothSearchResultAlertViewDelegate>)delegate;
/** dismiss */
+ (void)dismissAction;

@end

NS_ASSUME_NONNULL_END
