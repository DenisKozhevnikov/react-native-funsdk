#pragma once
#import <FunSDK/JObject.h>

#define JK_Users "Users" 
class Users : public JObject
{
public:
	JObjArray <JStrObj>		AuthorityList;
	JStrObj		Group;
	JStrObj		Memo;
	JStrObj		Name;
	JObject		NoMD5;
	JStrObj		Password;
	JBoolObj		Reserved;
	JBoolObj		Sharable;

public:
    Users(JObject *pParent = NULL, const char *szName = JK_Users):
    JObject(pParent,szName),
	AuthorityList(this, "AuthorityList"),
	Group(this, "Group"),
	Memo(this, "Memo"),
	Name(this, "Name"),
	NoMD5(this, "NoMD5"),
	Password(this, "Password"),
	Reserved(this, "Reserved"),
	Sharable(this, "Sharable"){
	};

    ~Users(void){};
};
