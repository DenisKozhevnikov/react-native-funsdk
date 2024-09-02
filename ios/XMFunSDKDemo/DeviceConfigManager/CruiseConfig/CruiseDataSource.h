//
//  CruiseDataSource.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/25.
//  Copyright © 2019 zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CruiseDataSource : NSObject

@property (nonatomic, assign) int cruiseID;   //巡航点ID
@property (nonatomic, copy) NSString *cruiseName;  //巡航点名称
@property (nonatomic, assign) int time;    //巡航点停留时间

@property (nonatomic, assign) BOOL trackEnable;   // 移动追踪是否开启
@property (nonatomic, assign) BOOL Sensitivity;   // 移动追踪灵敏度
@property (nonatomic, assign) BOOL ReturnTime;   // 移动追踪结束后 返回守望点的等待时间
@end
NS_ASSUME_NONNULL_END
