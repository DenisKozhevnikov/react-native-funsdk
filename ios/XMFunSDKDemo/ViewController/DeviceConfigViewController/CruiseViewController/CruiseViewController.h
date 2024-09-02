//
//  CruiseViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/25.
//  Copyright © 2019 zhang. All rights reserved.
//

/************
 1、根据能力级判断是否支持巡航
 2、根据能力级判断是否同时支持移动追踪和守望，如果支持，显示移动追踪和守望点功能
 3、获取巡航点，并且刷新界面显示 （巡航点数组，对象参数包括ID，名称、巡航点停留时间）
 4、增删巡航点（修改巡航点需要先删除再增加）
 5、跳转到某一个巡航点
 6、开始巡航，设置巡航次数
 7、添加守望点
 8、设置移动追踪参数 （开关、灵敏度、守望时间）
 
 说明；这个界面没有做鱼眼全景视频播放适配，鱼眼全景设备在这里会显示黑屏
 **********/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CruiseViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
