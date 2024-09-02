#pragma once
#import <FunSDK/JObject.h>

#define JK_PirTimeSectionOne "PirTimeSectionOne" 
class PirTimeSectionOne : public JObject
{
public:
	JBoolObj		Enable;
	JStrObj		EndTime;
	JStrObj		StartTime;
	JIntObj		WeekMask;

public:
    PirTimeSectionOne(JObject *pParent = NULL, const char *szName = JK_PirTimeSectionOne):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	EndTime(this, "EndTime"),
	StartTime(this, "StartTime"),
	WeekMask(this, "WeekMask"){
	};

    ~PirTimeSectionOne(void){};
};
