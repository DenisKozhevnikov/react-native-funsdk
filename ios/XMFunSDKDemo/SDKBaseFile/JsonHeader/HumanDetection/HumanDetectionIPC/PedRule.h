#pragma once
#import "FunSDK/JObject.h"
#include "RuleLine.h"
#include "RuleRegion.h"

#define JK_PedRule "PedRule" 
class PedRule : public JObject
{
public:
	JBoolObj		Enable; //规则警戒开关，关闭的话下列配置无效，默认全范围报警
	RuleLine		mRuleLine; //拌线警戒 （单线警戒，两个点确定一条线，通过拌线触发报警）
	RuleRegion		mRuleRegion; //区域警戒 （进出y区域触发报警，三个及以上的点确定一个区域，一般点数不能过多）
	JIntObj		RuleType; //警戒开启类型 ，0是拌线警戒，1是区域警戒

public:
    PedRule(JObject *pParent = NULL, const char *szName = JK_PedRule):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	mRuleLine(this, "RuleLine"),
	mRuleRegion(this, "RuleRegion"),
	RuleType(this, "RuleType"){
	};

    ~PedRule(void){};
};
