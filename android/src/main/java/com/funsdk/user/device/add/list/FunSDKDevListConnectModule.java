package com.funsdk.user.device.add.list;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import java.util.Map;
import java.util.HashMap;
import java.io.File;

import android.util.Log;

import com.manager.account.AccountManager;
import com.manager.account.BaseAccountManager;
import com.manager.device.DeviceManager;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKDevListConnectModule extends ReactContextBaseJavaModule {
  public FunSDKDevListConnectModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKDevListConnectModule";
  }

  /**
   * get the device list
   */
  @ReactMethod
  public void getDevList(Promise promise) {
    try {
      WritableArray writableArray = new WritableNativeArray();

      for (String item : AccountManager.getInstance().getDevList()) {
        writableArray.pushString(item);
      }

      WritableMap writableMap = new WritableNativeMap();
      writableMap.putArray("deviceList", writableArray);

      promise.resolve(writableMap);
    } catch (Exception e) {
      promise.reject("CONVERSION_ERROR", e.getMessage());
    }
    // TODO кажется, тут что-то не так
    // promise.resolve(AccountManager.getInstance().getDevList());
  }

  /**
   * get the device state
   */
  @ReactMethod
  public void getDevState(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[] { Constants.DEVICE_ID }, params)) {
      promise.resolve(AccountManager.getInstance().getDevState(params.getString(Constants.DEVICE_ID)));
    }
  }

  @ReactMethod
  public void getDetailDeviceList(Promise promise) {
    try {
      WritableArray writableArray = new WritableNativeArray();

      for (String devId : AccountManager.getInstance().getDevList()) {
        XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);

        WritableMap writableMap = new WritableNativeMap();
        writableMap.putString("devId", devId);
        writableMap.putInt("devState", AccountManager.getInstance().getDevState(devId));
        writableMap.putString("devName", xmDevInfo.getDevName());
        writableMap.putString("devIp", xmDevInfo.getDevIp());
        writableMap.putInt("devPort", xmDevInfo.getDevPort());
        writableMap.putInt("devType", xmDevInfo.getDevType());
        writableMap.putString("devIpPort", xmDevInfo.getIpPort());
        // depreceated
        // writableMap.putString("devPid", xmDevInfo.getPid());
        // writableMap.putString("devMac", xmDevInfo.getMac());
        // writableMap.putString("devToken", xmDevInfo.getDevToken());

        writableArray.pushMap(writableMap);
      }

      promise.resolve(writableArray);
    } catch (Exception e) {
      promise.reject("CONVERSION_ERROR", e.getMessage());
    }
  }

  // @ReactMethod
  // public void loginDevice(ReadableMap params, Promise promise) {
  // // To reference the pop-up password input box below, if you don't want to
  // // participate in the pop-up dialog, you can follow the steps below:
  // // Step 1: Ask the user to enter the correct password. Once you have the
  // correct
  // // password, directly call FunSDK.DevSetLocalPwd(devId, userName, passWord),
  // // where devId is the device serial number, userName is the device login name
  // // (default is admin), and passWord is the correct password you want to pass.
  // // Step 2: Call presenter.loginDev() again.
  // try {
  // DeviceManager.getInstance().loginDev(params.getString(Constants.DEVICE_ID),
  // params.getString(Constants.DEVICE_LOGIN),
  // params.getString(Constants.DEVICE_PASSWORD),
  // new DeviceManager.OnDevManagerListener() {
  // @Override
  // public void onSuccess(String s, int i, Object abilityKey) {
  // promise.resolve("success");

  // }

  // @Override
  // public void onFailed(String s, int i, String s1, int errorId) {
  // // promise.reject("failed");
  // promise.reject(s + " " + i + " " + s1 + " " + errorId);
  // }
  // });

  // } catch (Exception e) {
  // promise.reject("CONVERSION_ERROR", e.getMessage());
  // }
  // }

  @ReactMethod
  public void updateAllDevStateFromServer(Promise promise) {
    AccountManager.getInstance().updateAllDevStateFromServer(AccountManager.getInstance().getDevList(),
        getResultUpdateDevStateCallback(promise));
  }

  public static BaseAccountManager.OnDevStateListener getResultUpdateDevStateCallback(Promise promise) {
    return new BaseAccountManager.OnDevStateListener() {
      @Override
      public void onUpdateDevState(String devId) {
        // Single device status callback
      }

      @Override
      public void onUpdateCompleted() {
        // Get the end callback of all device status
        promise.resolve("updated");
      }

    };
  }

}