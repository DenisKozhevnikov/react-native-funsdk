#pragma once
#import "FunSDK/JObject.h"

#define JK_Pts "Pts" 
class Pts : public JObject
{
public:
	JIntObj		StartX;
	JIntObj		StartY;
	JIntObj		StopX;
	JIntObj		StopY;

public:
    Pts(JObject *pParent = NULL, const char *szName = JK_Pts):
    JObject(pParent,szName),
	StartX(this, "StartX"),
	StartY(this, "StartY"),
	StopX(this, "StopX"),
	StopY(this, "StopY"){
	};

    ~Pts(void){};
};
