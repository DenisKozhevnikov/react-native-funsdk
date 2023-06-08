package com.funsdk.user.register;

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
  public void userCheck(ReadableMap params, Promise promise) { //Check that the username is valid
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME}, params)) {
      XMAccountManager.getInstance().checkUserName(
        params.getString(Constants.USERNAME),
        Constants.getResultCallback(promise)
      );
    }
  }

  /* Send CAPTchas to email */
  @ReactMethod
  public void emailCode(ReadableMap params, Promise promise) { //Send code by Email
    if (ReactParamsCheck.checkParams(new String[]{Constants.EMAIL}, params)) {
      XMAccountManager.getInstance().sendEmailCodeForRegister(
        params.getString(Constants.EMAIL),
        Constants.getResultCallback(promise)
      );
    }
  }

  /* Send the CAPTCHA to the user's phone */
  @ReactMethod
  public void phoneMsg(ReadableMap params, Promise promise) { //Send code by Email
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME, Constants.PHONE_NUMBER}, params)) {
      XMAccountManager.getInstance().sendPhoneCodeForRegister(
        params.getString(Constants.USERNAME),
        params.getString(Constants.EMAIL),
        Constants.getResultCallback(promise)
      );
    }
  }

  /* Register by phone number */
  @ReactMethod
  public void registerPhone(ReadableMap params, Promise promise) { //Mobile phone number registered
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME, Constants.PASSWORD, Constants.VERIFY_CODE, Constants.PHONE_NUMBER}, params)) {
      XMAccountManager.getInstance().registerByPhoneNo(
        params.getString(Constants.USERNAME),
        params.getString(Constants.PASSWORD),
        params.getString(Constants.VERIFY_CODE),
        params.getString(Constants.PHONE_NUMBER),
        Constants.getResultCallback(promise)
      );
    }
  }

  /* Register via email */
  @ReactMethod
  public void registerEmail(ReadableMap params, Promise promise) { //Email Registration
    if (ReactParamsCheck.checkParams(new String[]{Constants.USERNAME, Constants.PASSWORD, Constants.EMAIL, Constants.VERIFY_CODE}, params)) {
      XMAccountManager.getInstance().registerByEmail(
        params.getString(Constants.USERNAME),
        params.getString(Constants.PASSWORD),
        params.getString(Constants.EMAIL),
        params.getString(Constants.VERIFY_CODE),
        Constants.getResultCallback(promise)
      );
    }
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