#pragma once
#import "FunSDK/JObject.h"
#import "PedRule.h"

#define JK_Detect_HumanDetection "Detect.HumanDetection" 
#define JK_Detect_HumanDetection0 "Detect.HumanDetection.[0]"
class Detect_HumanDetection : public JObject
{
public:
	JBoolObj		Enable; //报警总开关，这个开关需要开启之后，下面一系列配置才有效
	JIntObj		ObjectType;
	JIntObj		PedFdrAlg;
	JObjArray<PedRule>		PedRule; //报警规则
	JIntObj		Sensitivity;
	JIntObj		ShowRule; //是否显示规则
	JIntObj		ShowTrack; //是否显示踪迹

public:
    Detect_HumanDetection(JObject *pParent = NULL, const char *szName = JK_Detect_HumanDetection):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	ObjectType(this, "ObjectType"),
	PedFdrAlg(this, "PedFdrAlg"),
	PedRule(this, "PedRule"),
	Sensitivity(this, "Sensitivity"),
	ShowRule(this, "ShowRule"),
	ShowTrack(this, "ShowTrack"){
	};

    ~Detect_HumanDetection(void){};
};
