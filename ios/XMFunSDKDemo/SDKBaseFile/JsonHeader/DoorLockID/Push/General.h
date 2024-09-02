#pragma once
#import <FunSDK/JObject.h>
//普通
#define JK_General "General" 
class General : public JObject
{
public:
	JStrObj		Serial;
	JIntObj		UserId;
	JBoolObj		MessagePushEnable;
	JStrObj		NickName;

public:
    General(JObject *pParent = NULL, const char *szName = JK_General):
    JObject(pParent,szName),
	Serial(this, "Serial"),
	UserId(this, "UserId"),
	MessagePushEnable(this, "MessagePushEnable"),
	NickName(this, "NickName"){
	};

    ~General(void){};
};
