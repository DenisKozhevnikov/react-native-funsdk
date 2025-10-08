package com.funsdk.user.device.add.lan;

import android.content.Context;
import android.location.LocationManager;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import com.manager.device.DeviceManager;
import com.manager.db.XMDevInfo;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * LAN поиск устройств через высокоуровневый DeviceManager API (как в официальном демо)
 */
public class FunSDKDevLanConnectModule extends ReactContextBaseJavaModule implements DeviceManager.OnSearchLocalDevListener {
  private final ReactApplicationContext reactContext;
  private final Map<Integer, Promise> pending = new HashMap<>();
  private WifiManager.MulticastLock multicastLock;
  private int mSeq = 1;

  public FunSDKDevLanConnectModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    
    Log.d("LAN_ANDROID", "Init LAN module with DeviceManager API");
    
    WifiManager wifiManager = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    if (wifiManager != null) {
      multicastLock = wifiManager.createMulticastLock("FunSDK_LAN_Search");
    }
  }

  @Override
  public String getName() {
    return "FunSDKDevLanConnectModule";
  }

  private int nextSeq() {
    mSeq += 1;
    return mSeq;
  }

  
  private boolean checkLocationService() {
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP_MR1) {
      LocationManager locationManager = (LocationManager) reactContext.getSystemService(Context.LOCATION_SERVICE);
      return locationManager != null && locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
    } else {
      return true;
    }
  }

  @ReactMethod
  public void searchDevice(ReadableMap params, Promise promise) {
    if (!checkLocationService()) {
      promise.reject("LOCATION_DISABLED", "Геолокация отключена, включите GPS для LAN поиска");
      return;
    }
    final int timeout = (params != null && params.hasKey("timeout") && !params.isNull("timeout"))
        ? params.getInt("timeout")
        : 4000;
    
    final int seq = nextSeq();
    pending.put(seq, promise);

    Log.d("LAN_ANDROID", "Starting LAN device search with DeviceManager - timeout=" + timeout + ", seq=" + seq);

    if (multicastLock != null && !multicastLock.isHeld()) {
      try {
        multicastLock.acquire();
        Log.d("LAN_ANDROID", "Multicast lock acquired");
      } catch (Exception e) {
        Log.w("LAN_ANDROID", "Failed to acquire multicast lock: " + e.getMessage());
      }
    }

    // Фоллбек: если DeviceManager не вернёт результат, завершаем промис пустым массивом
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

    try {
      // Используем высокоуровневый API DeviceManager как в официальном демо
      DeviceManager.getInstance().searchLanDevice(this);
      Log.d("LAN_ANDROID", "DeviceManager.searchLanDevice() called");
    } catch (Throwable t) {
      Log.e("LAN_ANDROID", "Exception during device search: " + t.getMessage(), t);
      Promise p = pending.remove(seq);
      if (p != null) {
        p.reject("LAN_SEARCH_EXCEPTION", t.getMessage(), t);
      }
      releaseMulticastLock();
    }
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

  /**
   * Callback от DeviceManager.searchLanDevice() - высокоуровневый результат
   */
  @Override
  public void onSearchLocalDevResult(List<XMDevInfo> localDevList) {
    releaseMulticastLock();
    
    Log.d("LAN_ANDROID", "onSearchLocalDevResult: found " + (localDevList != null ? localDevList.size() : 0) + " devices");
    
    try {
      // Берём первый pending промис (в нашем случае всегда один активный поиск)
      Promise promise = null;
      Integer seq = null;
      for (Map.Entry<Integer, Promise> entry : pending.entrySet()) {
        promise = entry.getValue();
        seq = entry.getKey();
        break;
      }
      
      if (promise == null) {
        Log.w("LAN_ANDROID", "No pending promise found for search result");
        return;
      }
      
      pending.remove(seq);
      
      WritableArray arr = Arguments.createArray();
      if (localDevList != null && !localDevList.isEmpty()) {
        for (XMDevInfo devInfo : localDevList) {
          if (devInfo == null) continue;
          
          WritableMap m = Arguments.createMap();
          
          // Используем методы XMDevInfo для получения данных
          String devId = devInfo.getDevId();
          String deviceName = devInfo.getDevName();
          String deviceIp = devInfo.getDevIp();
          int port = devInfo.getDevPort();
          int deviceType = devInfo.getDevType();
          
          Log.d("LAN_ANDROID", "Device: id=" + devId + ", name=" + deviceName + 
                ", ip=" + deviceIp + ", port=" + port + ", type=" + deviceType);
          
          m.putString("devId", devId != null ? devId : "");
          m.putString("deviceName", deviceName != null ? deviceName : "");
          m.putString("deviceIp", deviceIp != null ? deviceIp : "");
          m.putInt("port", port);
          m.putInt("deviceType", deviceType);
          arr.pushMap(m);
        }
      }
      
      Log.d("LAN_ANDROID", "Resolving promise with " + arr.size() + " devices");
      promise.resolve(arr);
      
    } catch (Throwable t) {
      Log.e("LAN_ANDROID", "Exception in onSearchLocalDevResult: " + t.getMessage(), t);
      // Очищаем все pending промисы при ошибке
      for (Promise p : pending.values()) {
        if (p != null) {
          p.reject("SEARCH_DEVICE_EXCEPTION", t.getMessage(), t);
        }
      }
      pending.clear();
    }
  }
}