/*********************************************************************************
*Author:	xu bai
*Description:
*History:
Date:	2020.10.13/xu bai
Action：Create
**********************************************************************************/
#ifndef _FUN_BC_H
#define _FUN_BC_H
#include "XTypes.h"

/*******************轻量化云平台相关的接口**************************
* 方法名: 获取设备列表
* 描  述: 轻量化监控平台设备列表获取
* 返回值:
*      >=成功，< 0错误值，详见错误码
* 参  数:
*      输入(in)
*          [sRequestJson:请求json格式信息]
*      输出(out)
*          [无]
* 结果消息：
* 		消息id:EMSG_SYS_VMS_CLOUD_GET_DEV_LIST = 5086
* 		arg1: >=0 成功 代表设备个数  < 0错误值，详见错误码
* 		pData： 结构体信息
* 		str： 服务器返回的整个json结果， 上层应该需要用到，显示列表层级;
****************************************************/
int BC_SysVmsCloudGetDevList(UI_HANDLE hUser, const char *sRequestJson, int nSeq = 0);

#endif // _FUN_BC_H