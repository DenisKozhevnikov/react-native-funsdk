#pragma once
#import <FunSDK/JObject.h>

#define JK_FbExtraStateCtrl "FbExtraStateCtrl" 
class FbExtraStateCtrl : public JObject
{
public:
	JIntObj		ison;
    JIntObj     PlayVoiceTip;

public:
    FbExtraStateCtrl(JObject *pParent = NULL, const char *szName = JK_FbExtraStateCtrl):
    JObject(pParent,szName),
    PlayVoiceTip(this, "PlayVoiceTip"),
	ison(this, "ison"){
	};

    ~FbExtraStateCtrl(void){};
};
