package com.funsdk.register;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;

import com.funsdk.utils.Constant.getResultCallback;
import com.funsdk.utils.Constant.USERNAME;
import com.funsdk.utils.Constant.PASSWORD;
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
    if (ReactParamsCheck.checkParams(arrayOf(USERNAME, PASSWORD), params)) {
      XMAccountManager.getInstance().register(
        params.getString(USERNAME),
        params.getString(PASSWORD),
        getResultCallback(promise)
      );
    }
  }
}