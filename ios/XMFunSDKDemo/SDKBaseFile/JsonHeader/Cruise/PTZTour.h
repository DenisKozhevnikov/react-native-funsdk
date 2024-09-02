#pragma once
#import <FunSDK/JObject.h>
#import "Tour.h"
//移动追踪
#define JK_PTZTour "Uart.PTZTour"
class PTZTour : public JObject
{
public:
	JIntObj		Id;
	JStrObj		Name;
	JObjArray<Tour>		Tour;

public:
    PTZTour(JObject *pParent = NULL, const char *szName = JK_PTZTour):
    JObject(pParent,szName),
	Id(this, "Id"),
	Name(this, "Name"),
	Tour(this, "Tour"){
	};

    ~PTZTour(void){};
};
