package com.funsdk.user.device.add.lan;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
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
import com.facebook.react.bridge.UiThreadUtil;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.basic.G;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;


public class FunSDKDevLanConnectModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private int mUserId = 0;
  private int mSeq = 1;
  private final Map<Integer, Promise> pending = new HashMap<>();
  private WifiManager.MulticastLock multicastLock;

  public FunSDKDevLanConnectModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    
    // Не запрашиваем handle здесь (поток create_react_context без Looper)
    mUserId = 0;
    Log.d("LAN_ANDROID", "Init module, userId=" + mUserId);
    
    WifiManager wifiManager = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    if (wifiManager != null) {
      multicastLock = wifiManager.createMulticastLock("FunSDK_LAN_Search");
    }
  }

  @Override
  public void onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy();
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
    // Ничего не делаем здесь; получение userId только на UI-потоке в момент вызова
  }

  @ReactMethod
  public void searchDevice(ReadableMap params, Promise promise) {
    ensureUser();
    final int timeout = (params != null && params.hasKey("timeout") && !params.isNull("timeout"))
        ? params.getInt("timeout")
        : 4000; // как на iOS

    final int seq = nextSeq();
    pending.put(seq, promise);

    Log.d("LAN_ANDROID", "Starting LAN device search - timeout=" + timeout + ", seq=" + seq + ", userId=" + mUserId);

    if (multicastLock != null && !multicastLock.isHeld()) {
      try {
        multicastLock.acquire();
        Log.d("LAN_ANDROID", "Multicast lock acquired");
      } catch (Exception e) {
        Log.w("LAN_ANDROID", "Failed to acquire multicast lock: " + e.getMessage());
      }
    }

    // Фоллбек: если SDK не вернёт событие, завершаем промис пустым массивом
    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
      @Override
      public void run() {
        Promise p = pending.remove(seq);
        if (p != null) {
          Log.w("LAN_ANDROID", "LAN search timeout (" + timeout + " ms), resolving empty result");
          releaseMulticastLock();
          p.resolve(Arguments.createArray());
        }
      }
    }, timeout + 1000);

    // Все вызовы FunSDK выполняем на UI-потоке (требуется Looper)
    UiThreadUtil.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        try {
          if (mUserId == 0) {
            mUserId = FunSDK.GetId(0, FunSDKDevLanConnectModule.this);
            Log.d("LAN_ANDROID", "Got SDK handle on UI thread: " + mUserId);
          }

          int result = FunSDK.DevSearchDevice(mUserId, timeout, seq);
          Log.d("LAN_ANDROID", "DevSearchDevice called, result=" + result);

          if (result < 0) {
            Log.e("LAN_ANDROID", "Search device failed with result: " + result);
            Promise p = pending.remove(seq);
            if (p != null) {
              p.reject("SEARCH_FAILED", "Search returned error code: " + result);
            }
            releaseMulticastLock();
          }
        } catch (Throwable t) {
          Log.e("LAN_ANDROID", "Exception during device search: " + t.getMessage(), t);
          Promise p = pending.remove(seq);
          if (p != null) {
            p.reject("LAN_SEARCH_EXCEPTION", t.getMessage(), t);
          }
          releaseMulticastLock();
        }
      }
    });
  }
  
  @ReactMethod
  public void stopSearchDevice(Promise promise) {
    Log.d("LAN_ANDROID", "Stopping device search");
    
    try {
      releaseMulticastLock();
      
      for (Map.Entry<Integer, Promise> entry : pending.entrySet()) {
        Promise p = entry.getValue();
        if (p != null) {
          p.reject("SEARCH_CANCELLED", "Search was cancelled");
        }
      }
      pending.clear();
      
      promise.resolve(true);
      
    } catch (Exception e) {
      Log.e("LAN_ANDROID", "Error stopping search: " + e.getMessage(), e);
      promise.reject("STOP_SEARCH_ERROR", e.getMessage(), e);
    }
  }
  
  private void releaseMulticastLock() {
    if (multicastLock != null && multicastLock.isHeld()) {
      try {
        multicastLock.release();
        Log.d("LAN_ANDROID", "Multicast lock released");
      } catch (Exception e) {
        Log.w("LAN_ANDROID", "Failed to release multicast lock: " + e.getMessage());
      }
    }
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;
    Promise promise = pending.get(seq);

    Log.d("LAN_ANDROID", "OnFunSDKResult: what=" + what + ", arg1=" + arg1 + ", seq=" + seq + ", hasPromise=" + (promise != null));

    if (what == EUIMSG.DEV_SEARCH_DEVICES) {
      releaseMulticastLock();
      
      try {
        if (promise == null) {
          Log.w("LAN_ANDROID", "No promise found for seq=" + seq);
          return 0;
        }
        
        if (arg1 < 0) {
          Log.e("LAN_ANDROID", "Search failed with error code: " + arg1);
          pending.remove(seq);
          promise.reject("SEARCH_DEVICE_ERROR", "Search failed with error code: " + arg1);
          return 0;
        }

        int count = arg1;
        Log.d("LAN_ANDROID", "Found " + count + " devices");
        
        WritableArray arr = Arguments.createArray();
        if (ex != null && ex.pData != null && count > 0) {
          SDBDeviceInfo[] infos = new SDBDeviceInfo[count];
          G.BytesToObj(infos, ex.pData);
          
          for (int i = 0; i < infos.length; i++) {
            SDBDeviceInfo it = infos[i];
            if (it == null) {
              Log.w("LAN_ANDROID", "Device info at index " + i + " is null");
              continue;
            }
            
            WritableMap m = Arguments.createMap();
            String devId = G.ToString(it.st_0_Devmac);
            String deviceName = G.ToString(it.st_1_Devname);
            String deviceIp = G.ToString(it.st_2_Devip);
            int port = it.st_6_nDMZTcpPort;
            int deviceType = it.st_7_nType;

            Log.d("LAN_ANDROID", "Device " + i + ": id=" + devId + ", name=" + deviceName +
                  ", ip=" + deviceIp + ", port=" + port + ", type=" + deviceType);

            m.putString("devId", devId);
            m.putString("deviceName", deviceName);
            m.putString("deviceIp", deviceIp);
            m.putInt("port", port);
            m.putInt("deviceType", deviceType);
            arr.pushMap(m);
          }
        }
        
        Log.d("LAN_ANDROID", "Resolving promise with " + arr.size() + " devices");
        pending.remove(seq);
        promise.resolve(arr);
        
      } catch (Throwable t) {
        Log.e("LAN_ANDROID", "Exception in OnFunSDKResult: " + t.getMessage(), t);
        pending.remove(seq);
        if (promise != null) {
          promise.reject("SEARCH_DEVICE_EXCEPTION", t.getMessage(), t);
        }
      }
      return 0;
    }

    return 0;
  }
}


