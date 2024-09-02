//
//  IPCHumanDetectionViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/7/4.
//  Copyright © 2019 zhang. All rights reserved.
//

/*****
 * 人形检测配置 IPC  简易版本的
 * 需要先获取能力级，判断是否支持人形检测  SystemFunction.AlarmFunction.PEAInHumanPed
 
 *DVR人形检测和IPC人形检测 不是同一个功能。
 DVR人形检测主要功能包括报警开关、报警录像开关、报警抓图开关、消息推送开关等等
 IPC人形检测则主要包括报警开关、设置报警拌线、设置报警区域等等。
 如果需要设置拌线和设置区域功能demo（单线警戒、区域警戒），请在demo中搜索 "完全体版本的IPC人形检测"
***/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPCHumanDetectionViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
