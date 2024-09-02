#pragma once
#import <FunSDK/JObject.h>
//免打扰管理
#define JK_Consumer_NoDisturbing "Consumer.NoDisturbing" 
class Consumer_NoDisturbing : public JObject
{
public:
	JBoolObj		DeepSleepDnd; //深度休眠开关
	JBoolObj		EnableDnd; //免打扰总开关
	JStrObj		EndTime; //功能结束时间
	JBoolObj		MessageDnd; //是否开启消息推送
	JBoolObj		NotifyLightDnd; //是否开启呼吸灯
	JBoolObj		RingDownDnd; //是否开启提示音
	JStrObj		StartTime; //功能开始时间

public:
    Consumer_NoDisturbing(JObject *pParent = NULL, const char *szName = JK_Consumer_NoDisturbing):
    JObject(pParent,szName),
	DeepSleepDnd(this, "DeepSleepDnd"),
	EnableDnd(this, "EnableDnd"),
	EndTime(this, "EndTime"),
	MessageDnd(this, "MessageDnd"),
	NotifyLightDnd(this, "NotifyLightDnd"),
	RingDownDnd(this, "RingDownDnd"),
	StartTime(this, "StartTime"){
	};

    ~Consumer_NoDisturbing(void){};
};
