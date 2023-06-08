package com.funsdk.user.modify;

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

public class FunSDKModifyModule extends ReactContextBaseJavaModule {
  public FunSDKModifyModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
      return "FunSDKModifyModule";
  }

  @ReactMethod
  public void checkPwd(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.PASSWORD}, params)) {
      XMAccountManager.getInstance().checkPwd(
        params.getString(Constants.PASSWORD),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void changePwd(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME, Constants.CURRENT_PASSWORD, Constants.NEW_PASSWORD}, params)) {
      XMAccountManager.getInstance().modifyPwd(
        params.getString(Constants.USERNAME),
        params.getString(Constants.CURRENT_PASSWORD),
        params.getString(Constants.NEW_PASSWORD),
        Constants.getResultCallback(promise)
      );
    }
  }
}