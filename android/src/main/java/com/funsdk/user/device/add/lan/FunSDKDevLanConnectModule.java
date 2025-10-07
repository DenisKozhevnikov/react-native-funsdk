package com.funsdk.user.device.add.lan;

import android.os.Message;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.basic.G;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;

/**
 * LAN поиск устройств. Возвращает массив объектов с devId, deviceName, deviceIp, port, deviceType.
 */
public class FunSDKDevLanConnectModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private int mUserId = 0;
  private int mSeq = 1;
  private final Map<Integer, Promise> pending = new HashMap<>();

  public FunSDKDevLanConnectModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  @Override
  public String getName() {
    return "FunSDKDevLanConnectModule";
  }

  private int nextSeq() {
    mSeq += 1;
    return mSeq;
  }

  private void ensureUser() {
    if (mUserId == 0) {
      mUserId = FunSDK.GetId(mUserId, this);
    }
  }

  @ReactMethod
  public void searchDevice(ReadableMap params, Promise promise) {
    ensureUser();
    int timeout = 10000;
    if (params != null && params.hasKey("timeout") && !params.isNull("timeout")) {
      try { timeout = params.getInt("timeout"); } catch (Throwable ignored) {}
    }
    int seq = nextSeq();
    pending.put(seq, promise);

    // FunSDK Java обёртка для LAN-поиска: DevSearchDevices (сообщение EMSG_DEV_SEARCH_DEVICES)
    // В некоторых сборках доступен вызов FunSDK.DevSearchDevices(userId, timeout, seq)
    // Если его нет, можно fallback на H264_DVR_SearchDevice через низкоуровневый биндинг.
    try {
      Log.e("LAN_ANDROID", "Start LAN search, timeout=" + timeout + ", seq=" + seq);
      try {
        FunSDK.DevSearchDevice(mUserId, timeout, seq);
      } catch (Throwable t2) {
        throw t2;
      }
    } catch (Throwable t) {
      // Если в данной версии обёртка недоступна — немедленно фейлим, чтобы не зависало
      Promise p = pending.remove(seq);
      if (p != null) {
        p.reject("LAN_SEARCH_UNAVAILABLE", t);
      }
    }
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;
    Promise promise = pending.get(seq);

    if (what == EUIMSG.DEV_SEARCH_DEVICES) {
      try {
        if (promise == null) return 0;
        if (arg1 < 0) {
          pending.remove(seq);
          promise.reject("searchDevice_error", String.valueOf(arg1));
          return 0;
        }

        // ex.pData содержит поток байт массива SDBDeviceInfo (*count=arg1)
        int count = arg1;
        WritableArray arr = Arguments.createArray();
        if (ex != null && ex.pData != null && count > 0) {
          SDBDeviceInfo[] infos = new SDBDeviceInfo[count];
          G.BytesToObj(infos, ex.pData);
          for (int i = 0; i < infos.length; i++) {
            SDBDeviceInfo it = infos[i];
            if (it == null) continue;
            WritableMap m = Arguments.createMap();
            m.putString("devId", G.ToString(it.st_0_Devmac));
            m.putString("deviceName", G.ToString(it.st_1_Devname));
            m.putString("deviceIp", G.ToString(it.st_2_Devip));
            m.putString("port", String.valueOf(it.st_6_nDMZTcpPort));
            m.putString("deviceType", String.valueOf(it.st_7_nType));
            arr.pushMap(m);
          }
        }
        pending.remove(seq);
        promise.resolve(arr);
      } catch (Throwable t) {
        pending.remove(seq);
        if (promise != null) promise.reject("searchDevice_exception", t);
      }
      return 0;
    }

    return 0;
  }
}


