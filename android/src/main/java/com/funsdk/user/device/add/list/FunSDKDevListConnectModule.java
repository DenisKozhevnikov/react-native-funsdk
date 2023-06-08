package com.funsdk.user.device.add.list;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import java.util.Map;
import java.util.HashMap;
import java.io.File;

import android.util.Log;

import com.manager.account.AccountManager;

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
    // TODO кажется, тут что-то не так
    promise.resolve(AccountManager.getInstance().getDevList());
  }

  /**
   * get the device state
   */
  @ReactMethod
  public void getDevState(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.DEVICE_ID}, params)) {
      promise.resolve(AccountManager.getInstance().getDevState(params.getString(Constants.DEVICE_ID)));
    }
  }
}