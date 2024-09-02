#pragma once
#import "FunSDK/JObject.h"

#define JK_RegionPts "Pts"
class RegionPts : public JObject
{
public:
	JIntObj		X;
	JIntObj		Y;

public:
    RegionPts(JObject *pParent = NULL, const char *szName = JK_RegionPts):
    JObject(pParent,szName),
	X(this, "X"),
	Y(this, "Y"){
	};

    ~RegionPts(void){};
};
