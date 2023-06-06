package com.funsdk.register;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;

import com.manager.account.XMAccountManager;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKRegisterModule extends ReactContextBaseJavaModule {
  public FunSDKRegisterModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
      return "FunSDKRegisterModule";
  }

  @ReactMethod
  public void registerByNotBind(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME, Constants.PASSWORD}, params)) {
      XMAccountManager.getInstance().register(
        params.getString(Constants.USERNAME),
        params.getString(Constants.PASSWORD),
        Constants.getResultCallback(promise)
      );
    }
  }
}