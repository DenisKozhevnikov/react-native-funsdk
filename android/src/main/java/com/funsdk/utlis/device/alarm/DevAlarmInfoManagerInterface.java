package com.funsdk.utils.device.alarm;

import com.lib.sdk.bean.alarm.AlarmInfo;

import java.util.Calendar;
import java.util.Date;

/**
 * @author hws
 * @name M-Cam_Android
 * @class name：com.manager.device.alarm
 * @class describe
 * @time 2019-02-13 9:53
 */
public interface DevAlarmInfoManagerInterface {
    /**
     * 查询所有报警消息
     *
     * @param devId 设备序列号
     * @param chnId 设备通道号
     */
    void searchAlarmInfoAll(String devId, int chnId);

    /**
     * 查询报警消息
     *
     * @param devId                 设备序列号
     * @param chnId                 通道Id
     * @param alarmType             报警类型
     * @param searchTime            查询开始时间
     * @param searchDays            查询的天数
     * @param isSupportCloudStorage 是否支持云存储
     */
    void searchAlarmInfo(String devId, int chnId, int alarmType, Date searchTime, int searchDays,
            boolean isSupportCloudStorage);

    /**
     * 查询报警消息
     *
     * @param devId       设备序列号
     * @param chnId       通道Id
     * @param alarmType   报警类型
     * @param searchTime  查询开始时间
     * @param searchDays  查询的天数
     * @param thumbWidth  缩略图-宽 原图默认传0
     * @param thumbHeight 缩略图-高 原图默认传0
     */
    void searchAlarmInfo(String devId, int chnId, int alarmType, Date searchTime, int searchDays, int thumbWidth,
            int thumbHeight);

    /**
     * 删除报警消息
     *
     * @param devId      设备序列号
     * @param deleteType MSG：删除图片和消息 VIDEO：删除视频
     * @param alarmInfos 报警信息
     */
    void deleteAlarmInfo(String devId, String deleteType, AlarmInfo... alarmInfos);

    /**
     * 删除是所有报警消息
     *
     * @param devId      设备序列号
     * @param deleteType MSG：删除图片和消息 VIDEO：删除视频
     */
    void deleteAllAlarmInfos(String devId, String deleteType);
}
