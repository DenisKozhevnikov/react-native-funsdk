package com.funsdk.user.device.add.ap;

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

import com.manager.account.XMAccountManager;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKDevApConnectModule extends ReactContextBaseJavaModule {
  public FunSDKDevApConnectModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
      return "FunSDKDevApConnectModule";
  }
}