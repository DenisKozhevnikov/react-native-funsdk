#pragma once
#import <FunSDK/JObject.h>

#define JK_Tour "Tour" 
class Tour : public JObject
{
public:
	JIntObj		Id; //巡航点ID
	JStrObj		Name; //巡航点名称
	JIntObj		Time; //每个巡航点停留时间

public:
    Tour(JObject *pParent = NULL, const char *szName = JK_Tour):
    JObject(pParent,szName),
	Id(this, "Id"),
	Name(this, "Name"),
	Time(this, "Time"){
	};

    ~Tour(void){};
};
