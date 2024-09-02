#pragma once
#import <FunSDK/JObject.h>
#include "Admin.h"
#include "Force.h"
#include "General.h"
#include "Guest.h"
#include "Temporary.h"
//指纹推送管理
#define JK_FingerManger "FingerManger" 
class FingerManger : public JObject
{
public:
    JObjArray<Admin>        Admin;
    JObjArray<Force>        Force;
    JObjArray<General>        General;
    JObjArray<Guest>        Guest;
    JObjArray<Temporary>        Temporary;

public:
    FingerManger(JObject *pParent = NULL, const char *szName = JK_FingerManger):
    JObject(pParent,szName),
	Admin(this, "Admin"),
	Force(this, "Force"),
	General(this, "General"),
	Guest(this, "Guest"),
	Temporary(this, "Temporary"){
	};

    ~FingerManger(void){};
};
