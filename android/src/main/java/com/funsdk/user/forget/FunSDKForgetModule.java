package com.funsdk.user.forget;

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

public class FunSDKForgetModule extends ReactContextBaseJavaModule {
  public FunSDKForgetModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
      return "FunSDKForgetModule";
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
  public void requestSendEmailCodeForResetPW(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.EMAIL}, params)) {
      XMAccountManager.getInstance().sendEmailCodeForResetPwd(
        params.getString(Constants.EMAIL),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void requestSendPhoneMsgForResetPW(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.PHONE_NUMBER}, params)) {
      XMAccountManager.getInstance().sendPhoneCodeForResetPwd(
        params.getString(Constants.PHONE_NUMBER),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void requestVerifyEmailCode(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.EMAIL, Constants.VERIFY_CODE}, params)) {
      XMAccountManager.getInstance().verifyEmailCode(
        params.getString(Constants.EMAIL),
        params.getString(Constants.VERIFY_CODE),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void requestVerifyPhoneCode(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.PHONE_NUMBER, Constants.VERIFY_CODE}, params)) {
      XMAccountManager.getInstance().verifyPhoneCode(
        params.getString(Constants.PHONE_NUMBER),
        params.getString(Constants.VERIFY_CODE),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void requestResetPasswByEmail(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.EMAIL, Constants.NEW_PASSWORD}, params)) {
      XMAccountManager.getInstance().resetPwdByEmail(
        params.getString(Constants.EMAIL),
        params.getString(Constants.NEW_PASSWORD),
        Constants.getResultCallback(promise)
      );
    }
  }

  @ReactMethod
  public void requestResetPasswByPhone(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(new String[]{Constants.PHONE_NUMBER, Constants.NEW_PASSWORD}, params)) {
      XMAccountManager.getInstance().resetPwdByPhone(
        params.getString(Constants.PHONE_NUMBER),
        params.getString(Constants.NEW_PASSWORD),
        Constants.getResultCallback(promise)
      );
    }
  }
}