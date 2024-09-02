#pragma once
#import <FunSDK/JObject.h>
#include "CardManger.h"
#include "FingerManger.h"
#include "PassWdManger.h"
//门锁推送管理
#define JK_Consumer_DoorLockAuthManage "Consumer.DoorLockAuthManage" 
class Consumer_DoorLockAuthManage : public JObject
{
public:
	CardManger		mCardManger;
	JStrObj		DoorLockID;
	FingerManger		mFingerManger;
	PassWdManger		mPassWdManger;

public:
    Consumer_DoorLockAuthManage(JObject *pParent = NULL, const char *szName = JK_Consumer_DoorLockAuthManage):
    JObject(pParent,szName),
	mCardManger(this, "CardManger"),
	DoorLockID(this, "DoorLockID"),
	mFingerManger(this, "FingerManger"),
	mPassWdManger(this, "PassWdManger"){
	};

    ~Consumer_DoorLockAuthManage(void){};
};
