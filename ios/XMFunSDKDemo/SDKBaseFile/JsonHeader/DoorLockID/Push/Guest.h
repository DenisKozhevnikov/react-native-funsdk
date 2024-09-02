#pragma once
#import <FunSDK/JObject.h>
//宾客
#define JK_Guest "Guest" 
class Guest : public JObject
{
public:
	JStrObj		Serial;
	JIntObj		UserId;
	JBoolObj		MessagePushEnable;
	JStrObj		NickName;

public:
    Guest(JObject *pParent = NULL, const char *szName = JK_Guest):
    JObject(pParent,szName),
	Serial(this, "Serial"),
	UserId(this, "UserId"),
	MessagePushEnable(this, "MessagePushEnable"),
	NickName(this, "NickName"){
	};

    ~Guest(void){};
};
