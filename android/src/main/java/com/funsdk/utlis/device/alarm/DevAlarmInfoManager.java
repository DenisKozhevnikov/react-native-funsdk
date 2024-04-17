package com.funsdk.utils.device.alarm;

import android.content.Context;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.basic.G;
import com.google.gson.Gson;
import com.lib.EFUN_ERROR;
import com.lib.EUIMSG;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.Mps.MpsClient;
import com.lib.Mps.XPMS_SEARCH_ALARMINFO_REQ;
import com.lib.MsgContent;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.bean.alarm.AlarmGroup;
import com.lib.sdk.bean.alarm.AlarmInfo;
import com.lib.sdk.bean.alarm.AlarmPicVideoInfo;
import com.lib.sdk.bean.alarm.SearchAlarmInfo;
import com.manager.base.BaseManager;
import com.utils.XUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.LinkedBlockingDeque;

import static com.lib.EFUN_ERROR.EE_NOT_FOUND_ALARM_INFO;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * @author hws
 * @name M-Cam_Android
 * @class name：com.manager.device.alarm
 * @class 报警消息查询
 * @time 2019-02-13 9:49
 */
public class DevAlarmInfoManager extends BaseManager
        implements IFunSDKResult, DevAlarmInfoManagerInterface {
    /**
     * 默认查询天数
     */
    private static final int SEARCH_DAYS = 7;
    /**
     * 一次删除命令最多删除的消息数量
     */
    private static final int DELETE_SEND_DATA_MAX_COUNT = 60;
    /**
     * 查询的最小数量
     */
    private static final int SEARCH_MIN_COUNT = 20;
    private Context context;
    private int userId;
    private OnAlarmInfoListener onAlarmInfoListener;
    private boolean isSupportCloudStorage;
    private List<AlarmGroup> alarmGroupList;
    private List<AlarmInfo> tempDeleteAlarmInfos;
    /**
     * 查询报警消息队列
     */
    private Queue<SearchAlarmInfo> searchAlarmInfoQueue;
    private int alarmType;// 报警类型
    private Date searchTime;// 查询开始时间
    private int searchDays = SEARCH_DAYS;// 查询天数
    private int thumbWidth;// 缩略图-宽
    private int thumbHeight;// 缩略图-高

    public DevAlarmInfoManager(OnAlarmInfoListener listener) {
        this.onAlarmInfoListener = listener;
        this.searchAlarmInfoQueue = new LinkedBlockingDeque<>();
        init();
    }

    @Override
    public boolean init() {
        userId = FunSDK.GetId(userId, this);
        return true;
    }

    @Override
    public void unInit() {
        FunSDK.UnRegUser(userId);
        userId = 0;
    }

    /**
     * 查询报警消息
     *
     * @param devId      设备序列号
     * @param chnId      通道Id
     * @param alarmType  报警类型
     * @param searchTime 查询开始时间
     * @param searchDays 查询的天数
     */
    @Override
    public void searchAlarmInfo(String devId, int chnId, int alarmType,
            Date searchTime, final int searchDays, boolean isSupportCloudStorage) {
        this.alarmType = alarmType;
        this.searchTime = searchTime;
        this.searchDays = searchDays;
        this.isSupportCloudStorage = isSupportCloudStorage;

        if (alarmGroupList != null) {
            alarmGroupList.clear();
        } else {
            alarmGroupList = new ArrayList<>();
        }

        if (searchAlarmInfoQueue != null) {
            searchAlarmInfoQueue.clear();
        }

        if (isSupportCloudStorage) {
            for (int i = 0; i >= 1 - searchDays; i--) {
                // 从几天前查起
                Calendar searchDay = Calendar.getInstance();
                searchDay.setTime(DevAlarmInfoManager.this.searchTime);
                searchDay.add(Calendar.DATE, i);
                searchDay.set(Calendar.HOUR_OF_DAY, 23);
                searchDay.set(Calendar.MINUTE, 59);
                searchDay.set(Calendar.SECOND, 59);

                SearchAlarmInfo searchAlarmInfo = new SearchAlarmInfo();
                searchAlarmInfo.setDevId(devId);
                searchAlarmInfo.setChnId(chnId);
                searchAlarmInfo.setSearchCalendar(searchDay);
                searchAlarmInfo.setFlag(i);
                searchAlarmInfoQueue.offer(searchAlarmInfo);
            }

            searchAlarmInfoByDayQueue();
        } else {
            searchAlarmInfoAll(devId, chnId);
        }

    }

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
    @Override
    public void searchAlarmInfo(String devId, int chnId, int alarmType, Date searchTime, int searchDays, int thumbWidth,
            int thumbHeight) {
        this.thumbWidth = thumbWidth;
        this.thumbHeight = thumbHeight;
        searchAlarmInfo(devId, chnId, alarmType, searchTime, searchDays, true);
    }

    /**
     * 按天队列查找报警消息
     */
    public boolean searchAlarmInfoByDayQueue() {
        if (searchAlarmInfoQueue == null || searchAlarmInfoQueue.isEmpty()) {
            return false;
        }

        synchronized (searchAlarmInfoQueue) {
            SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
            if (searchAlarmInfo != null) {
                Calendar calendar = searchAlarmInfo.getSearchCalendar();
                int flag = searchAlarmInfo.getFlag();
                return searchAlarmInfoByDay(searchAlarmInfo.getDevId(), searchAlarmInfo.getChnId(), calendar, flag);
            }
        }

        return false;
    }

    /**
     * 按天查找报警消息
     *
     * @param calendar
     */
    private boolean searchAlarmInfoByDay(String devId, int chnId, Calendar calendar, int seq) {
        if (calendar == null) {
            return false;
        }

        Calendar startSearchDay = Calendar.getInstance();
        startSearchDay.setTime(calendar.getTime());
        startSearchDay.set(Calendar.HOUR_OF_DAY, 0);
        startSearchDay.set(Calendar.MINUTE, 0);
        startSearchDay.set(Calendar.SECOND, 0);

        Calendar stopSearchDay = Calendar.getInstance();
        stopSearchDay.setTime(calendar.getTime());

        searchAlarmInfoByTime(devId, chnId, startSearchDay, stopSearchDay, seq);
        return true;
    }

    /**
     * 删除报警消息
     *
     * @param devId      设备序列号
     * @param deleteType MSG：删除图片和消息 VIDEO：删除视频
     * @param alarmInfos 报警信息
     */
    @Override
    public void deleteAlarmInfo(String devId, String deleteType, AlarmInfo... alarmInfos) {
        if (alarmInfos == null) {
            return;
        }

        // if (alarmGroupList == null || alarmGroupList.isEmpty()) {
        // return;
        // }

        // synchronized (alarmGroupList) {
        if (tempDeleteAlarmInfos == null) {
            tempDeleteAlarmInfos = new ArrayList<>();
        }

        StringBuffer sb = new StringBuffer();
        ArrayList<String> sendJsons = new ArrayList();
        for (int i = 0; i < alarmInfos.length; ++i) {
            sb.append(alarmInfos[i].getId());
            sb.append(";");
            tempDeleteAlarmInfos.add(alarmInfos[i]);
            if (!StringUtils.isStringNULL(sb.toString())) {
                if ((i + 1) % DELETE_SEND_DATA_MAX_COUNT == 0
                        || (i + 1) == alarmInfos.length) {
                    sendJsons.add(sb.toString());
                    sb = new StringBuffer();
                }
            }
        }

        if (sendJsons.isEmpty()) {
            return;
        }

        for (int i = 0; i < sendJsons.size(); i++) {
            String sendJson = sendJsons.get(i);
            boolean isLast = ((i + 1) == sendJsons.size());
            MpsClient.DeleteMediaFile(userId, devId, deleteType, sendJson, isLast ? 1 : 0);
        }
        // }
    }

    /**
     * 删除是所有报警消息
     *
     * @param devId      设备序列号
     * @param deleteType MSG：删除图片和消息 VIDEO：删除视频
     */
    @Override
    public void deleteAllAlarmInfos(String devId, String deleteType) {
        MpsClient.DeleteMediaFile(userId, devId, deleteType, null, 1);
    }

    /**
     * 查询所有报警消息
     *
     * @param devId 设备序列号
     * @param chnId 设备通道号
     */
    @Override
    public void searchAlarmInfoAll(String devId, int chnId) {
        XPMS_SEARCH_ALARMINFO_REQ info = new XPMS_SEARCH_ALARMINFO_REQ();
        G.SetValue(info.st_00_Uuid, devId);
        Calendar c = Calendar.getInstance();
        c.setTime(searchTime);
        info.st_02_StarTime.st_0_year = c.get(Calendar.YEAR);
        info.st_02_StarTime.st_1_month = c.get(Calendar.MONTH) + 1;
        info.st_02_StarTime.st_2_day = c.get(Calendar.DATE);
        info.st_02_StarTime.st_4_hour = 0;
        info.st_02_StarTime.st_5_minute = 0;
        info.st_02_StarTime.st_6_second = 0;
        info.st_03_EndTime.st_0_year = c.get(Calendar.YEAR);
        info.st_03_EndTime.st_1_month = c.get(Calendar.MONTH) + 1;
        info.st_03_EndTime.st_2_day = c.get(Calendar.DATE);
        info.st_03_EndTime.st_4_hour = 23;
        info.st_03_EndTime.st_5_minute = 59;
        info.st_03_EndTime.st_6_second = 59;
        info.st_04_Channel = chnId;
        info.st_06_Number = 0;
        info.st_05_AlarmType = alarmType;
        MpsClient.SearchAlarmInfo(userId, G.ObjToBytes(info), 0);
    }

    /**
     * 按时间查询报警消息
     *
     * @param devId          设备序列号
     * @param chnId          通道号
     * @param startSearchDay 查询开始时间
     * @param stopSearchDay  查询结束时间
     * @param seq
     */
    public void searchAlarmInfoByTime(String devId, int chnId, Calendar startSearchDay, Calendar stopSearchDay,
            int seq) {
        XPMS_SEARCH_ALARMINFO_REQ info = new XPMS_SEARCH_ALARMINFO_REQ();
        G.SetValue(info.st_00_Uuid, devId);

        info.st_02_StarTime.st_0_year = startSearchDay.get(Calendar.YEAR);
        info.st_02_StarTime.st_1_month = startSearchDay.get(Calendar.MONTH) + 1;
        info.st_02_StarTime.st_2_day = startSearchDay.get(Calendar.DATE);
        info.st_02_StarTime.st_4_hour = startSearchDay.get(Calendar.HOUR_OF_DAY);
        info.st_02_StarTime.st_5_minute = startSearchDay.get(Calendar.MINUTE);
        info.st_02_StarTime.st_6_second = startSearchDay.get(Calendar.SECOND);
        info.st_03_EndTime.st_0_year = stopSearchDay.get(Calendar.YEAR);
        info.st_03_EndTime.st_1_month = stopSearchDay.get(Calendar.MONTH) + 1;
        info.st_03_EndTime.st_2_day = stopSearchDay.get(Calendar.DATE);
        info.st_03_EndTime.st_4_hour = stopSearchDay.get(Calendar.HOUR_OF_DAY);
        info.st_03_EndTime.st_5_minute = stopSearchDay.get(Calendar.MINUTE);
        info.st_03_EndTime.st_6_second = stopSearchDay.get(Calendar.SECOND);
        info.st_04_Channel = chnId;
        info.st_06_Number = 0;
        info.st_05_AlarmType = alarmType;
        // MpsClient.SearchAlarmInfoByTime(userId, G.ObjToBytes(info), seq);
        // //返回的报警消息按时间倒序
        MpsClient.SearchCloudAlarmInfoByTime(userId, G.ObjToBytes(info), thumbWidth, thumbHeight, seq);// 新的报警消息列表查询
    }

    /**
     * 按时间查询报警消息
     *
     * @param devId          设备序列号
     * @param chnId          通道号
     * @param startSearchDay 查询开始时间
     * @param stopSearchDay  查询结束时间
     */
    private void searchAlarmInfoByTime(String devId, int chnId, Calendar startSearchDay, Calendar stopSearchDay) {
        searchAlarmInfoByTime(devId, chnId, startSearchDay, stopSearchDay, 0);
    }

    /**
     * 按时间查询报警消息
     *
     * @param devId    设备序列号
     * @param chnId    通道号
     * @param stopTime 查询开始时间
     * @param seq
     */
    private void searchAlarmInfoByTime(String devId, int chnId, String stopTime, int seq) {
        // 从几天前查起
        Calendar startSearchDay = Calendar.getInstance();
        startSearchDay.setTime(searchTime);
        startSearchDay.add(Calendar.DATE, seq);
        startSearchDay.set(Calendar.HOUR_OF_DAY, 0);
        startSearchDay.set(Calendar.MINUTE, 0);
        startSearchDay.set(Calendar.SECOND, 0);
        XPMS_SEARCH_ALARMINFO_REQ info = new XPMS_SEARCH_ALARMINFO_REQ();
        G.SetValue(info.st_00_Uuid, devId);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date();
        try {
            date = sdf.parse(stopTime);
            Calendar stopSearchDay = Calendar.getInstance();
            stopSearchDay.setTime(date);
            stopSearchDay.add(Calendar.SECOND, -1); // -1s

            if (isContinueToSearchAlarmInfo()) {
                searchAlarmInfoByTime(devId, chnId, startSearchDay, stopSearchDay, seq);
            } else {
                SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
                if (searchAlarmInfo != null) {
                    searchAlarmInfo.setSearchCalendar(stopSearchDay);
                }

                onAlarmInfoListener.onSearchResult(alarmGroupList);
            }
        } catch (ParseException e) {
            Log.e("ccy", "查询报警消息时，服务器返回的时间格式不对");
            e.printStackTrace();
        }
    }

    /**
     * 是否有报警消息
     *
     * @return
     */
    private boolean isHaveAlarmInfo() {
        if (alarmGroupList == null) {
            return false;
        }

        synchronized (alarmGroupList) {
            return !alarmGroupList.isEmpty();
        }
    }

    private boolean isContinueToSearchAlarmInfo() {
        if (alarmGroupList == null || alarmGroupList.isEmpty()) {
            return true;
        }

        int alarmCount = 0;
        for (AlarmGroup alarmGroup : alarmGroupList) {
            if (alarmGroup != null) {
                alarmCount += alarmGroup.getCount();
            }
        }

        if (alarmCount < SEARCH_MIN_COUNT) {
            return true;
        }

        return false;
    }

    @Override
    public int OnFunSDKResult(Message msg, MsgContent ex) {
        switch (msg.what) {
            case EUIMSG.MC_SearchAlarmInfo:
                if (msg.arg1 >= 0) {
                    dealWithSearchAlarmResult(msg, ex);
                } else {
                    searchAlarmInfoQueue.poll();
                    if (msg.arg1 == EE_NOT_FOUND_ALARM_INFO) {
                        if (!isHaveAlarmInfo()) {
                            if (!searchAlarmInfoByDayQueue()) {
                                if (onAlarmInfoListener != null) {
                                    onAlarmInfoListener.onSearchResult(null);
                                }
                            }
                        } else if (isContinueToSearchAlarmInfo()) {
                            if (!searchAlarmInfoByDayQueue()) {
                                if (onAlarmInfoListener != null) {
                                    onAlarmInfoListener.onSearchResult(alarmGroupList);
                                }
                            }
                        }
                    } else {
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(null);
                        }
                    }
                }
                break;
            case EUIMSG.MC_SEARCH_CLOUD_ALARM_INFO:
                if (msg.arg1 >= 0) {
                    dealWithSearchAlarmResultV2(msg, ex);
                } else {
                    searchAlarmInfoQueue.poll();
                    if (msg.arg1 == EE_NOT_FOUND_ALARM_INFO) {
                        if (!isHaveAlarmInfo()) {
                            if (!searchAlarmInfoByDayQueue()) {
                                if (onAlarmInfoListener != null) {
                                    onAlarmInfoListener.onSearchResult(null);
                                }
                            }
                        } else if (isContinueToSearchAlarmInfo()) {
                            if (!searchAlarmInfoByDayQueue()) {
                                if (onAlarmInfoListener != null) {
                                    onAlarmInfoListener.onSearchResult(alarmGroupList);
                                }
                            }
                        }
                    } else {
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(null);
                        }
                    }
                }
                break;
            case EUIMSG.MC_DeleteAlarm:
                if (ex.seq == 1) {
                    deleteAlarmInfoResult();
                }

                if (onAlarmInfoListener != null) {
                    onAlarmInfoListener.onDeleteResult(msg.arg1 >= 0, msg, ex, tempDeleteAlarmInfos);
                }
                break;
            default:
                break;
        }
        return 0;
    }

    /**
     * 解析搜索到的报警消息
     *
     * @param msg
     * @param ex
     */
    private void dealWithSearchAlarmResult(Message msg, MsgContent ex) {
        // 消息是否重叠包含了
        boolean isContain = false;
        // 云存储是分段查找的，直到没有消息了再结束
        if (ex.arg3 <= 0) {
            searchAlarmInfoQueue.poll();
            if (isSupportCloudStorage) {
                if (isContinueToSearchAlarmInfo()) {
                    if (!searchAlarmInfoByDayQueue()) {
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(alarmGroupList);
                        }
                    }
                } else {
                    if (onAlarmInfoListener != null) {
                        onAlarmInfoListener.onSearchResult(alarmGroupList);
                    }
                }
            } else {
                if (onAlarmInfoListener != null) {
                    onAlarmInfoListener.onSearchResult(alarmGroupList);
                }
            }
            return;
        }

        AlarmInfo alarmInfo = parseAlarmInfos(ex.arg3, ex.pData);

        Collections.sort(alarmGroupList, (object1, object2) -> {
            return object2.getDate().compareTo(object1.getDate());
        });

        if (isSupportCloudStorage) {
            // 从最后一条报警消息时间-1s继续查（报警消息是按时间倒序返回的）
            if (alarmInfo != null) {
                if (!isContinueToSearchAlarmInfo()) {
                    // 搜索返回150条消息就不再继续查，滑动查看消息时再查询
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Date date = new Date();
                    if (alarmInfo.getStartTime() != null) {
                        try {
                            date = sdf.parse(alarmInfo.getStartTime());
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }
                    }

                    Calendar stopSearchDay = Calendar.getInstance();
                    stopSearchDay.setTime(date);
                    stopSearchDay.add(Calendar.SECOND, -1);
                    SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
                    if (searchAlarmInfo != null) {
                        searchAlarmInfo.setSearchCalendar(stopSearchDay);
                    }
                    if (onAlarmInfoListener != null) {
                        onAlarmInfoListener.onSearchResult(alarmGroupList);
                    }
                } else {
                    SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
                    if (searchAlarmInfo != null) {
                        searchAlarmInfoByTime(searchAlarmInfo.getDevId(), searchAlarmInfo.getChnId(),
                                alarmInfo.getStartTime(), ex.seq);
                    } else {
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(alarmGroupList);
                        }
                    }
                }
            }
        } else {
            if (onAlarmInfoListener != null) {
                onAlarmInfoListener.onSearchResult(alarmGroupList);
            }
        }
    }

    /**
     * V2版本：解析搜索到的报警消息
     *
     * @param msg
     * @param ex
     */
    private void dealWithSearchAlarmResultV2(Message msg, MsgContent ex) {
        // 消息是否重叠包含了
        try {
            String jsonData = G.ToStringJson(ex.pData);
            JSONObject jsonObject = new JSONObject(jsonData);
            int count = 0;// 消息个数
            if (jsonObject.has("msgnum")) {
                count = jsonObject.optInt("msgnum", 0);
            }

            // 云存储是分段查找的，直到没有消息了再结束
            if (count <= 0) {
                searchAlarmInfoQueue.poll();
                if (isSupportCloudStorage) {
                    if (isContinueToSearchAlarmInfo()) {
                        if (!searchAlarmInfoByDayQueue()) {
                            if (onAlarmInfoListener != null) {
                                onAlarmInfoListener.onSearchResult(alarmGroupList);
                            }
                        }
                    } else {
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(alarmGroupList);
                        }
                    }
                } else {
                    if (onAlarmInfoListener != null) {
                        onAlarmInfoListener.onSearchResult(alarmGroupList);
                    }
                }
                return;
            }

            if (!jsonObject.has("msglist")) {
                if (onAlarmInfoListener != null) {
                    onAlarmInfoListener.onSearchResult(alarmGroupList);
                }
                return;
            }

            JSONArray jsonArray = jsonObject.optJSONArray("msglist");
            AlarmInfo alarmInfo = parseAlarmInfosV2(jsonArray);

            Collections.sort(alarmGroupList, (object1, object2) -> {
                return object2.getDate().compareTo(object1.getDate());
            });

            if (isSupportCloudStorage) {
                // 从最后一条报警消息时间-1s继续查（报警消息是按时间倒序返回的）
                if (alarmInfo != null) {
                    if (!isContinueToSearchAlarmInfo()) {
                        // 搜索返回150条消息就不再继续查，滑动查看消息时再查询
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        Date date = new Date();
                        try {
                            date = sdf.parse(alarmInfo.getStartTime());
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }

                        Calendar stopSearchDay = Calendar.getInstance();
                        stopSearchDay.setTime(date);
                        stopSearchDay.add(Calendar.SECOND, -1);
                        SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
                        if (searchAlarmInfo != null) {
                            searchAlarmInfo.setSearchCalendar(stopSearchDay);
                        }
                        if (onAlarmInfoListener != null) {
                            onAlarmInfoListener.onSearchResult(alarmGroupList);
                        }
                    } else {
                        SearchAlarmInfo searchAlarmInfo = searchAlarmInfoQueue.peek();
                        if (searchAlarmInfo != null) {
                            searchAlarmInfoByTime(searchAlarmInfo.getDevId(), searchAlarmInfo.getChnId(),
                                    alarmInfo.getStartTime(), ex.seq);
                        } else {
                            if (onAlarmInfoListener != null) {
                                onAlarmInfoListener.onSearchResult(alarmGroupList);
                            }
                        }
                    }
                }
            } else {
                if (onAlarmInfoListener != null) {
                    onAlarmInfoListener.onSearchResult(alarmGroupList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 解析报警消息数据
     *
     * @param alarmCount
     * @param alarmInfos
     * @return
     */
    private AlarmInfo parseAlarmInfos(int alarmCount, byte[] alarmInfos) {
        if (alarmGroupList == null) {
            alarmGroupList = new ArrayList<>();
        }

        AlarmInfo info = null;
        int nNext[] = new int[1];
        nNext[0] = 0;
        int nStart = 0;
        String time = "";
        for (int i = 0; i < alarmCount; ++i) {
            boolean isExist = false;
            String ret = G.ArrayToString(alarmInfos, nStart, nNext);
            nStart = nNext[0];
            info = new AlarmInfo();
            if (!info.onParse(ret)) {
                if (!info.onParse("{" + ret)) {
                    continue;
                }
            }

            if (null != info.getExtInfo()) {
                String extUserData = info.getExtUserData();
                if (null != extUserData && extUserData.length() > 0) {
                    continue;
                }
            }

            if (XUtils.notEmpty(info.getStartTime()) && info.getStartTime().split(" ").length > 0) {
                time = info.getStartTime().split(" ")[0];
            }

            AlarmGroup group = null;
            if (alarmGroupList.isEmpty()) {
                group = new AlarmGroup();
                group.setDate(time);
                group.getInfoList().add(info);
            } else {
                for (AlarmGroup alarmGroup : alarmGroupList) {
                    if (alarmGroup.getDate().equals(time)) {
                        isExist = true;
                        group = null;
                        alarmGroup.getInfoList().add(info);
                    }

                }
                if (!isExist) {
                    group = new AlarmGroup();
                    group.setDate(time);
                    group.getInfoList().add(info);
                }
            }

            if (group != null && alarmGroupList != null) {
                alarmGroupList.add(group);
            }
        }

        return info;
    }

    private AlarmInfo parseAlarmInfosV2(JSONArray jsonArray) {
        if (jsonArray == null) {
            return null;
        }

        if (alarmGroupList == null) {
            alarmGroupList = new ArrayList<>();
        }

        AlarmInfo alarmInfo = null;
        String time = "";// 报警日期
        ArrayList<AlarmInfo> alarmInfos = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); ++i) {
            boolean isExist = false;
            alarmInfo = new AlarmInfo();
            String subJson = jsonArray.optString(i);
            if (!StringUtils.isStringNULL(subJson)) {
                alarmInfo.onParse(subJson);
                alarmInfos.add(alarmInfo);
                if (XUtils.notEmpty(alarmInfo.getStartTime()) && alarmInfo.getStartTime().split(" ").length > 0) {
                    time = alarmInfo.getStartTime().split(" ")[0];
                }

                AlarmGroup group = null;
                if (alarmGroupList.isEmpty()) {
                    group = new AlarmGroup();
                    group.setDate(time);
                    group.getInfoList().add(alarmInfo);
                } else {
                    for (AlarmGroup alarmGroup : alarmGroupList) {
                        if (alarmGroup.getDate().equals(time)) {
                            isExist = true;
                            group = null;
                            alarmGroup.getInfoList().add(alarmInfo);
                        }

                    }
                    if (!isExist) {
                        group = new AlarmGroup();
                        group.setDate(time);
                        group.getInfoList().add(alarmInfo);
                    }
                }

                if (group != null && alarmGroupList != null) {
                    alarmGroupList.add(group);
                }
            }
        }

        return alarmInfo;
    }

    private void deleteAlarmInfoResult() {
        // synchronized (alarmGroupList) {
        try {
            if (tempDeleteAlarmInfos != null && alarmGroupList != null && !alarmGroupList.isEmpty()) {
                for (AlarmInfo alarmInfo : tempDeleteAlarmInfos) {
                    if (alarmInfo == null) {
                        continue;
                    }

                    for (AlarmGroup alarmGroup : alarmGroupList) {
                        if (alarmGroup != null) {
                            List<AlarmInfo> alarmInfos = alarmGroup.getInfoList();
                            if (alarmInfos != null && alarmInfos.contains(alarmInfo)) {
                                alarmInfos.remove(alarmInfo);
                                break;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // }
    }

    public interface OnAlarmInfoListener {
        /**
         * 查询结果回调
         *
         * @param list 报警消息列表
         */
        void onSearchResult(List<AlarmGroup> list);

        /**
         * 删除消息结果回调
         *
         * @param isSuccess        是否成功
         * @param msg              Message
         * @param ex               MsgContent
         * @param deleteAlarmInfos 删除的报警消息列表
         */
        void onDeleteResult(boolean isSuccess, Message msg, MsgContent ex, List<AlarmInfo> deleteAlarmInfos);
    }
}
