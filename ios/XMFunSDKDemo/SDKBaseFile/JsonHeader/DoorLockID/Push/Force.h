#pragma once
#import <FunSDK/JObject.h>
//强拆
#define JK_Force "Force" 
class Force : public JObject
{
public:
	JStrObj		Serial;
	JIntObj		UserId;
	JBoolObj		MessagePushEnable;
	JStrObj		NickName;

public:
    Force(JObject *pParent = NULL, const char *szName = JK_Force):
    JObject(pParent,szName),
	Serial(this, "Serial"),
	UserId(this, "UserId"),
	MessagePushEnable(this, "MessagePushEnable"),
	NickName(this, "NickName"){
	};

    ~Force(void){};
};
