#pragma once
#import <FunSDK/JObject.h>

#define JK_WorkMode_CapturePriority "WorkMode.CapturePriority"
class WorkMode_CapturePriority : public JObject
{
public:
	JIntObj		Type;

public:
    WorkMode_CapturePriority(JObject *pParent = NULL, const char *szName = JK_WorkMode_CapturePriority):
    JObject(pParent,szName),
	Type(this, "Type"){
	};
    ~WorkMode_CapturePriority(void){};
};
