#pragma once
#import <FunSDK/JObject.h>
#include "EventHandler.h"
#include "MessageStatistics.h"
//门锁状态
#define JK_Consumer_DoorLock "Consumer.DoorLock" 
class Consumer_DoorLock : public JObject
{
public:
	JIntObj		DevType;
	JStrObj		DoorLockID;
	JStrObj		DoorLockName;
	JBoolObj		Enable;
	EventHandler		mEventHandler;
	JObject		LockStatus;
	MessageStatistics		mMessageStatistics;
	JObject		TempPasswd;
	JObject		UnLock;

public:
    Consumer_DoorLock(JObject *pParent = NULL, const char *szName = JK_Consumer_DoorLock):
    JObject(pParent,szName),
	DevType(this, "DevType"),
	DoorLockID(this, "DoorLockID"),
	DoorLockName(this, "DoorLockName"),
	Enable(this, "Enable"),
	mEventHandler(this, "EventHandler"),
	LockStatus(this, "LockStatus"),
	mMessageStatistics(this, "MessageStatistics"),
	TempPasswd(this, "TempPasswd"),
	UnLock(this, "UnLock"){
	};

    ~Consumer_DoorLock(void){};
};
