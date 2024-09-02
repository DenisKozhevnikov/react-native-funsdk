#pragma once
#import <FunSDK/JObject.h>

#define JK_WorkPeriod "WorkPeriod" 
class WorkPeriod : public JObject
{
public:
	JIntObj		EHour;
	JIntObj		EMinute;
	JIntObj		Enable;
	JIntObj		SHour;
	JIntObj		SMinute;

public:
    WorkPeriod(JObject *pParent = NULL, const char *szName = JK_WorkPeriod):
    JObject(pParent,szName),
	EHour(this, "EHour"),
	EMinute(this, "EMinute"),
	Enable(this, "Enable"),
	SHour(this, "SHour"),
	SMinute(this, "SMinute"){
	};

    ~WorkPeriod(void){};
};
