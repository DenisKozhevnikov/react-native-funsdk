//
//  PlayView.h
//  XMEye
//
//  Created by XM on 2018/7/21.
//  Copyright © 2018年 Megatron. All rights reserved.
//

/******
 *
 *播放窗口界面view
 *如果想要自定义这个类，那么必须要有 +(Class)layerClass 方法 （SDK初始化画布时需要用到这个方法）
 *
 */

#import <UIKit/UIKit.h>

@protocol PlayViewDelegate <NSObject>
@optional
-(void)PlayViewSelected:(int)tag;
@end


@interface PlayView : UIView

@property (nonatomic,strong) UIActivityIndicatorView *activityView;  // 加载状态图标

@property (nonatomic) UIImageView *wifiStatus;//信号强度

@property (nonatomic,weak) id <PlayViewDelegate> playViewDelegate;


- (id)initWithFrame:(CGRect)frame;
#pragma mark  刷新界面图标
- (void)refreshView:(int)index;
- (void)playViewBufferIng; //正在缓冲
- (void)playViewBufferEnd;//缓冲完成
- (void)playViewBufferStop;//预览失败

- (void)setFrameColor:(BOOL)select;//设置选中状态
@end
