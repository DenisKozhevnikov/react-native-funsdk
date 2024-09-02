//
//  AlarmMessageConfig.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/1.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

/****
 *
 *设备报警消息查询配置
 *获取报警消息
 *根据消息id和图片名称获取缩略图
 *根据消息id和图片名称获取报警原图
 *
 ***/
#import <Foundation/Foundation.h>
#import "FunMsgListener.h"
NS_ASSUME_NONNULL_BEGIN

@protocol AlarmMessageConfigDelegate <NSObject>

//获取报警消息回调
-(void)getAlarmMessageConfigResult:(NSInteger)result message:(NSMutableArray *)array;
//搜索报警消息图片回调
-(void)searchAlarmPicConfigResult:(NSInteger)result imagePath:(NSString *)imagePath;
//删除报警消息回调
-(void)deleteAlarmMessageConfigResult:(NSInteger)result message:(NSMutableArray *)array;
@end

@interface AlarmMessageConfig : FunMsgListener

@property (nonatomic,strong) NSMutableArray *fileList;           // 报警消息列表
@property (nonatomic,strong) NSMutableArray *deleteAlarmID;      // 报警消息批量删除的ID
@property (nonatomic, assign) id <AlarmMessageConfigDelegate> delegate;
#pragma mark - 查找报警缩略图
- (void)searchAlarmThumbnail:(NSString *)uId fileName:(NSString *)fileName;
#pragma mark - 下载报警缩略图
- (void)downloadAlarmThumbnail:(NSString *)path info:(NSString *)picInfo;
#pragma mark - 查找报警图
- (void)searchAlarmPic:(NSString *)uId fileName:(NSString *)fileName;
#pragma mark - 查询报警消息
-(void)searchAlarmInfo;
//MARK: 下载图片
- (void)downloadImage:(NSString *)path info:(NSString *)picInfo; // 图片完整路径
#pragma mark - 删除报警消息
- (void)deleteAlarmMessage:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
