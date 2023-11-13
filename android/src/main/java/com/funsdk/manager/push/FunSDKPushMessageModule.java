package com.funsdk.manager.push;

import android.os.Message;
import android.content.Context;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Arguments;

import com.basic.G;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.Mps.SMCInitInfo;
import com.utils.XUtils;

import com.manager.push.XMPushManager;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.account.XMAccountManager;

import com.funsdk.utils.Constants;

public class FunSDKPushMessageModule extends ReactContextBaseJavaModule implements XMPushManager.OnXMPushLinkListener {
  private ReactApplicationContext reactContext;
  private XMPushManager manager;
  private String devId = "";

  @Override
  public String getName() {
    return "FunSDKPushMessageModule";
  }

  public FunSDKPushMessageModule(ReactApplicationContext context) {
    super(context);
    reactContext = context;
    // manager = new XMPushManager(this);
  }

  // public XMPushManager getInstance() {
  // if (manager == null) {
  // manager = new XMPushManager(this);
  // }

  // return manager;
  // }

  @ReactMethod
  public void iniXMFunSDKPush() {

    String pushToken = XUtils.getPushToken((Context) reactContext);

    SMCInitInfo info = new SMCInitInfo();

    G.SetValue(info.st_0_user, XMAccountManager.getInstance().getAccountName());
    G.SetValue(info.st_1_password, XMAccountManager.getInstance().getPassword());
    G.SetValue(info.st_2_token, pushToken);

    manager.initFunSDKPush((Context) reactContext, info, 1);
  }

  @ReactMethod
  public void initGoogleFunSDKPush(ReadableMap params, Promise promise) {
    manager = new XMPushManager(this);

    String devId = params.getString(Constants.DEVICE_ID);
    String token = params.getString(Constants.TOKEN);
    int pushType = params.getInt("type");

    SMCInitInfo info = new SMCInitInfo();

    G.SetValue(info.st_0_user, XMAccountManager.getInstance().getAccountName());
    G.SetValue(info.st_1_password, XMAccountManager.getInstance().getPassword());
    G.SetValue(info.st_2_token, token);

    manager.initFunSDKPush((Context) reactContext, info, pushType);
    manager.linkAlarm(devId, 0);

    System.out.println("success init?");
  }

  public String getDevId() {
    return devId;
  }

  // protected XMPushManager getManager() {
  // return new XMPushManager(this);
  // }

  @ReactMethod
  public void isPushOpen() {// The server gets whether to open
    manager.isAlarmLinked(getDevId());
  }

  @ReactMethod
  public void openPush() {// Local open
    manager.linkAlarm(getDevId(), 0);
  }

  @ReactMethod
  public void closePush() {// Local close
    manager.unLinkAlarm(getDevId(), 0);
  }

  @Override
  public void onPushInit(int i, int i1) {
    System.out.println("onPushInit: " + i + i1);
  }

  @Override
  public void onPushLink(int i, String s, int i1, int i2) {
    System.out.println("onPushLink: " + i + " s: " + s + " i1: " + i1 + " i2: " + i2);

  }

  @Override
  public void onPushUnLink(int i, String s, int i1, int i2) {
    System.out.println("onPushUnLink: " + i + s + i1 + i2);
  }

  @Override
  public void onIsPushLinkedFromServer(int i, String s, boolean isLinked) {// The callback to isPushOpen()
    // if (iDevPushView != null) {
    // iDevPushView.onPushStateResult(isLinked);
    // }
    System.out.println("onIsPushLinkedFromServer: " + Boolean.toString(isLinked));
    System.out.println("onIsPushLinkedFromServer: " + i + s);
  }

  @Override
  public void onAlarmInfo(int i, String s, Message message, MsgContent msgContent) {
    System.out.println("onAlarmInfo: " + i + s);
  }

  @Override
  public void onLinkDisconnect(int i, String s) {
    System.out.println("onLinkDisconnect: " + i + s);
  }

  @Override
  public void onWeChatState(String s, int i, int i1) {
    System.out.println("onWeChatState: " + i + s + i1);
  }

  @Override
  public void onThirdPushState(String s, int i, int i1, int i2) {
    System.out.println("onThirdPushState: " + s + i + i1 + i2);

  }

  @Override
  public void onAllUnLinkResult() {
    System.out.println("onAllUnLinkResult: ");

  }

  @Override
  public void onFunSDKResult(Message message, MsgContent msgContent) {

  }
}
