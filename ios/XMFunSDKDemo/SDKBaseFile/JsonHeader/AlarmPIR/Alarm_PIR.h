#pragma once
#import <FunSDK/JObject.h>
#include "EventHandler.h"

#define JK_Alarm_PIR "Alarm.PIR" 
class Alarm_PIR : public JObject
{
public:
	JBoolObj		Enable;
	EventHandler		mEventHandler;
	JIntObj		Level;
    JIntObj     PIRCheckTime;
    JIntObj     PirSensitive;
public:
    Alarm_PIR(JObject *pParent = NULL, const char *szName = JK_Alarm_PIR):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	mEventHandler(this, "EventHandler"),
	Level(this, "Level"),
    PIRCheckTime(this, "PIRCheckTime"),
    PirSensitive(this, "PirSensitive"){
	};

    ~Alarm_PIR(void){};
};
