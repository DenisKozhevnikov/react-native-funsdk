#pragma once
#import <FunSDK/JObject.h>

#define JK_PirTimeSectionTwo "PirTimeSectionTwo" 
class PirTimeSectionTwo : public JObject
{
public:
	JBoolObj		Enable;
	JStrObj		EndTime;
	JStrObj		StartTime;
	JIntObj		WeekMask;

public:
    PirTimeSectionTwo(JObject *pParent = NULL, const char *szName = JK_PirTimeSectionTwo):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	EndTime(this, "EndTime"),
	StartTime(this, "StartTime"),
	WeekMask(this, "WeekMask"){
	};

    ~PirTimeSectionTwo(void){};
};
