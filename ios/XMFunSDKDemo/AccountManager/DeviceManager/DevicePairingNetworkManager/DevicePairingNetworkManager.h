//
//  DevicePairingNetworkManager.h
//   iCSee
//
//  Created by Tony Stark on 2023/2/9.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetCloudCryNumCallBack)(int result,NSString * _Nullable crynum);

NS_ASSUME_NONNULL_BEGIN

/*
 设备配网管理者
 */
@interface DevicePairingNetworkManager : NSObject

@property (nonatomic,copy) GetCloudCryNumCallBack getCloudCryNumCallBack;

/**
 * @brief 查询设备特征校验码(CloudCryNum)
 *  设备配网之后，App连接设备，通过netip协议(消息ID是1020，Name是GetCloudCryNum)，可以获取到CloudCryNum（Wifi配网和蓝牙配网，才去获取CloudCryNum，添加设备的时候，还是通知服务器要清空之前的老账号下的设备，RS系统判断：如果是Token方式的设备，原来是只允许一个账号添加的，现在又要去清空历史账号的情况下，那么这个时候要判断 CloudCryNum 是否和从CAPS获取的一致，如果一致，才允许清除，如果不一致，还是和原来逻辑一样，提示“当前设备已经被他人占用”。）；
 * @param devID 设备ID
 * @param completion GetCloudCryNumCallBack
 * @return void
 */
- (void)requestCloudCryNum:(NSString *)devID completed:(GetCloudCryNumCallBack)completion;

@end

NS_ASSUME_NONNULL_END
