#pragma once
#import <FunSDK/JObject.h>
#include "WorkPeriod.h"
#include "MoveTrigLight.h"
//灯泡配置
#define JK_Camera_WhiteLight "Camera.WhiteLight" 
class Camera_WhiteLight : public JObject
{
public:
    JIntObj        Brightness;
    MoveTrigLight        mMoveTrigLight;
	JStrObj		WorkMode;
	WorkPeriod		mWorkPeriod;

public:
    Camera_WhiteLight(JObject *pParent = NULL, const char *szName = JK_Camera_WhiteLight):
    JObject(pParent,szName),
    mMoveTrigLight(this, "MoveTrigLight"),
	WorkMode(this, "WorkMode"),
    Brightness(this, "Brightness"),
	mWorkPeriod(this, "WorkPeriod"){
	};

    ~Camera_WhiteLight(void){};
};
