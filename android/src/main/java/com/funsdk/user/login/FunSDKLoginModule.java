package com.funsdk.user.login;

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
import com.manager.db.DevDataCenter;
import static com.manager.db.Define.LOGIN_BY_INTERNET;
import com.utils.PathUtils;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKLoginModule extends ReactContextBaseJavaModule {
  public FunSDKLoginModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKLoginModule";
  }

  /* account login */
  @ReactMethod
  public void loginByAccount(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[] { Constants.USERNAME, Constants.PASSWORD }, params)) {
      AccountManager.getInstance().xmLogin( // LOGIN_BY_INTERNET（1） Account login type
          params.getString(Constants.USERNAME),
          params.getString(Constants.PASSWORD),
          LOGIN_BY_INTERNET,
          Constants.getResultCallback(promise));
    }
  }

  /*
   * Log in locally. After logging in locally, the added device will be saved in
   * the private app directory of the mobile phone.
   */
  @ReactMethod
  public void loginByLocal(Promise promise) {
    // TODO
    // String dbPath = PathUtils.getAndroidPath(/* add here */) + File.separator +
    // "CSFile.db";
    // AccountManager.getInstance().localLogin(
    // dbPath,
    // Constants.getResultCallback(promise)
    // );
  }

  /* AP Log in */
  @ReactMethod
  public void loginByAP(Promise promise) {
    // TODO
    // AccountManager.getInstance().localLogin(
    // /* add here */,
    // Constants.getResultCallback(promise)
    // );
  }

  @ReactMethod
  public void getDevCount(Promise promise) {
    promise.resolve(AccountManager.getInstance() != null ? AccountManager.getInstance().getDevList().size() : 0);
  }
}