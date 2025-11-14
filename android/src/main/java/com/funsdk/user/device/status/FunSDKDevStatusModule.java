package com.funsdk.user.device.status;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Callback;

import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
import com.manager.device.config.DevConfigManager;
import com.manager.device.config.DevConfigInfo;
import com.manager.account.AccountManager;
import com.manager.account.BaseAccountManager;
import com.manager.XMFunSDKManager;
import com.utils.SignatureUtil;
import com.utils.TimeMillisUtil;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;
import com.lib.SDKCONST;
import com.lib.sdk.bean.PtzCtrlInfoBean;
import com.lib.sdk.bean.JsonConfig;
import com.lib.sdk.bean.HandleConfigData;
import com.lib.sdk.bean.SystemInfoBean;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.lib.sdk.struct.SDK_ChannelNameConfigAll;
import static com.lib.EFUN_ATTR.LOGIN_USER_ID;

import com.funsdk.utils.DataConverter;

import java.util.HashMap;
import java.util.Map;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

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

  // SDK 5.0.7: Обновлено для поддержки P2P
  @ReactMethod
  public void loginDevice(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      final String devId = params.getString(Constants.DEVICE_ID);
      android.util.Log.e("DEV_STATUS_ANDROID", "loginDevice: devId=" + devId);

      // Дополнительное логирование состояния DevDataCenter/XMDevInfo перед loginDev
      try {
        DevDataCenter devDataCenter = DevDataCenter.getInstance();
        int loginType = devDataCenter != null ? devDataCenter.getLoginType() : -1;
        XMDevInfo xmDevInfo = devDataCenter != null ? devDataCenter.getDevInfo(devId) : null;

        if (xmDevInfo != null) {
          SDBDeviceInfo sdbInfo = xmDevInfo.getSdbDevInfo();
          String userName = xmDevInfo.getDevUserName();
          String pwd = xmDevInfo.getDevPassword();
          String token = xmDevInfo.getDevToken();
          int connectType = (sdbInfo != null) ? sdbInfo.connectType : -1;

          android.util.Log.e(
              "DEV_STATUS_ANDROID",
              "loginDevice XMDevInfo: loginType=" + loginType +
                  ", devUserName=" + userName +
                  ", devPwdLen=" + (pwd != null ? pwd.length() : -1) +
                  ", devToken=" + token +
                  ", connectType=" + connectType);
        } else {
          android.util.Log.e(
              "DEV_STATUS_ANDROID",
              "loginDevice XMDevInfo is null for devId=" + devId + ", loginType=" + loginType);
        }
      } catch (Throwable t) {
        android.util.Log.e("DEV_STATUS_ANDROID", "loginDevice: error logging XMDevInfo: " + t.getMessage());
      }

      DeviceManager.getInstance().loginDev(devId, getResultCallback(promise));
    }
  }

    @ReactMethod
  public void loginDeviceWithCredential(ReadableMap params, Promise promise) {
    if (ReactParamsCheck
        .checkParams(new String[] { Constants.DEVICE_ID, Constants.DEVICE_LOGIN, Constants.DEVICE_PASSWORD }, params)) {
      final String devId = params.getString(Constants.DEVICE_ID);
      final String devUser = params.getString(Constants.DEVICE_LOGIN);
      final String devPwd = params.getString(Constants.DEVICE_PASSWORD);

      // Жёсткая валидация, чтобы не падать внутри DeviceManager
      if (devId == null || devId.trim().isEmpty()) {
        promise.reject("FunSDK", "DeviceId is empty");
        return;
      }
      if (devUser == null || devUser.trim().isEmpty()) {
        promise.reject("FunSDK", "Device login is empty");
        return;
      }
      if (devPwd == null || devPwd.trim().isEmpty()) {
        promise.reject("FunSDK", "Device password is empty");
        return;
      }

      try {
        // Определяем, есть ли активный вход по аккаунту и кэш устройства в DevDataCenter
        DevDataCenter devDataCenter = DevDataCenter.getInstance();
        XMDevInfo xmDevInfo = devDataCenter.getDevInfo(devId);
        boolean hasAccountLogin = devDataCenter.getLoginType() != com.manager.db.Define.LOGIN_NONE;
        final boolean useCachedLogin = hasAccountLogin && xmDevInfo != null;

        if (!useCachedLogin) {
          // Локальный SN‑сценарий: сбрасываем состояние и задаём пароль через DevSetLocalPwd
          DeviceManager.getInstance().logoutDev(devId);

          int pwdResult = FunSDK.DevSetLocalPwd(devId, devUser, devPwd);
          android.util.Log.e("DEV_STATUS_ANDROID", "DevSetLocalPwd: devId=" + devId + ", user=" + devUser + ", result=" + pwdResult);

          try {
            Thread.sleep(500);
          } catch (InterruptedException e) {
            // Игнорируем прерывание
          }
        } else {
          android.util.Log.e("DEV_STATUS_ANDROID", "loginDeviceWithCredential: use cached DevDataCenter login info for devId=" + devId + "; hasAccountLogin=" + hasAccountLogin);
        }

        // Логируем тип подключения до логина, если он уже известен
        if (xmDevInfo != null && xmDevInfo.getSdbDevInfo() != null) {
          android.util.Log.e("DEV_STATUS_ANDROID", "Device connection type before login: " + xmDevInfo.getSdbDevInfo().connectType);
        }

        // Универсальный listener для loginDev (с явными кредами или без, как в демо)
        DeviceManager.OnDevManagerListener listener = new DeviceManager.OnDevManagerListener() {
          @Override
          public void onSuccess(String s, int i, Object result) {
            android.util.Log.e("DEV_STATUS_ANDROID", "loginDev SUCCESS: devId=" + s);
            resolveLoginWithSystemInfo(devId, promise);
          }

          @Override
          public void onFailed(String s, int i, String s1, int errorId) {
            android.util.Log.e("DEV_STATUS_ANDROID", "loginDev FAILED: devId=" + s + ", msgId=" + i + ", jsonName=" + s1 + ", errorId=" + errorId);

            // В демо для f920... login считается успешным, даже если SystemInfo сыпется с -11307.
            // Если ошибка относится к SystemInfo и код -11307, считаем логин успешным и
            // продолжаем через resolveLoginWithSystemInfo, а не роняем промис.
            if ("SystemInfo".equals(s1) && errorId == -11307) {
              android.util.Log.e("DEV_STATUS_ANDROID", "loginDev: treating SystemInfo -11307 as success fallback for devId=" + devId);
              resolveLoginWithSystemInfo(devId, promise);
              return;
            }

            // Все остальные ошибки по-прежнему считаем фатальными для логина
            promise.reject(String.valueOf(errorId), "Login failed: " + s1);
          }
        };

        // Пробуем авторизоваться
        if (useCachedLogin) {
          // Как в официальном демо: опираемся на данные DevDataCenter/аккаунта
          DeviceManager.getInstance().loginDev(devId, listener);
        } else {
          // Локальный SN‑сценарий: используем явные логин/пароль
          DeviceManager.getInstance().loginDev(devId, devUser, devPwd, listener);
        }
      } catch (Throwable t) {
        promise.reject("FunSDK", t);
      }
    }
  }



  private void resolveLoginWithSystemInfo(final String devId, final Promise promise) {
    try {
      final DeviceManager deviceManager = DeviceManager.getInstance();
      final DevConfigManager devConfigManager = deviceManager.getDevConfigManager(devId);
      if (devConfigManager == null) {
        android.util.Log.e("DEV_STATUS_ANDROID", "DevConfigManager is null for devId=" + devId);
        WritableMap value = buildBasicDeviceInfo(devId);
        WritableMap res = Arguments.createMap();
        res.putString("s", devId);
        res.putInt("i", 1);
        res.putMap("value", value);
        promise.resolve(res);
        return;
      }

      DevConfigInfo devConfigInfo = DevConfigInfo.create(new DeviceManager.OnDevManagerListener<String>() {
        @Override
        public void onSuccess(String devIdInner, int operationType, String result) {
          try {
            WritableMap value = buildSystemInfoValue(devId, result);
            WritableMap res = Arguments.createMap();
            res.putString("s", devId);
            res.putInt("i", 1);
            res.putMap("value", value);
            promise.resolve(res);
          } catch (Exception e) {
            android.util.Log.e("DEV_STATUS_ANDROID", "buildSystemInfoValue error: " + e.getMessage());
            WritableMap value = buildBasicDeviceInfo(devId);
            value.putBoolean("systemInfoParseError", true);
            WritableMap res = Arguments.createMap();
            res.putString("s", devId);
            res.putInt("i", 1);
            res.putMap("value", value);
            promise.resolve(res);
          }
        }

        @Override
        public void onFailed(String devIdInner, int msgId, String jsonName, int errorId) {
          android.util.Log.e("DEV_STATUS_ANDROID", "getDevConfig(SystemInfo) failed: devId=" + devIdInner + ", msgId=" + msgId + ", jsonName=" + jsonName + ", errorId=" + errorId);
          WritableMap value = buildBasicDeviceInfo(devId);
          value.putBoolean("systemInfoFailed", true);
          value.putInt("systemInfoError", errorId);
          if (jsonName != null) {
            value.putString("systemInfoName", jsonName);
          }
          WritableMap res = Arguments.createMap();
          res.putString("s", devId);
          res.putInt("i", 1);
          res.putMap("value", value);
          promise.resolve(res);
        }
      });

      devConfigInfo.setJsonName(JsonConfig.SYSTEM_INFO);
      devConfigInfo.setChnId(-1);
      devConfigManager.getDevConfig(devConfigInfo);
    } catch (Throwable t) {
      android.util.Log.e("DEV_STATUS_ANDROID", "resolveLoginWithSystemInfo exception: " + t.getMessage());
      WritableMap value = buildBasicDeviceInfo(devId);
      WritableMap res = Arguments.createMap();
      res.putString("s", devId);
      res.putInt("i", 1);
      res.putMap("value", value);
      promise.resolve(res);
    }
  }

  private WritableMap buildSystemInfoValue(String devId, String jsonResult) {
    WritableMap value = Arguments.createMap();

    XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);
    int networkMode = 2;
    if (xmDevInfo != null && xmDevInfo.getSdbDevInfo() != null) {
      networkMode = xmDevInfo.getSdbDevInfo().connectType;
    }

    value.putInt("networkMode", networkMode);
    value.putString("SerialNo", devId);
    if (xmDevInfo != null) {
      value.putInt("DeviceType", xmDevInfo.getDevType());
    }

    if (!TextUtils.isEmpty(jsonResult)) {
      HandleConfigData handle = new HandleConfigData();
      if (handle.getDataObj(jsonResult, SystemInfoBean.class)) {
        SystemInfoBean bean = (SystemInfoBean) handle.getObj();
        if (bean != null) {
          value.putString("HardWare", safeString(bean.getHardWare()));
          value.putString("HardWareVersion", safeString(bean.getHardWareVersion()));
          value.putString("SoftWareVersion", safeString(bean.getSoftWareVersion()));
          value.putString("BuildTime", safeString(bean.getBuildTime()));
          value.putInt("VideoInChannel", bean.getVideoInChannel());
          value.putInt("VideoOutChannel", bean.getVideoOutChannel());
          value.putInt("AlarmInChannel", bean.getAlarmInChannel());
          value.putInt("AlarmOutChannel", bean.getAlarmOutChannel());
          value.putInt("AudioInChannel", bean.getAudioInChannel());
          value.putInt("TalkInChannel", bean.getTalkInChannel());
          value.putInt("TalkOutChannel", bean.getTalkOutChannel());
          value.putInt("DigChannel", bean.getDigChannel());
          value.putInt("ExtraChannel", bean.getExtraChannel());
          value.putInt("CombineSwitch", bean.getCombineSwitch());
          value.putString("DeviceRunTime", safeString(bean.getDeviceRunTime()));
          value.putString("EncryptVersion", safeString(bean.getEncryptVersion()));
          value.putString("UpdataTime", safeString(bean.getUpdataTime()));
          value.putString("UpdataType", safeString(bean.getUpdataType()));
          value.putString("Pid", safeString(bean.getPid()));
        }
      }
    }

    return value;
  }

  private WritableMap buildBasicDeviceInfo(String devId) {
    WritableMap value = Arguments.createMap();
    XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);
    int networkMode = 2;
    if (xmDevInfo != null && xmDevInfo.getSdbDevInfo() != null) {
      networkMode = xmDevInfo.getSdbDevInfo().connectType;
    }
    value.putInt("networkMode", networkMode);
    value.putString("SerialNo", devId);
    if (xmDevInfo != null) {
      value.putInt("DeviceType", xmDevInfo.getDevType());
    }
    return value;
  }

  private String safeString(String s) {
    return s != null ? s : "";
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
      final String devId = params.getString(Constants.DEVICE_ID);

      DeviceManager.getInstance().getChannelInfo(
          devId,
          new DeviceManager.OnDevManagerListener<SDK_ChannelNameConfigAll>() {
            @Override
            public void onSuccess(String s, int operationType, SDK_ChannelNameConfigAll channelInfos) {
              // Формируем ответ в том же формате, что и getResultCallback, но с минимальными полями
              WritableMap map = Arguments.createMap();
              map.putString("s", s);
              map.putInt("i", operationType);

              if (channelInfos == null) {
                map.putNull("value");
              } else {
                WritableMap value = Arguments.createMap();
                value.putInt("nChnCount", channelInfos.nChnCount);
                map.putMap("value", value);
              }

              promise.resolve(map);
            }

            @Override
            public void onFailed(String s, int msgId, String jsonName, int errorId) {
              android.util.Log.e("DEV_STATUS_ANDROID",
                  "getChannelInfo FAILED: devId=" + s + ", msgId=" + msgId + ", jsonName=" + jsonName + ", errorId=" + errorId);

              // DSS fallback как в DevListConnectPresenter: попробовать FunSDK.GetDevChannelCount
              int count = FunSDK.GetDevChannelCount(s);
              if (count > 0) {
                android.util.Log.e("DEV_STATUS_ANDROID",
                    "getChannelInfo: using DSS fallback channel count=" + count + " for devId=" + s);

                // Синхронизируем канал в SDBDeviceInfo, как делает демо
                XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(s);
                if (xmDevInfo != null) {
                  SDBDeviceInfo sdbDeviceInfo = xmDevInfo.getSdbDevInfo();
                  if (sdbDeviceInfo != null) {
                    SDK_ChannelNameConfigAll channelNameConfigAll = new SDK_ChannelNameConfigAll();
                    channelNameConfigAll.nChnCount = count;
                    sdbDeviceInfo.setChannel(channelNameConfigAll);
                  }
                }

                WritableMap map = Arguments.createMap();
                map.putString("s", s);
                map.putInt("i", msgId);
                WritableMap value = Arguments.createMap();
                value.putInt("nChnCount", count);
                map.putMap("value", value);
                promise.resolve(map);
              } else {
                // Если DSS тоже не помог, честно пробрасываем ошибку
                promise.reject(s + ", " + msgId + ", " + jsonName + ", " + errorId);
              }
            }
          });
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

      if (devId == null || devId.trim().isEmpty()) {
        promise.reject("INVALID_DEV_ID", "devId cannot be empty");
        return;
      }

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
      // Выполним смену пароля через ModifyPassword (DevSetConfigByJson), как на iOS
      final String devId = params.getString(Constants.DEVICE_ID);
      final String userName = params.getString(Constants.DEVICE_LOGIN);
      final String oldPwd = params.getString(Constants.DEVICE_PASSWORD);
      final String newPwd = params.getString(Constants.DEVICE_NEW_PASSWORD);

      ensureUser();

      final int timeoutMs = 20000;
      final int seq = nextSeq();

      String json = buildModifyPasswordJson(userName, oldPwd, newPwd);

      PendingSet pend = new PendingSet(promise, devId, "ModifyPassword", timeoutMs);
      pendingSet.put(seq, pend);

      int ret = FunSDK.DevSetConfigByJson(mUserId, devId, "ModifyPassword", json, -1, timeoutMs, seq);
      if (ret < 0) {
        pendingSet.remove(seq);
        promise.reject("DevSetConfigByJson", String.valueOf(ret));
        return;
      }

      Runnable r = new Runnable() {
        @Override
        public void run() {
          PendingSet removed = pendingSet.remove(seq);
          if (removed != null && removed.promise != null) {
            removed.promise.reject("Timeout", "Timeout: ModifyPassword");
          }
        }
      };
      pendingSetTimeouts.put(seq, r);
      getMainHandler().postDelayed(r, timeoutMs);
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

  // === Для modifyDevicePassword ===

  private int mUserId = 0;
  private boolean isRegistered = false;
  private int mSeq = 1;
  private final Map<Integer, PendingSet> pendingSet = new HashMap<>();
  private final Map<Integer, Runnable> pendingSetTimeouts = new HashMap<>();
  private Handler mainHandler;

  private Handler getMainHandler() {
    if (mainHandler == null) {
      mainHandler = new Handler(Looper.getMainLooper());
    }
    return mainHandler;
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

  private static class PendingSet {
    final Promise promise;
    final String devId;
    final String name;
    final int timeoutMs;
    PendingSet(Promise promise, String devId, String name, int timeoutMs) {
      this.promise = promise;
      this.devId = devId;
      this.name = name;
      this.timeoutMs = timeoutMs;
    }
  }

  private static String bytesToHex(byte[] bytes) {
    StringBuilder sb = new StringBuilder(bytes.length * 2);
    for (byte b : bytes) {
      sb.append(String.format("%02x", b));
    }
    return sb.toString();
  }

  private static String md5_8(String s) {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      byte[] d = md.digest(s != null ? s.getBytes(StandardCharsets.UTF_8) : new byte[0]);
      String hex = bytesToHex(d);
      return hex.substring(0, Math.min(8, hex.length()));
    } catch (NoSuchAlgorithmException e) {
      return "";
    }
  }

  private static String buildModifyPasswordJson(String userName, String oldPwd, String newPwd) {
    String old8 = md5_8(oldPwd);
    String new8 = md5_8(newPwd);
    StringBuilder sb = new StringBuilder();
    sb.append('{')
      .append("\"Name\":\"ModifyPassword\",")
      .append("\"ModifyPassword\":{")
      .append("\"EncryptType\":\"MD5\",")
      .append("\"UserName\":\"").append(userName != null ? userName : "").append("\",")
      .append("\"PassWord\":\"").append(old8).append("\",")
      .append("\"NewPassWord\":\"").append(new8).append("\"")
      .append('}')
      .append('}');
    return sb.toString();
  }

  @Override
  public int OnFunSDKResult(android.os.Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;

    PendingSet pendSet = pendingSet.remove(seq);
    if (pendSet != null && what == EUIMSG.DEV_SET_CONFIG) {
      Runnable r = pendingSetTimeouts.remove(seq);
      if (r != null) getMainHandler().removeCallbacks(r);

      if (arg1 >= 0) {
        WritableMap res = Arguments.createMap();
        res.putString("s", pendSet.devId);
        res.putInt("i", 1);
        res.putNull("value");
        pendSet.promise.resolve(res);
      } else {
        pendSet.promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
      }
      return 0;
    }

    return 0;
  }
}