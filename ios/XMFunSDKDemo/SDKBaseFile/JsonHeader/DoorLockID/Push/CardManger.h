#pragma once
#import <FunSDK/JObject.h>
#include "Admin.h"
#include "Force.h"
#include "General.h"
#include "Guest.h"
#include "Temporary.h"
//门卡推送管理
#define JK_CardManger "CardManger" 
class CardManger : public JObject
{
public:
	JObjArray<Admin>		Admin;
	JObjArray<Force>		Force;
	JObjArray<General>		General;
	JObjArray<Guest>		Guest;
	JObjArray<Temporary>		Temporary;

public:
    CardManger(JObject *pParent = NULL, const char *szName = JK_CardManger):
    JObject(pParent,szName),
	Admin(this, "Admin"),
	Force(this, "Force"),
	General(this, "General"),
	Guest(this, "Guest"),
	Temporary(this, "Temporary"){
	};

    ~CardManger(void){};
};
