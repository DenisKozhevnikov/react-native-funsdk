#pragma once
#import <FunSDK/JObject.h>
#include "EventHandler.h"
#include "MessageStatistics.h"
//临时密码
#define JK_GetAllDevList "GetAllDevList" 
class GetAllDevList : public JObject
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
    GetAllDevList(JObject *pParent = NULL, const char *szName = JK_GetAllDevList):
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

    ~GetAllDevList(void){};
};
