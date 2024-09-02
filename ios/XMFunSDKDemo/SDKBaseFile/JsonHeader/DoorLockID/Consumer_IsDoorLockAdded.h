#pragma once
#import <FunSDK/JObject.h>
 //远程开锁的门锁ID
#define JK_Consumer_IsDoorLockAdded "Consumer.IsDoorLockAdded" 
class Consumer_IsDoorLockAdded : public JObject
{
public:
	JBoolObj		Add;
	JObjArray<JStrObj>		DoorLockID;

public:
    Consumer_IsDoorLockAdded(JObject *pParent = NULL, const char *szName = JK_Consumer_IsDoorLockAdded):
    JObject(pParent,szName),
	Add(this, "Add"),
	DoorLockID(this, "DoorLockID"){
	};

    ~Consumer_IsDoorLockAdded(void){};
};
