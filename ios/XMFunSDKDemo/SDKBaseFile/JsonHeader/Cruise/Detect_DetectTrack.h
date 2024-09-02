#pragma once
#import <FunSDK/JObject.h>
//移动追踪
#define JK_Detect_DetectTrack "Detect.DetectTrack" 
class Detect_DetectTrack : public JObject
{
public:
	JIntObj		Enable;             // 移动追踪是否开启
	JIntObj		Sensitivity;        // 移动追踪灵敏度
    JIntObj     ReturnTime;         // 移动追踪结束后 返回守望点的等待时间

public:
    Detect_DetectTrack(JObject *pParent = NULL, const char *szName = JK_Detect_DetectTrack):
    JObject(pParent,szName),
	Enable(this, "Enable"),
	Sensitivity(this, "Sensitivity"),
    ReturnTime(this,"ReturnTime"){
	};

    ~Detect_DetectTrack(void){};
};
