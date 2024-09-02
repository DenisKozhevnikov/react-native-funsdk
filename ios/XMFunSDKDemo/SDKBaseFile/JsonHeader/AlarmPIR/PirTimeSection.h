#pragma once
#import <FunSDK/JObject.h>
#include "PirTimeSectionOne.h"
#include "PirTimeSectionTwo.h"

#define JK_PirTimeSection "PirTimeSection" 
class PirTimeSection : public JObject
{
public:
	PirTimeSectionOne		mPirTimeSectionOne;
	PirTimeSectionTwo		mPirTimeSectionTwo;

public:
    PirTimeSection(JObject *pParent = NULL, const char *szName = JK_PirTimeSection):
    JObject(pParent,szName),
	mPirTimeSectionOne(this, "PirTimeSectionOne"),
	mPirTimeSectionTwo(this, "PirTimeSectionTwo"){
	};

    ~PirTimeSection(void){};
};
