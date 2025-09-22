package com.funsdk.user.device.config;

import android.os.Message;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;

/**
 * Android-аналог iOS-модуля FunSDKDevConfigModule.
 * Обёртки над FunSDK для получения/сохранения конфигов и DevCmdGeneral.
 */
public class FunSDKDevConfigModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private int mUserId = 0;
  private boolean isRegistered = false;
  private int mSeq = 1;
  private final Map<Integer, Promise> pending = new HashMap<>();
  private Promise pendingCmdGeneral = null;

  public FunSDKDevConfigModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  @Override
  public String getName() {
    return "FunSDKDevConfigModule";
  }

  private int nextSeq() {
    mSeq += 1;
    return mSeq;
  }

  private void ensureUser() {
    if (!isRegistered) {
      mUserId = FunSDK.GetId(mUserId, this);
      isRegistered = true;
    }
  }

  // === Public RN API ===

  /**
   * Получение JSON-конфига с устройства (эквивалент iOS FUN_DevGetConfig_Json)
   * params: { deviceId, name, nOutBufLen, channel, timeout }
   */
  @ReactMethod
  public void getDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final int nOutBufLen = params.hasKey("nOutBufLen") ? params.getInt("nOutBufLen") : 0;
    final int channel = params.hasKey("channel") ? params.getInt("channel") : -1;
    final int timeout = params.hasKey("timeout") ? params.getInt("timeout") : 15000;

    final int seq = nextSeq();
    pending.put(seq, promise);

    // int DevGetConfigByJson(int userId, String devId, String cmd, int outLen, int chn, int timeout, int seq)
    FunSDK.DevGetConfigByJson(mUserId, devId, name, nOutBufLen, channel, timeout, seq);
  }

  /**
   * Сохранение JSON-конфига на устройство (эквивалент iOS FUN_DevSetConfig_Json)
   * params: { deviceId, name, param (json), channel, timeout }
   */
  @ReactMethod
  public void setDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final String json = params.getString("param");
    final int channel = params.hasKey("channel") ? params.getInt("channel") : -1;
    final int timeout = params.hasKey("timeout") ? params.getInt("timeout") : 15000;

    final int seq = nextSeq();
    pending.put(seq, promise);

    final String jsonStr = json != null ? json : "";
    // int DevSetConfigByJson(int userId, String devId, String cmd, String json, int chn, int timeout, int seq)
    FunSDK.DevSetConfigByJson(mUserId, devId, name, jsonStr, channel, timeout, seq);
  }

  /**
   * Универсальная команда к устройству (эквивалент iOS FUN_DevCmdGeneral)
   * params: { deviceId, cmdReq, cmd, isBinary, timeout, param, inParamLen, cmdRes }
   */
  @ReactMethod
  public void getDevCmdGeneral(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final int cmdReq = params.getInt("cmdReq");
    final String cmd = params.getString("cmd");
    final int isBinary = params.hasKey("isBinary") ? params.getInt("isBinary") : 0;
    final int timeout = params.hasKey("timeout") ? params.getInt("timeout") : 5000;
    final String param = params.hasKey("param") && !params.isNull("param") ? params.getString("param") : null;
    final int inParamLen = params.hasKey("inParamLen") ? params.getInt("inParamLen") : 0;
    final int cmdRes = params.hasKey("cmdRes") ? params.getInt("cmdRes") : -1;

    // В Android Java API DevCmdGeneral не принимает seq, поэтому храним одиночный promise
    pendingCmdGeneral = promise;

    byte[] inBytes = param != null ? param.getBytes(Charset.forName("UTF-8")) : null;
    // int DevCmdGeneral(int userId, String devId, int cmdType, String cmd, int isBinary, int timeout, byte[] inData, int inLen, int cmdRes)
    FunSDK.DevCmdGeneral(mUserId, devId, cmdReq, cmd, isBinary, timeout, inBytes, inParamLen, cmdRes);
  }

  // === IFunSDKResult ===

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2; // FunSDK обычно возвращает seq в arg2

    Promise promise = pending.remove(seq);

    try {
      if (what == EUIMSG.DEV_GET_JSON || what == EUIMSG.DEV_GET_CONFIG) {
        if (arg1 >= 0) {
          String data = ex != null && ex.pData != null ? new String(ex.pData, Charset.forName("UTF-8")).trim() : "";
          WritableMap map = Arguments.createMap();
          map.putString("data", data);
          if (promise != null) promise.resolve(map);
        } else {
          if (promise != null) promise.reject(String.valueOf(arg1), "DEV_GET_CONFIG failed");
        }
        return 0;
      }

      if (what == EUIMSG.DEV_SET_JSON || what == EUIMSG.DEV_SET_CONFIG) {
        if (arg1 >= 0) {
          WritableMap map = Arguments.createMap();
          map.putBoolean("success", true);
          if (promise != null) promise.resolve(map);
        } else {
          if (promise != null) promise.reject(String.valueOf(arg1), "DEV_SET_CONFIG failed");
        }
        return 0;
      }

      if (what == EUIMSG.DEV_CMD_EN) {
        if (arg1 >= 0) {
          String data = ex != null && ex.pData != null ? new String(ex.pData, Charset.forName("UTF-8")).trim() : "";
          WritableMap map = Arguments.createMap();
          map.putString("data", data);
          if (pendingCmdGeneral != null) {
            pendingCmdGeneral.resolve(map);
            pendingCmdGeneral = null;
          }
        } else {
          if (pendingCmdGeneral != null) {
            pendingCmdGeneral.reject(String.valueOf(arg1), "DEV_CMD_EN failed");
            pendingCmdGeneral = null;
          }
        }
        return 0;
      }
    } catch (Throwable t) {
      if (promise != null) {
        promise.reject("FunSDKDevConfigModule", t);
      } else if (pendingCmdGeneral != null) {
        pendingCmdGeneral.reject("FunSDKDevConfigModule", t);
        pendingCmdGeneral = null;
      }
    }

    return 0;
  }
}

