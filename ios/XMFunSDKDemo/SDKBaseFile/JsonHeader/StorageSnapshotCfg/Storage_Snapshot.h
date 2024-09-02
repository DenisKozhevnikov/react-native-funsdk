#pragma once
#import <FunSDK/JObject.h>

#define JK_Storage_Snapshot "Storage.Snapshot" 
class Storage_Snapshot : public JObject
{
public:
	JObjArray<JObject>		Mask;
	JIntObj		PreSnap;
	JBoolObj		Redundancy;
	JStrObj		SnapMode;
	JObjArray<JObject>		TimeSection;

public:
    Storage_Snapshot(JObject *pParent = NULL, const char *szName = JK_Storage_Snapshot):
    JObject(pParent,szName),
	Mask(this, "Mask"),
	PreSnap(this, "PreSnap"),
	Redundancy(this, "Redundancy"),
	SnapMode(this, "SnapMode"),
	TimeSection(this, "TimeSection"){
	};

    ~Storage_Snapshot(void){};
};
