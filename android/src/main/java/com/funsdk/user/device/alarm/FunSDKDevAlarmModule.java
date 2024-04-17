package com.funsdk.user.device.alarm;

import android.os.Message;
import android.util.Log;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Callback;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;
import com.funsdk.utils.device.alarm.DevAlarmInfoManager;

import com.lib.sdk.bean.alarm.AlarmGroup;
import com.lib.sdk.bean.alarm.AlarmInfo;
import com.lib.sdk.bean.alarm.AlarmInfo.LinkCenterExt;
// import com.manager.device.alarm.DevAlarmInfoManager;
import com.lib.MsgContent;

import java.util.Calendar;
import java.util.List;
import java.util.ArrayList;

// https://oppf.xmcsrv.com/static/md/docs/javadoc/
// https://oppf.jftech.com/#/docs?md=androidAlarmInter&lang=en
public class FunSDKDevAlarmModule extends ReactContextBaseJavaModule {
  public FunSDKDevAlarmModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKDevAlarmModule";
  }

  @ReactMethod
  public void searchAlarmMsg(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] {
            Constants.DEVICE_ID,
            Constants.DEVICE_CHANNEL,
            Constants.ALARM_TYPE,
            Constants.SEARCH_TIME,
            Constants.SEARCH_DAYS,
            Constants.IMAGE_SIZES,
        }, params)) {

      DevAlarmInfoManager devAlarmInfoManager;

      devAlarmInfoManager = new DevAlarmInfoManager(new DevAlarmInfoManager.OnAlarmInfoListener() {
        @Override
        public void onSearchResult(List<AlarmGroup> alarmGroupList) {
          WritableArray alarmArray = Arguments.createArray();

          if (alarmGroupList != null) {
            List<AlarmInfo> alarmMsgList = new ArrayList<>();
            for (AlarmGroup alarmGroup : alarmGroupList) {
              for (AlarmInfo alarmInfo : alarmGroup.getInfoList()) {
                alarmMsgList.add(alarmInfo);
              }
            }

            for (AlarmInfo alarmMsg : alarmMsgList) {
              WritableMap alarmMap = Arguments.createMap();
              alarmMap.putBoolean("videoInfo", alarmMsg.isVideoInfo());
              alarmMap.putString("extInfo", alarmMsg.getExtInfo());
              alarmMap.putString("serialNumber", alarmMsg.getSn());
              alarmMap.putString("id", alarmMsg.getId());
              alarmMap.putInt("channel", alarmMsg.getChannel());
              alarmMap.putString("event", alarmMsg.getEvent());
              alarmMap.putString("startTime", alarmMsg.getStartTime());
              alarmMap.putString("status", alarmMsg.getStatus());
              // getPicSize - тип long
              alarmMap.putDouble("picsize", alarmMsg.getPicSize());
              alarmMap.putString("pushMsg", alarmMsg.getPushMsg());
              alarmMap.putString("alarmRing", alarmMsg.getAlarmRing());
              alarmMap.putString("pic", alarmMsg.getPic());
              alarmMap.putInt("picError", alarmMsg.getPicError());
              alarmMap.putBoolean("isHavePic", alarmMsg.isHavePic());
              alarmMap.putString("devName", alarmMsg.getDevName());

              WritableMap linkCenter = Arguments.createMap();
              LinkCenterExt mLinkCenterExt = alarmMsg.getLinkCenterExt();

              if (mLinkCenterExt != null) {

                linkCenter.putString("msgType", mLinkCenterExt.getMsgType());
                linkCenter.putString("msg", mLinkCenterExt.getMsg());
                linkCenter.putString("subSn", mLinkCenterExt.getSubSn());
                linkCenter.putInt("modelType", mLinkCenterExt.getModelType());

                alarmMap.putMap("linkCenter", linkCenter);
              } else {
                alarmMap.putMap("linkCenter", null);

              }

              alarmArray.pushMap(alarmMap);
            }
          }

          promise.resolve(alarmArray);
        }

        @Override
        public void onDeleteResult(boolean isSuccess, Message message, MsgContent msgContent, List<AlarmInfo> list) {

        }
      });

      // example - 1699680774000
      long timeLong = (long) params.getDouble(Constants.SEARCH_TIME);
      Calendar searchTime = Calendar.getInstance();
      searchTime.setTimeInMillis(timeLong);

      ReadableMap imgSizes = params.getMap(Constants.IMAGE_SIZES);
      int imgWidth = imgSizes.getInt(Constants.IMAGE_WIDTH); // 90
      int imgHeight = imgSizes.getInt(Constants.IMAGE_HEIGHT); // 160

      devAlarmInfoManager.searchAlarmInfo(
          params.getString(Constants.DEVICE_ID),
          params.getInt(Constants.DEVICE_CHANNEL),
          params.getInt(Constants.ALARM_TYPE),
          searchTime.getTime(),
          params.getInt(Constants.SEARCH_DAYS),
          imgWidth,
          imgHeight);
    }
  }

  @ReactMethod
  public void deleteAlarmInfo(ReadableMap params, Promise promise) {

    if (ReactParamsCheck
        .checkParams(new String[] {
            Constants.DEVICE_ID,
            Constants.DELETE_TYPE, // MSG or VIDEO
            Constants.ALARM_INFOS,
        }, params)) {

      DevAlarmInfoManager devAlarmInfoManager;

      devAlarmInfoManager = new DevAlarmInfoManager(new DevAlarmInfoManager.OnAlarmInfoListener() {
        @Override
        public void onSearchResult(List<AlarmGroup> alarmGroupList) {
        }

        @Override
        public void onDeleteResult(boolean isSuccess, Message message, MsgContent msgContent, List<AlarmInfo> list) {
          WritableMap resultMap = Arguments.createMap();

          WritableArray alarmArray = Arguments.createArray();

          for (AlarmInfo alarmMsg : list) {
            WritableMap alarmMap = Arguments.createMap();
            alarmMap.putBoolean("videoInfo", alarmMsg.isVideoInfo());
            alarmMap.putString("extInfo", alarmMsg.getExtInfo());
            alarmMap.putString("serialNumber", alarmMsg.getSn());
            alarmMap.putString("id", alarmMsg.getId());
            alarmMap.putInt("channel", alarmMsg.getChannel());
            alarmMap.putString("event", alarmMsg.getEvent());
            alarmMap.putString("startTime", alarmMsg.getStartTime());
            alarmMap.putString("status", alarmMsg.getStatus());
            // getPicSize - тип long
            alarmMap.putDouble("picsize", alarmMsg.getPicSize());
            alarmMap.putString("pushMsg", alarmMsg.getPushMsg());
            alarmMap.putString("alarmRing", alarmMsg.getAlarmRing());
            alarmMap.putString("pic", alarmMsg.getPic());
            alarmMap.putInt("picError", alarmMsg.getPicError());
            alarmMap.putBoolean("isHavePic", alarmMsg.isHavePic());
            alarmMap.putString("devName", alarmMsg.getDevName());

            WritableMap linkCenter = Arguments.createMap();
            LinkCenterExt mLinkCenterExt = alarmMsg.getLinkCenterExt();

            if (mLinkCenterExt != null) {

              linkCenter.putString("msgType", mLinkCenterExt.getMsgType());
              linkCenter.putString("msg", mLinkCenterExt.getMsg());
              linkCenter.putString("subSn", mLinkCenterExt.getSubSn());
              linkCenter.putInt("modelType", mLinkCenterExt.getModelType());

              alarmMap.putMap("linkCenter", linkCenter);
            } else {
              alarmMap.putMap("linkCenter", null);

            }

            alarmArray.pushMap(alarmMap);
          }

          resultMap.putArray(Constants.ALARM_INFOS, alarmArray);
          resultMap.putBoolean("isSuccess", isSuccess);

          promise.resolve(resultMap);
        }
      });

      ReadableArray alarmArray = params.getArray(Constants.ALARM_INFOS);

      List<AlarmInfo> alarmList = new ArrayList<AlarmInfo>();

      for (int i = 0; i < alarmArray.size(); i++) {
        ReadableMap alarmMap = alarmArray.getMap(i);
        AlarmInfo info = new AlarmInfo();
        info.setId(alarmMap.getString("id"));

        alarmList.add(info);
      }

      devAlarmInfoManager.deleteAlarmInfo(
          params.getString(Constants.DEVICE_ID),
          params.getString(Constants.DELETE_TYPE),
          alarmList.toArray(new AlarmInfo[0]));
    }
  }

  @ReactMethod
  public void deleteAllAlarmMsg(ReadableMap params, Promise promise) {
    // 删除消息和图片
    // devAlarmInfoManager.deleteAllAlarmInfos(getDevId(), "MSG");
    // 删除视频
    // devAlarmInfoManager.deleteAllAlarmInfos(getDevId(), "VIDEO");

    if (ReactParamsCheck
        .checkParams(new String[] {
            Constants.DEVICE_ID,
            Constants.DELETE_TYPE, // MSG or VIDEO
        }, params)) {

      DevAlarmInfoManager devAlarmInfoManager;

      devAlarmInfoManager = new DevAlarmInfoManager(new DevAlarmInfoManager.OnAlarmInfoListener() {
        @Override
        public void onSearchResult(List<AlarmGroup> alarmGroupList) {
        }

        @Override
        public void onDeleteResult(boolean isSuccess, Message message, MsgContent msgContent, List<AlarmInfo> list) {

          WritableMap resultMap = Arguments.createMap();
          resultMap.putBoolean("isSuccess", isSuccess);

          promise.resolve(resultMap);
        }
      });

      devAlarmInfoManager.deleteAllAlarmInfos(
          params.getString(Constants.DEVICE_ID),
          params.getString(Constants.DELETE_TYPE));
    }
  }
}
