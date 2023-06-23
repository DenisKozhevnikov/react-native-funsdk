package com.funsdk.user.info;

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
import com.manager.db.DevDataCenter;
import com.manager.db.XMUserInfo;
import static com.manager.db.Define.LOGIN_BY_INTERNET;
import com.utils.PathUtils;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKInfoModule extends ReactContextBaseJavaModule {
  public FunSDKInfoModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKInfoModule";
  }

  @ReactMethod
  public void logout() {
    XMAccountManager.getInstance().logout();
  }

  @ReactMethod
  public void hasLogin(Promise promise) {
    boolean isLogin = XMAccountManager.getInstance().hasLogin();

    promise.resolve(isLogin);
  }

  @ReactMethod
  public void getUserId(Promise promise) {
    XMUserInfo xmUserInfo = XMAccountManager.getInstance().getXmUserInfo();

    String result = xmUserInfo == null ? "" : xmUserInfo.getUserId();
    promise.resolve(result);
  }

  @ReactMethod
  public void getUserName(Promise promise) {
    XMUserInfo xmUserInfo = XMAccountManager.getInstance().getXmUserInfo();

    String result = xmUserInfo == null ? "" : xmUserInfo.getUserName();
    promise.resolve(result);
  }

  @ReactMethod
  public void getEmail(Promise promise) {
    XMUserInfo xmUserInfo = XMAccountManager.getInstance().getXmUserInfo();

    String result = xmUserInfo == null ? "" : xmUserInfo.getEmail();
    promise.resolve(result);
  }

  @ReactMethod
  public void getPhoneNo(Promise promise) {
    XMUserInfo xmUserInfo = XMAccountManager.getInstance().getXmUserInfo();

    String result = xmUserInfo == null ? "" : xmUserInfo.getPhoneNo();
    promise.resolve(result);
  }
}