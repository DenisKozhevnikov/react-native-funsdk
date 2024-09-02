//
//  SuperView.h
//  XMEye
//
//  Created by XM on 2017/4/24.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawControl.h"
@protocol SuperViewSelectPointDelegate <NSObject>
@optional
//选择点完成之后的代理
-(void)SuperViewSelectPointArray:(NSMutableArray*)array;
- (void)superViewUserChangedPoint;

@end
@interface SuperView : UIView
{
}
@property (nonatomic, strong) DrawControl *control;
@property (nonatomic, assign) id <SuperViewSelectPointDelegate> delegate;
@property (nonatomic,assign) DefaultPoint_Type lastType;

//设置是大的智能分析类型，周界警戒，单线，盗移，滞留
-(void)setDrawType:(int)type;
//设置场景，包括应用场景和自定义场景
-(void)setSelectSceneType:(DefaultPoint_Type)sceneType;

//撤销，回到上一步
-(void)toTheBeforeStep;
//和android同步撤销
-(void)removeAllStep;
//撤回上一步
-(void)rollBackLastStep;
@end
