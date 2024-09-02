#pragma once
#import <FunSDK/JObject.h>

#define JK_NetWork_SetEnableVideo "NetWork.SetEnableVideo" 
class NetWork_SetEnableVideo : public JObject
{
public:
	JIntObj		StrmType;
	JBoolObj		Enable;

public:
    NetWork_SetEnableVideo(JObject *pParent = NULL, const char *szName = JK_NetWork_SetEnableVideo):
    JObject(pParent,szName),
	StrmType(this, "StrmType"),
	Enable(this, "Enable"){
	};

    ~NetWork_SetEnableVideo(void){};
};
