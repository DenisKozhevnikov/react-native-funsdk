package com.funsdk.user.device.alarm;

import android.os.Message;
import android.util.Log;
import android.content.Context;

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

import com.manager.push.XMPushManager;
import com.manager.account.XMAccountManager;
import com.lib.Mps.SMCInitInfoV2;
import com.basic.G;
import com.lib.FunSDK;
import com.lib.EUIMSG;
import com.lib.IFunSDKResult;
import com.funsdk.utils.DataConverter;
import org.json.JSONObject;
import org.json.JSONException;

import java.util.Calendar;
import java.util.List;
import java.util.ArrayList;

// https://oppf.xmcsrv.com/static/md/docs/javadoc/
// https://oppf.jftech.com/#/docs?md=androidAlarmInter&lang=en
public class FunSDKDevAlarmModule extends ReactContextBaseJavaModule implements XMPushManager.OnXMPushLinkListener, IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private XMPushManager pushManager;
  private Promise pendingInitPromise;
  private java.util.Map<String, Promise> pendingLinkPromises = new java.util.HashMap<>();
  private java.util.Map<String, Promise> pendingUnlinkPromises = new java.util.HashMap<>();
  private Promise pendingBatchLinkPromise;
  private java.util.Set<String> pendingBatchDevIds;
  private WritableMap batchResults;

  private int mUserId = 0;
  private boolean isRegistered = false;
  private int mSeq = 1;

  private static class PendingOp {
    final String devId;
    final Promise promise;
    PendingOp(String devId, Promise promise) { this.devId = devId; this.promise = promise; }
  }
  private final java.util.Map<Integer, PendingOp> pendingGetPms = new java.util.HashMap<>();
  private final java.util.Map<Integer, PendingOp> pendingSetPms = new java.util.HashMap<>();

  public FunSDKDevAlarmModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    try {
      mUserId = FunSDK.GetId(mUserId, this);
      isRegistered = true;
      Log.e("ALARM", "Registered IFunSDKResult userId=" + mUserId);
    } catch (Throwable ignored) {}
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

  // === Push/Alarm server init & link/unlink ===
  @ReactMethod
  public void initAlarmServer(ReadableMap params, Promise promise) {
    try {
      if (pushManager == null) {
        pushManager = new XMPushManager(this);
      }

      String username = params.hasKey("username") && !params.isNull("username") ? params.getString("username") : XMAccountManager.getInstance().getAccountName();
      String password = params.hasKey("password") && !params.isNull("password") ? params.getString("password") : XMAccountManager.getInstance().getPassword();
      String token = params.hasKey("token") && !params.isNull("token") ? params.getString("token") : "";
      int pushType = params.hasKey("pushType") ? params.getInt("pushType") : XMPushManager.PUSH_TYPE_GOOGLE_V2;

      SMCInitInfoV2 info = new SMCInitInfoV2();
      G.SetValue(info.st_0_user, username != null ? username : "");
      G.SetValue(info.st_1_password, password != null ? password : "");
      G.SetValue(info.st_3_token, token != null ? token : "");

      pendingInitPromise = promise;
      pushManager.initFunSDKPush((Context) reactContext, info, pushType);
    } catch (Throwable t) {
      promise.reject("InitAlarmServerError", t);
    }
  }

  private void ensureUser() {
    if (!isRegistered) {
      mUserId = FunSDK.GetId(mUserId, this);
      isRegistered = true;
    }
  }

  private int nextSeq() {
    mSeq += 1;
    return mSeq;
  }

  private String sanitize(String raw) {
    if (raw == null) return "";
    String s = raw;
    int zero = s.indexOf('\u0000');
    if (zero >= 0) s = s.substring(0, zero);
    int start = s.indexOf('{');
    int end = s.lastIndexOf('}');
    if (start >= 0 && end >= start) s = s.substring(start, end + 1);
    return s.trim();
  }

  private String extractNameFromJson(String json) {
    try {
      if (json == null || json.isEmpty()) return null;
      JSONObject obj = new JSONObject(json);
      if (obj.has("Name")) return obj.getString("Name");
    } catch (Throwable ignored) {}
    return null;
  }

  @ReactMethod
  public void linkAlarm(ReadableMap params, Promise promise) {
    try {
      if (pushManager == null) {
        pushManager = new XMPushManager(this);
      }
      if (ReactParamsCheck.checkParams(new String[] { Constants.DEVICE_ID }, params)) {
        String devId = params.getString(Constants.DEVICE_ID);
        // Optional credentials parity with iOS
        try {
          if (params.hasKey("deviceLogin") && params.hasKey("devicePassword") &&
              !params.isNull("deviceLogin") && !params.isNull("devicePassword")) {
            String deviceLogin = params.getString("deviceLogin");
            String devicePassword = params.getString("devicePassword");
            if (devId != null && !devId.trim().isEmpty()) {
              FunSDK.DevSetLocalPwd(devId, deviceLogin, devicePassword);
            }
          }
        } catch (Throwable ignored) {}
        pendingLinkPromises.put(devId, promise);
        pushManager.linkAlarm(devId, 0);
      }
    } catch (Throwable t) {
      promise.reject("LinkAlarmError", t);
    }
  }

  @ReactMethod
  public void unlinkAlarm(ReadableMap params, Promise promise) {
    try {
      if (pushManager == null) {
        pushManager = new XMPushManager(this);
      }
      if (ReactParamsCheck.checkParams(new String[] { Constants.DEVICE_ID }, params)) {
        String devId = params.getString(Constants.DEVICE_ID);
        pendingUnlinkPromises.put(devId, promise);
        pushManager.unLinkAlarm(devId, 0);
      }
    } catch (Throwable t) {
      promise.reject("UnlinkAlarmError", t);
    }
  }

  // iOS API parity: linkDevGeneral
  @ReactMethod
  public void linkDevGeneral(ReadableMap params, Promise promise) {
    try {
      if (pushManager == null) {
        pushManager = new XMPushManager(this);
      }
      String devId = params.hasKey("deviceId") ? params.getString("deviceId") : null;
      if (devId == null) {
        promise.reject("ParamsError", "deviceId is required");
        return;
      }
      // Map optional params similar to iOS; use if provided
      try {
        String devUserName = params.hasKey("devUserName") && !params.isNull("devUserName") ? params.getString("devUserName") : null;
        String devUserPwd = params.hasKey("devUserPwd") && !params.isNull("devUserPwd") ? params.getString("devUserPwd") : null;
        if (devUserName != null && devUserPwd != null && !devId.trim().isEmpty()) {
          FunSDK.DevSetLocalPwd(devId, devUserName, devUserPwd);
        }
      } catch (Throwable ignored) {}
      // Optional re-init with appToken/appType
      try {
        if ((params.hasKey("appToken") && !params.isNull("appToken")) || (params.hasKey("appType") && !params.isNull("appType"))) {
          String token = params.hasKey("appToken") ? params.getString("appToken") : "";
          int pushType = XMPushManager.PUSH_TYPE_GOOGLE_V2;
          SMCInitInfoV2 info = new SMCInitInfoV2();
          G.SetValue(info.st_0_user, XMAccountManager.getInstance().getAccountName());
          G.SetValue(info.st_1_password, XMAccountManager.getInstance().getPassword());
          G.SetValue(info.st_3_token, token);
          pushManager.initFunSDKPush((Context) reactContext, info, pushType);
        }
      } catch (Throwable ignored) {}
      pendingLinkPromises.put(devId, promise);
      pushManager.linkAlarm(devId, 0);
    } catch (Throwable t) {
      promise.reject("LinkDevGeneralError", t);
    }
  }

  // iOS API parity: unlinkDevGeneral (alias)
  @ReactMethod
  public void unlinkDevGeneral(ReadableMap params, Promise promise) {
    unlinkAlarm(params, promise);
  }

  // iOS API parity: linkDevsBatch
  @ReactMethod
  public void linkDevsBatch(ReadableMap params, Promise promise) {
    try {
      if (pushManager == null) {
        pushManager = new XMPushManager(this);
      }
      String ids = params.hasKey("deviceIds") ? params.getString("deviceIds") : null;
      if (ids == null || ids.trim().isEmpty()) {
        promise.reject("ParamsError", "deviceIds is required (comma-separated)");
        return;
      }
      String[] arr = ids.split(",");
      pendingBatchLinkPromise = promise;
      pendingBatchDevIds = new java.util.HashSet<>();
      batchResults = Arguments.createMap();
      for (String raw : arr) {
        String devId = raw.trim();
        if (devId.isEmpty()) continue;
        pendingBatchDevIds.add(devId);
        pendingLinkPromises.put(devId, null); // mark tracked
        pushManager.linkAlarm(devId, 0);
      }
      if (pendingBatchDevIds.isEmpty()) {
        promise.resolve(Arguments.createMap());
      }
    } catch (Throwable t) {
      promise.reject("LinkDevsBatchError", t);
    }
  }

  // === iOS parity: Get/Set Alarm (NetWork.PMS) ===
  @ReactMethod
  public void getAlarmState(ReadableMap params, Promise promise) {
    try {
      if (ReactParamsCheck.checkParams(new String[] { Constants.DEVICE_ID }, params)) {
        ensureUser();
        String devId = params.getString(Constants.DEVICE_ID);
        int seq = nextSeq();
        pendingGetPms.put(seq, new PendingOp(devId, promise));
        int ret = FunSDK.DevGetConfigByJson(mUserId, devId, "NetWork.PMS", 4096, -1, 15000, seq);
        Log.e("ALARM", "DevGetConfigByJson(NetWork.PMS) ret=" + ret + ", seq=" + seq + ", devId=" + devId);
        if (ret < 0) {
          pendingGetPms.remove(seq);
          promise.reject(String.valueOf(ret), "DEV_GET_CONFIG immediate error");
        }
      }
    } catch (Throwable t) {
      promise.reject("GetAlarmStateError", t);
    }
  }

  @ReactMethod
  public void setAlarmState(ReadableMap params, Promise promise) {
    try {
      if (ReactParamsCheck.checkParams(new String[] { Constants.DEVICE_ID, "isAlertEnabled" }, params)) {
        ensureUser();
        String devId = params.getString(Constants.DEVICE_ID);
        boolean enabled = params.getBoolean("isAlertEnabled");
        String json = "{\"Name\":\"NetWork.PMS\",\"NetWork.PMS\":{\"Enable\":" + (enabled ? "true" : "false") + "}}";
        int seq = nextSeq();
        pendingSetPms.put(seq, new PendingOp(devId, promise));
        int ret = FunSDK.DevSetConfigByJson(mUserId, devId, "NetWork.PMS", json, -1, 15000, seq);
        Log.e("ALARM", "DevSetConfigByJson(NetWork.PMS) ret=" + ret + ", seq=" + seq + ", devId=" + devId + ", enable=" + enabled);
        if (ret < 0) {
          pendingSetPms.remove(seq);
          promise.reject(String.valueOf(ret), "DEV_SET_CONFIG immediate error");
        }
      }
    } catch (Throwable t) {
      promise.reject("SetAlarmStateError", t);
    }
  }

  // === XMPushManager callbacks (no-op logging) ===
  @Override
  public void onPushInit(int pushType, int errorId) {
    Log.e("PUSH", "onPushInit pushType=" + pushType + " err=" + errorId);
    if (pendingInitPromise != null) {
      Promise p = pendingInitPromise;
      pendingInitPromise = null;
      if (errorId >= 0) p.resolve(true); else p.reject("InitAlarmServerError", String.valueOf(errorId));
    }
  }

  @Override
  public void onPushLink(int pushType, String devId, int seq, int errorId) {
    Log.e("PUSH", "onPushLink devId=" + devId + " pushType=" + pushType + " err=" + errorId);
    Promise p = pendingLinkPromises.remove(devId);
    if (p != null) {
      if (errorId >= 0) p.resolve(true); else p.reject("LinkAlarmError", String.valueOf(errorId));
    }
    if (pendingBatchDevIds != null && pendingBatchDevIds.contains(devId)) {
      pendingBatchDevIds.remove(devId);
      try { batchResults.putBoolean(devId, errorId >= 0); } catch (Throwable ignored) {}
      if (pendingBatchDevIds.isEmpty() && pendingBatchLinkPromise != null) {
        Promise bp = pendingBatchLinkPromise;
        pendingBatchLinkPromise = null;
        bp.resolve(batchResults);
      }
    }
  }

  @Override
  public void onPushUnLink(int pushType, String devId, int seq, int errorId) {
    Log.e("PUSH", "onPushUnLink devId=" + devId + " pushType=" + pushType + " err=" + errorId);
    Promise p = pendingUnlinkPromises.remove(devId);
    if (p != null) {
      if (errorId >= 0) p.resolve(true); else p.reject("UnlinkAlarmError", String.valueOf(errorId));
    }
  }

  @Override
  public void onIsPushLinkedFromServer(int pushType, String devId, boolean isLinked) {
    Log.e("PUSH", "onIsPushLinkedFromServer devId=" + devId + " linked=" + isLinked);
  }

  @Override
  public void onAlarmInfo(int pushType, String devId, Message message, com.lib.MsgContent msgContent) {
    // no-op
  }

  @Override
  public void onLinkDisconnect(int i, String s) {
    Log.e("PUSH", "onLinkDisconnect code=" + i + " info=" + s);
  }

  @Override
  public void onWeChatState(String s, int i, int i1) {
    // no-op
  }

  @Override
  public void onThirdPushState(String info, int pushType, int state, int errorId) {
    Log.e("PUSH", "onThirdPushState info=" + info + " state=" + state + " err=" + errorId);
  }

  @Override
  public void onAllUnLinkResult(boolean isSuccess) {
    // no-op
  }

  // Required by XMPushManager.OnXMPushLinkListener (distinct from IFunSDKResult)
  @Override
  public void onFunSDKResult(Message message, MsgContent msgContent) {
    // no-op
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;
    try { Log.e("ALARM", "OnFunSDKResult what=" + what + ", arg1=" + arg1 + ", seq=" + seq); } catch (Throwable ignored) {}

    try {
      if (what == EUIMSG.DEV_GET_JSON || what == EUIMSG.DEV_GET_CONFIG) {
        PendingOp pend = pendingGetPms.remove(seq);
        String data = null;
        if (ex != null) {
          if (ex.pData != null && ex.pData.length > 0) {
            data = new String(ex.pData, java.nio.charset.Charset.forName("UTF-8")).trim();
          } else if (ex.str != null) {
            data = ex.str.trim();
          }
        }
        String cleaned = sanitize(data);
        Log.e("ALARM", "OnFunSDKResult GET PMS seq=" + seq + ", arg1=" + arg1 + ", len=" + (cleaned != null ? cleaned.length() : -1));

        if (pend == null) {
          // Fallback by Name when seq is -1
          String name = extractNameFromJson(cleaned);
          if ("NetWork.PMS".equals(name) && !pendingGetPms.isEmpty()) {
            Integer anySeq = pendingGetPms.keySet().iterator().next();
            pend = pendingGetPms.remove(anySeq);
          }
        }

        if (pend != null) {
          if (arg1 >= 0) {
            // Ignore header-only response (no NetWork.PMS payload), wait for full one
            boolean hasPayload = false;
            try {
              if (cleaned != null && !cleaned.isEmpty()) {
                JSONObject obj = new JSONObject(cleaned);
                hasPayload = obj.has("NetWork.PMS");
              }
            } catch (Throwable ignored) {}
            if (!hasPayload) {
              // Keep pending for the full response
              pendingGetPms.put(seq, pend);
              return 0;
            }

            WritableMap parsed;
            try {
              parsed = DataConverter.parseToWritableMap(cleaned);
            } catch (Throwable t) {
              parsed = Arguments.createMap();
              parsed.putString("raw", cleaned);
            }
            WritableMap res = Arguments.createMap();
            res.putString("s", pend.devId);
            res.putInt("i", 1);
            res.putMap("value", parsed);
            pend.promise.resolve(res);
          } else {
            pend.promise.reject("FunSDK", String.valueOf(arg1));
          }
          return 0;
        }
      }

      if (what == EUIMSG.DEV_SET_JSON || what == EUIMSG.DEV_SET_CONFIG) {
        PendingOp pend = pendingSetPms.remove(seq);
        String data = null;
        if (ex != null) {
          if (ex.pData != null && ex.pData.length > 0) {
            data = new String(ex.pData, java.nio.charset.Charset.forName("UTF-8")).trim();
          } else if (ex.str != null) {
            data = ex.str.trim();
          }
        }
        String cleaned = sanitize(data);
        Log.e("ALARM", "OnFunSDKResult SET PMS seq=" + seq + ", arg1=" + arg1 + ", len=" + (cleaned != null ? cleaned.length() : -1));

        if (pend == null) {
          String name = extractNameFromJson(cleaned);
          if ("NetWork.PMS".equals(name) && !pendingSetPms.isEmpty()) {
            Integer anySeq = pendingSetPms.keySet().iterator().next();
            pend = pendingSetPms.remove(anySeq);
          }
        }

        if (pend != null) {
          if (arg1 >= 0) {
            WritableMap res = Arguments.createMap();
            res.putString("s", pend.devId);
            res.putInt("i", 1);
            WritableMap val = Arguments.createMap();
            val.putString("Name", "NetWork.PMS");
            try {
              WritableMap parsed = DataConverter.parseToWritableMap(cleaned);
              res.putMap("value", parsed);
            } catch (Throwable ignored) {
              res.putMap("value", val);
            }
            pend.promise.resolve(res);
          } else {
            pend.promise.reject("FunSDK", String.valueOf(arg1));
          }
          return 0;
        }
      }
    } catch (Throwable t) {
      // Swallow and continue
    }

    return 0;
  }

  // Note: Already implement IFunSDKResult.OnFunSDKResult below; remove duplicate override

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
