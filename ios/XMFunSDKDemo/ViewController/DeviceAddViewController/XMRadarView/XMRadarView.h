//
//  XMRadarView.h
//  HoMeYe
//
//  Created by coderXY on 2023/3/11.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMRadarView : UIView
/** 当前雷达图片 */
@property (nonatomic, copy) NSString *radarImgName;
/** 开始动画 */
- (void)beginAnimation;
/** 结束动画 */
- (void)endAnimation;

@end

