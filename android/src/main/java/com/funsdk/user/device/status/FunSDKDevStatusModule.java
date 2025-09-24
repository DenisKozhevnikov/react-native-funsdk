package com.funsdk.user.device.status;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Callback;

import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
import com.manager.XMFunSDKManager;
import com.utils.SignatureUtil;
import com.utils.TimeMillisUtil;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;
import com.lib.sdk.bean.PtzCtrlInfoBean;
import com.lib.sdk.struct.SDBDeviceInfo;
import static com.lib.EFUN_ATTR.LOGIN_USER_ID;

import com.funsdk.utils.DataConverter;

import java.util.HashMap;
import java.util.Map;
import java.nio.charset.Charset;

// // To reference the pop-up password input box below, if you don't want to
// // participate in the pop-up dialog, you can follow the steps below:
// // Step 1: Ask the user to enter the correct password. Once you have the
// correct
// // password, directly call FunSDK.DevSetLocalPwd(devId, userName, passWord),
// // where devId is the device serial number, userName is the device login name
// // (default is admin), and passWord is the correct password you want to pass.
// // Step 2: Call presenter.loginDev() again.

public class FunSDKDevStatusModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  public FunSDKDevStatusModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKDevStatusModule";
  }

  // not tested
  @ReactMethod
  public void loginDevice(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DeviceManager.getInstance().loginDev(params.getString(Constants.DEVICE_ID), getResultCallback(promise));
    }
  }

  // works
  @ReactMethod
  public void loginDeviceWithCredential(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN, Constants.DEVICE_PASSWORD }, params)) {
      final String devId = params.getString(Constants.DEVICE_ID);
      final String devUser = params.getString(Constants.DEVICE_LOGIN);
      final String devPwd = params.getString(Constants.DEVICE_PASSWORD);

      // как на iOS: сохранить локальные креды и не вызывать фактический логин
      try {
        FunSDK.DevSetLocalPwd(devId, devUser, devPwd);
      } catch (Exception ignored) {
      }

      int networkMode = 0;
      try {
        XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);
        if (xmDevInfo != null) {
          SDBDeviceInfo sdb = xmDevInfo.getSdbDevInfo();
          if (sdb != null) {
            networkMode = sdb.connectType;
          }
        }
      } catch (Exception ignored) {
      }

      // Как на iOS: запрашиваем SystemInfo и резолвим этим ответом
      ensureUser();
      final int seq = nextSeq();
      android.util.Log.e("DEV_STATUS_ANDROID", "loginDeviceWithCredential: devId=" + devId + ", user=" + devUser + ", outLen=1024, ch=-1, timeout=15000, seq=" + seq);
      // Отменим предыдущие ожидания SystemInfo, чтобы fallback не схватывал старый seq
      try {
        java.util.ArrayList<Integer> toRemove = new java.util.ArrayList<>();
        for (java.util.Map.Entry<Integer, PendingLogin> e : pendingSystemInfo.entrySet()) {
          Integer oldSeq = e.getKey();
          PendingLogin oldPend = e.getValue();
          if (oldPend != null && oldPend.promise != null) {
            try { oldPend.promise.reject("Cancelled", "Superseded by newer loginDeviceWithCredential"); } catch (Throwable ignored) {}
          }
          toRemove.add(oldSeq);
        }
        for (Integer k : toRemove) pendingSystemInfo.remove(k);
      } catch (Throwable ignored) {}
      pendingSystemInfo.put(seq, new PendingLogin(promise, devId, networkMode));
      int ret = FunSDK.DevGetConfigByJson(mUserId, devId, "SystemInfo", 4096, -1, 15000, seq);
      android.util.Log.e("DEV_STATUS_ANDROID", "DevGetConfigByJson(SystemInfo) returned ret=" + ret);
      if (ret < 0) {
        PendingLogin removed = pendingSystemInfo.remove(seq);
        if (removed != null && removed.promise != null) {
          removed.promise.reject(String.valueOf(ret), "SystemInfo immediate error");
        }
        return;
      }
    }
  }

  // not tested
  // @ReactMethod
  // public void loginDeviceByLowPower(ReadableMap params, Promise promise) {
  // if (ReactParamsCheck
  // .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
  // DeviceManager.getInstance().loginDevByLowPower(params.getString(Constants.DEVICE_ID),
  // getResultCallback(promise));
  // }
  // }

  // not tested
  // @ReactMethod
  // public void loginDeviceByLowPowerWithCredential(ReadableMap params, Promise
  // promise) {
  // if (ReactParamsCheck
  // .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN,
  // Constants.DEVICE_PASSWORD }, params)) {
  // DeviceManager.getInstance().loginDevByLowPower(
  // params.getString(Constants.DEVICE_ID),
  // params.getString(Constants.DEVICE_LOGIN),
  // params.getString(Constants.DEVICE_PASSWORD),
  // getResultCallback(promise));
  // }
  // }

  // not tested
  // вероятно есть проблемы с невозвратом промиса
  // @ReactMethod
  // public void wakeUpAndSendCtrl(ReadableMap params, Promise promise) {
  // if (ReactParamsCheck
  // .checkParams(new String[] { Constants.DEVICE_ID, Constants.JSON_AS_STRING },
  // params)) {
  // DeviceManager.getInstance().wakeUpAndSendCtrl(
  // params.getString(Constants.DEVICE_ID),
  // params.getString(Constants.JSON_AS_STRING),
  // getResultCallback(promise));
  // }
  // }

  // not tested
  // отключение от подключенного устройства
  @ReactMethod
  public void logoutDevice(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DeviceManager.getInstance().logoutDev(
          params.getString(Constants.DEVICE_ID));
      promise.resolve("success");
    }
  }

  // not tested
  @ReactMethod
  public void getChannelInfo(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DeviceManager.getInstance().getChannelInfo(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getChannelCount(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {

      int count = DeviceManager.getInstance().getChannelCount(
          params.getString(Constants.DEVICE_ID));
      promise.resolve(count);
    }
  }

  // not tested
  // появился в 4.0
  @ReactMethod
  public void setLocalDeviceUserPassword(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN,
            Constants.DEVICE_PASSWORD }, params)) {
      String devId = params.getString(Constants.DEVICE_ID);
      String devUser = params.getString(Constants.DEVICE_LOGIN);
      String pwd = params.getString(Constants.DEVICE_PASSWORD);

      int iRet = FunSDK.DevSetLocalPwd(devId,
          devUser,
          pwd);
      if (iRet >= 0) {
        XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);
        if (xmDevInfo != null) {
          xmDevInfo.setDevUserName(devUser);
          // setDevPassword - отсутствует в 2.4 версии (есть в 4.0)
          xmDevInfo.setDevPassword(pwd);
        }
      }
      promise.resolve("success");
    }
  }

  // not tested
  // появился в 4.0
  @ReactMethod
  public void setLocalLoginInfo(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(
            new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN,
                Constants.DEVICE_PASSWORD, Constants.TOKEN },
            params)) {
      DeviceManager.getInstance().setLocalDevLoginInfo(
          params.getString(Constants.DEVICE_ID),
          params.getString(Constants.DEVICE_LOGIN),
          params.getString(Constants.DEVICE_PASSWORD),
          params.getString(Constants.TOKEN));
      promise.resolve("success");
    }
  }

  // not tested
  @ReactMethod
  public void modifyDevicePassword(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN, Constants.DEVICE_PASSWORD,
            Constants.DEVICE_NEW_PASSWORD }, params)) {
      DeviceManager.getInstance().modifyDevPwd(
          params.getString(Constants.DEVICE_ID),
          params.getString(Constants.DEVICE_LOGIN),
          params.getString(Constants.DEVICE_PASSWORD),
          params.getString(Constants.DEVICE_NEW_PASSWORD),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void modifyDeviceName(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_NAME }, params)) {
      DeviceManager.getInstance().modifyDevName(
          params.getString(Constants.DEVICE_ID),
          params.getString(Constants.DEVICE_NAME),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void devicePTZControl(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(
            new String[] { Constants.DEVICE_ID, Constants.COMMAND, Constants.B_STOP, Constants.DEVICE_CHANNEL,
                Constants.SPEED },
            params)) {

      String deviceId = params.getString(Constants.DEVICE_ID);
      int nPTZCommand = params.getInt(Constants.COMMAND);
      boolean bStop = params.getBoolean(Constants.B_STOP);
      int channelId = params.getInt(Constants.DEVICE_CHANNEL);
      int speed = params.getInt(Constants.SPEED);

      PtzCtrlInfoBean ptzCtrlInfoBean = new PtzCtrlInfoBean();
      ptzCtrlInfoBean.setDevId(deviceId);
      ptzCtrlInfoBean.setPtzCommandId(nPTZCommand);
      ptzCtrlInfoBean.setStop(bStop);
      ptzCtrlInfoBean.setChnId(channelId);
      ptzCtrlInfoBean.setSpeed(speed);
      System.out.println("devicePTZControl: ");
      boolean result = DeviceManager.getInstance().devPTZControl(ptzCtrlInfoBean, getResultCallback(promise));

      System.out.println("devicePTZControl: " + result);

      // promise.resolve(result);
    }
  }

  // not tested
  @ReactMethod
  public void resetDeviceConfig(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_NAME }, params)) {
      DeviceManager.getInstance().resetDevConfig(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // можно также добавить методы обновления устройства
  // checkDevUpgrade
  // startDevUpgrade
  // startDevUpgradeByLocalFile
  // switchDevNetworkMode

  // not tested
  @ReactMethod
  public void rebootDevice(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DeviceManager.getInstance().rebootDev(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void captureFromDeviceAndSaveToDevice(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_CHANNEL }, params)) {
      DeviceManager.getInstance().captureFromDevAndSaveToDev(
          params.getString(Constants.DEVICE_ID),
          params.getInt(Constants.DEVICE_CHANNEL),
          getResultCallback(promise));
    }
  }

  // получает информацию о доступности какой-то функциональности устройства
  // not tested
  @ReactMethod
  public void isDeviceFunctionSupport(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getSystemFunctionItemValue(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise),
          params.getString(Constants.FUNCTION_NAME),
          params.getString(Constants.FUNCTION_COMMAND_STR));
    }
  }

  // not tested
  @ReactMethod
  public void getDeviceModel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getDeviceModel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getSoftWareVersion(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getSoftWareVersion(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getBuildTime(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getBuildTime(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getHardWare(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getHardWare(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getDigChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getDigChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getExtraChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getExtraChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getVideoInChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getVideoInChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getTalkInChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getTalkInChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getAlarmInChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getAlarmInChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getAlarmOutChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getAlarmOutChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getCombineSwitch(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getCombineSwitch(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getVideoOutChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getVideoOutChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getAudioInChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getAudioInChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getTalkOutChannel(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getTalkOutChannel(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getUpdataTime(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getUpdataTime(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getEncryptVersion(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getEncryptVersion(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getDeviceRunTime(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getDeviceRunTime(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getHardWareVersion(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getHardWareVersion(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getMcuVersion(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      DevDataCenter.getInstance().getMcuVersion(
          params.getString(Constants.DEVICE_ID),
          getResultCallback(promise));
    }
  }

  // not tested
  @ReactMethod
  public void getNetworkMode(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      XMDevInfo devInfo = DevDataCenter.getInstance().getDevInfo(params.getString(Constants.DEVICE_ID));
      SDBDeviceInfo sbdInfo = devInfo.getSdbDevInfo();

      // 0:p2p连接，1转发模式 2:IP地址直连
      int connectType = sbdInfo.connectType;

      WritableMap map = Arguments.createMap();
      map.putInt("value", (Integer) connectType);
      promise.resolve(map);
    }
  }

  // Получение токена для авторизации
  @ReactMethod
  public void getAccessToken(Promise promise) {
    promise.resolve(DevDataCenter.getInstance().getAccessToken());
  }

  // Получение строки secret или signature или sign для запросов
  @ReactMethod
  public void getSecret(Promise promise) {
    if (DevDataCenter.getInstance().isLoginByAccount()) {
      String timeMillis = TimeMillisUtil.getTimMillis();

      String uuid = XMFunSDKManager.getInstance().getAppUuid();
      String appKey = XMFunSDKManager.getInstance().getAppKey();
      String appSecret = XMFunSDKManager.getInstance().getAppSecret();
      int movedCard = XMFunSDKManager.getInstance().getAppMovecard();

      try {
        String secret = SignatureUtil.getEncryptStr(uuid,
            appKey,
            appSecret,
            timeMillis,
            movedCard);

        WritableMap map = Arguments.createMap();
        map.putString("timeMillis", timeMillis);
        map.putString("secret", secret);
        map.putString("uuid", uuid);
        map.putString("appKey", appKey);
        map.putString("appSecret", appSecret);
        map.putInt("movedCard", movedCard);

        promise.resolve(map);
      } catch (Exception e) {
        e.printStackTrace();
        promise.reject("signError");
      }
    } else {
      promise.reject("loginError");
    }
  }

  @ReactMethod
  public void getFunStrAttr(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.FUN_STR_ATTR }, params)) {
      int FunStrAttr = params.getInt(Constants.FUN_STR_ATTR);

      String result = FunSDK.GetFunStrAttr(FunStrAttr);
      promise.resolve(result);
    }
  }

  @ReactMethod
  public void devGetLocalUserName(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      String loginName = FunSDK.DevGetLocalUserName(params.getString(Constants.DEVICE_ID));

      promise.resolve(loginName);
    }
  }

  @ReactMethod
  public void getDevType(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      int devType = DevDataCenter.getInstance().getDevType(params.getString(Constants.DEVICE_ID));

      promise.resolve(devType);
    }
  }

  @ReactMethod
  public void devGetLocalEncToken(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      String devToken = FunSDK.DevGetLocalEncToken(params.getString(Constants.DEVICE_ID));

      promise.resolve(devToken);
    }
  }

  public static DeviceManager.OnDevManagerListener getResultCallback(Promise promise) {
    return new DeviceManager.OnDevManagerListener() {

      public void onSuccess(String s, int i, Object abilityKey) {
        WritableMap map = Arguments.createMap();
        map.putString("s", s);
        map.putInt("i", i);

        if (abilityKey == null) {
          map.putNull("value");
        } else if (abilityKey instanceof String) {
          map.putString("value", (String) abilityKey);
        } else if (abilityKey instanceof Boolean) {
          map.putBoolean("value", (Boolean) abilityKey);
        } else if (abilityKey instanceof Integer) {
          map.putInt("value", (Integer) abilityKey);
        } else if (abilityKey instanceof Double) {
          map.putDouble("value", (Double) abilityKey);
        } else if (abilityKey instanceof Long) {
          map.putDouble("value", (Long) abilityKey);
        } else {
          com.facebook.react.bridge.WritableMap valueMap = DataConverter.parseToWritableMap(abilityKey);
          try {
            if (valueMap != null && valueMap.hasKey("st_channelTitle")) {
              com.facebook.react.bridge.ReadableArray titles = valueMap.getArray("st_channelTitle");
              if (titles != null) {
                int limit = titles.size();
                if (valueMap.hasKey("nChnCount")) {
                  try {
                    int n = valueMap.getInt("nChnCount");
                    if (n >= 0) {
                      limit = Math.min(limit, n);
                    }
                  } catch (Exception ignored) {
                  }
                }
                com.facebook.react.bridge.WritableArray decoded = com.facebook.react.bridge.Arguments.createArray();
                for (int idx = 0; idx < limit; idx++) {
                  String raw = titles.getString(idx);
                  String decodedStr = raw != null ? raw : "";
                  try {
                    if (raw != null) {
                      byte[] bytes = android.util.Base64.decode(raw, android.util.Base64.DEFAULT);
                      decodedStr = new String(bytes, java.nio.charset.StandardCharsets.UTF_8).replace("\u0000", "");
                    }
                  } catch (Exception ignored) {
                    // Keep original string if decoding fails
                  }
                  decoded.pushString(decodedStr);
                }
                valueMap.putArray("st_channelTitle", decoded);
              }
            }
          } catch (Exception ignored) {
          }
          map.putMap("value", valueMap);
        }

        promise.resolve(map);
      }

      public void onFailed(String s, int i, String s1, int errorId) {
        promise.reject(s + ", " + i + ", " + s1 + ", " + errorId);
      }
    };
  }

  // === Прямой запрос SystemInfo для loginDeviceWithCredential ===

  private int mUserId = 0;
  private boolean isRegistered = false;
  private int mSeq = 1;
  private final Map<Integer, PendingLogin> pendingSystemInfo = new HashMap<>();

  private static class PendingLogin {
    final Promise promise;
    final String devId;
    final int networkMode;
    PendingLogin(Promise promise, String devId, int networkMode) {
      this.promise = promise;
      this.devId = devId;
      this.networkMode = networkMode;
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

  @Override
  public int OnFunSDKResult(android.os.Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;

    PendingLogin pend = pendingSystemInfo.remove(seq);

    if (what == EUIMSG.DEV_GET_JSON || what == EUIMSG.DEV_GET_CONFIG) {
      android.util.Log.e("DEV_STATUS_ANDROID", "OnFunSDKResult: what=" + what + ", arg1=" + arg1 + ", seq=" + seq + ", ex.strLen=" + (ex != null && ex.str != null ? ex.str.length() : -1) + ", pDataLen=" + (ex != null && ex.pData != null ? ex.pData.length : -1));
      if (pend == null) {
        Integer matchedSeq = null;
        PendingLogin matched = null;
        for (java.util.Map.Entry<Integer, PendingLogin> e : pendingSystemInfo.entrySet()) {
          if (matchedSeq == null || e.getKey() > matchedSeq) {
            matchedSeq = e.getKey();
            matched = e.getValue();
          }
        }
        if (matched != null) {
          // Снимем таймаут с подобранного запроса
          pendingSystemInfo.remove(matchedSeq);
          pend = matched;
          android.util.Log.e("DEV_STATUS_ANDROID", "OnFunSDKResult: fallback matched pending by name SystemInfo, matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
        } else {
          android.util.Log.e("DEV_STATUS_ANDROID", "OnFunSDKResult: no pending for seq=" + seq + ", ignoring");
          return 0;
        }
      }
      try {
        if (arg1 >= 0) {
          String data = null;
          if (ex != null) {
            if (ex.pData != null && ex.pData.length > 0) {
              data = new String(ex.pData, Charset.forName("UTF-8")).trim();
            } else if (ex.str != null) {
              data = ex.str.trim();
            }
          }
          android.util.Log.e("DEV_STATUS_ANDROID", "SystemInfo raw len=" + (data != null ? data.length() : -1));
          if (data == null || data.isEmpty()) {
            pend.promise.reject("EMPTY", "SystemInfo empty");
            return 0;
          }
          // Возвращаем плоский объект SystemInfo, как на iOS
          com.facebook.react.bridge.WritableMap parsedAll = DataConverter.parseToWritableMap(data);
          com.facebook.react.bridge.ReadableMap value = parsedAll;
          try {
            if (parsedAll != null && parsedAll.hasKey("SystemInfo")) {
              com.facebook.react.bridge.ReadableMap nested = parsedAll.getMap("SystemInfo");
              if (nested != null) {
                value = nested; // отдать вложенный объект как есть (как на iOS)
              }
            }
          } catch (Throwable ignored) {}

          WritableMap res = Arguments.createMap();
          res.putString("s", pend.devId);
          res.putInt("i", 1);
          res.putMap("value", value);
          pend.promise.resolve(res);
          android.util.Log.e("DEV_STATUS_ANDROID", "SystemInfo RESOLVED for devId=" + pend.devId + ", seq=" + seq);
        } else {
          pend.promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
          android.util.Log.e("DEV_STATUS_ANDROID", "SystemInfo REJECT what=" + what + " arg1=" + arg1 + " seq=" + seq);
        }
      } catch (Throwable t) {
        pend.promise.reject("FunSDKDevStatusModule", t);
      }
      return 0;
    }

    return 0;
  }
}