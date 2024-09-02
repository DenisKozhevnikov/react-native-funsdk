#pragma once
#import <FunSDK/JObject.h>
//统计消息上传状态和时间
#define JK_MessageStatistics "MessageStatistics" 
class MessageStatistics : public JObject
{
public:
	JBoolObj		Enable;
	JStrObj		Time;

public:
    MessageStatistics(JObject *pParent = NULL, const char *szName = JK_MessageStatistics):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	Time(this, "Time"){
	};

    ~MessageStatistics(void){};
};
