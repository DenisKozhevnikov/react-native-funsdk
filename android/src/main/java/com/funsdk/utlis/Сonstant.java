package com.funsdk.utils;

import com.facebook.react.bridge.Promise;
import com.manager.account.BaseAccountManager;


public class Сonstant {
  public static final String USERNAME = "username";
  public static final String PASSWORD = "password";

  public BaseAccountManager.OnAccountManagerListener getResultCallback(Promise promise) {
    return new BaseAccountManager.OnAccountManagerListener() {
      @Override
      public void onSuccess(int msgId) {
        promise.resolve(msgId);
      }
      
      @Override
      public void onFailed(int msgId, int errorId) {
        promise.reject(msgId + " " + errorId);
      }
      
      @Override
      public void onFunSDKResult(Message message, MsgContent msgContent) {
      }
    };
  }
}
