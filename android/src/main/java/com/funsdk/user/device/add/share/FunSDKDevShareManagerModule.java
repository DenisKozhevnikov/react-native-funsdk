package com.funsdk.user.device.add.share;

import android.content.Context;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

// Нет необходимости в использовании так как все запросы идут через https
// в библиотеке есть все запросы в ShareManagerServerInteraction
public class FunSDKDevShareManagerModule extends ReactContextBaseJavaModule {
  public ReactApplicationContext reactContext;
  public ShareManager shareManager;

  public FunSDKDevShareManagerModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  @Override
  public String getName() {
    return "FunSDKDevShareManagerModule";
  }

  public ShareManager getManager() {
    if (shareManager == null) {
      shareManager = ShareManager.getInstance((Context) reactContext);
      shareManager.init();
    }

    return shareManager;
  }

  @ReactMethod
  public void userQuery(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[] { "searchUserName" }, params)) {
      String searchUserName = params.getString("searchUserName");

      getManager().userQuery(searchUserName, promise);
    }
  }
}
