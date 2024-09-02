#pragma once
#import "FunSDK/JObject.h"
#include "Pts.h"

#define JK_RuleLine "RuleLine" 
class RuleLine : public JObject
{
public:
	JIntObj		AlarmDirect; //报警方向，从左向右触发报警，从右向左，双向
	Pts		mPts; //点集

public:
    RuleLine(JObject *pParent = NULL, const char *szName = JK_RuleLine):
    JObject(pParent,szName),
	AlarmDirect(this, "AlarmDirect"),
	mPts(this, "Pts"){
	};

    ~RuleLine(void){};
};
