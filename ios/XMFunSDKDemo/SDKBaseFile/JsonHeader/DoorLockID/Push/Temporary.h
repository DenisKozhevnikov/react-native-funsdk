#pragma once
#import <FunSDK/JObject.h>
 //临时
#define JK_Temporary "Temporary" 
class Temporary : public JObject
{
public:
	JStrObj		Serial;
	JIntObj		UserId;
	JBoolObj		MessagePushEnable;
	JStrObj		NickName;

public:
    Temporary(JObject *pParent = NULL, const char *szName = JK_Temporary):
    JObject(pParent,szName),
	Serial(this, "Serial"),
	UserId(this, "UserId"),
	MessagePushEnable(this, "MessagePushEnable"),
	NickName(this, "NickName"){
	};

    ~Temporary(void){};
};
