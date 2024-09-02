#pragma once
#import <FunSDK/JObject.h>
#include "Admin.h"
#include "Force.h"
#include "General.h"
#include "Guest.h"
#include "Temporary.h"
//密码推送管理
#define JK_PassWdManger "PassWdManger" 
class PassWdManger : public JObject
{
public:
    JObjArray<Admin>        Admin;
    JObjArray<Force>        Force;
    JObjArray<General>        General;
    JObjArray<Guest>        Guest;
    JObjArray<Temporary>        Temporary;

public:
    PassWdManger(JObject *pParent = NULL, const char *szName = JK_PassWdManger):
    JObject(pParent,szName),
	Admin(this, "Admin"),
	Force(this, "Force"),
	General(this, "General"),
	Guest(this, "Guest"),
	Temporary(this, "Temporary"){
	};

    ~PassWdManger(void){};
};
