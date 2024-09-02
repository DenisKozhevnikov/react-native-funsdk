//
//  JFBluetoothSearchResultCell.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFBluetoothSearchResultCell : UITableViewCell
/** 刷新cell */
- (void)jf_updateCellWithDevname:(NSString *)devName;

@end

NS_ASSUME_NONNULL_END
