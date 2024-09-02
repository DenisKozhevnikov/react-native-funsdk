#pragma once
#import <FunSDK/JObject.h>

#define JK_MoveTrigLight "MoveTrigLight" 
class MoveTrigLight : public JObject
{
public:
	JIntObj		Duration;
	JIntObj		Level;

public:
    MoveTrigLight(JObject *pParent = NULL, const char *szName = JK_MoveTrigLight):
    JObject(pParent,szName),
	Duration(this, "Duration"),
	Level(this, "Level"){
	};

    ~MoveTrigLight(void){};
};
