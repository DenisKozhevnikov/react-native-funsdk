#pragma once
#import "FunSDK/JObject.h"
#import "RegionPts.h"

#define JK_RuleRegion "RuleRegion" 
class RuleRegion : public JObject
{
public:
	JIntObj		AlarmDirect; //报警方向 （从内向外触发报警、从外向内报警、双向报警）
	JObjArray<RegionPts>		Pts; //点集，至少3个点才有效，不能过多
	JIntObj		PtsNum;   //点的数量

public:
    RuleRegion(JObject *pParent = NULL, const char *szName = JK_RuleRegion):
    JObject(pParent,szName),
	AlarmDirect(this, "AlarmDirect"),
	Pts(this, "Pts"),
	PtsNum(this, "PtsNum"){
	};

    ~RuleRegion(void){};
};
