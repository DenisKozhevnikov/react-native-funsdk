//
//  SensorConfig.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/4/10.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 传感器操作
 
 Function: add sensor to camera ,show sensor status and more.
 
 How can i receive alarm push form sensor?
 First :To control App Notifications received or not ,only need to execute function “ MC_LinkDev” (means Open after this you can receive message form service), or function “ MC_UnlinkDev” (this means opposite before). This two functions you can search in demo.
 Second: Control sensor push message to camera, after you add a sensor you need to change sensor config key “ Status”   ( this value means alarm message will send to camera or not.Only keep it open (Status = 1) ,your camera can get push message.)
 If you finish all above,when gas sensor trigger a alarm message,it will send to your camera,and the camera will send this info to our service.Because you had execute "MC_LinkDev”,the service knows you want receive this device push message,it will send to AppService and than your phone revice the alarm message and show on screen.
 */

NS_ASSUME_NONNULL_BEGIN

@interface SensorConfig : NSObject

@property (nonatomic,assign) int msgHandle;

#pragma mark - get sensor list
- (void)getSensorList;

#pragma mark - begin adding sensor
- (void)beginAddSensor;

#pragma mark - stop adding sensor
- (void)stopAddSensor;

#pragma mark - delete added sensor
- (void)beginDeleteSensor:(NSString *)devID;

#pragma mark - change sensor name in list
- (void)changeSensorName:(NSString *)name sensorID:(NSString *)devID;

#pragma mark - control sensor push status
- (void)beginChangeStatueOpen:(BOOL)ifOpen devID:(NSString *)devID;

#pragma mark - get camera scene mode
- (void)beginGetSceneMode;

#pragma mark - change camera scene mode
- (void)beginChangeMode:(NSString *)modeID;

#pragma mark - get sensor online status
- (void)requestSensorState:(NSString *)sensorID;

#pragma mark - get detail status
- (void)requestSensorDetailStatus:(NSString *)sensorID;

@end

NS_ASSUME_NONNULL_END
