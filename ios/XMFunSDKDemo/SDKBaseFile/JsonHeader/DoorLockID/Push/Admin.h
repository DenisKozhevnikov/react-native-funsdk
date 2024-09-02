#pragma once
#import <FunSDK/JObject.h>
//管理员
#define JK_Admin "Admin" 
class Admin : public JObject
{
public:
	JStrObj		Serial;
	JIntObj		UserId;
	JBoolObj		MessagePushEnable;
	JStrObj		NickName;

public:
    Admin(JObject *pParent = NULL, const char *szName = JK_Admin):
    JObject(pParent,szName),
	Serial(this, "Serial"),
	UserId(this, "UserId"),
	MessagePushEnable(this, "MessagePushEnable"),
	NickName(this, "NickName"){
	};

    ~Admin(void){};
};
