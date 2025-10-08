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

import static com.manager.push.XMPushManager.PUSH_TYPE_XM;
import static com.manager.push.XMPushManager.PUSH_TYPE_GOOGLE;
import static com.manager.push.XMPushManager.PUSH_TYPE_GOOGLE_V2;

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

  @ReactMethod
  public void initGoogleV2FunSDKPush(ReadableMap params, Promise promise) {
    manager = new XMPushManager(this);

    // String devId = params.getString(Constants.DEVICE_ID);
    // String token = params.getString(Constants.TOKEN);
    // int pushType = params.getInt("type");

    // SMCInitInfo info = new SMCInitInfo();

    // G.SetValue(info.st_0_user, XMAccountManager.getInstance().getAccountName());
    // G.SetValue(info.st_1_password, XMAccountManager.getInstance().getPassword());
    // G.SetValue(info.st_2_token, token);

    // manager.initFunSDKPush((Context) reactContext, info, pushType);
    // manager.linkAlarm(devId, 0);

    // System.out.println("success init?");
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
  public void onPushInit(int pushType, int errorId) {
    if (errorId >= 0) {
      System.out.println("onPush 推送初始化成功:" + pushType);
    } else {
      System.out.println("onPush 推送初始化失败:" + errorId);
    }
  }

  @Override
  public void onPushLink(int pushType, String devId, int seq, int errorId) {
    if (errorId >= 0) {
      System.out.println("推送订阅成功:" + devId + " pushType: " + pushType + " seq: " + seq);
    } else {
      System.out.println("推送订阅失败:" + devId + ":" + errorId + " pushType: " + pushType + " seq: " + seq);
    }
  }

  @Override
  public void onPushUnLink(int pushType, String devId, int seq, int errorId) {
    if (errorId >= 0) {
      System.out.println("取消订阅成功:" + devId + " pushType: " + pushType + " seq: " + seq);
    } else {
      System.out.println("取消订阅失败:" + devId + ":" + errorId + " pushType: " + pushType + " seq: " + seq);
    }
  }

  @Override
  public void onIsPushLinkedFromServer(int pushType, String devId, boolean isLinked) {// The callback to isPushOpen()
    // if (iDevPushView != null) {
    // iDevPushView.onPushStateResult(isLinked);
    // }
    System.out.println("onPush onIsPushLinkedFromServer: " + Boolean.toString(isLinked));
    System.out.println("onPush onIsPushLinkedFromServer: " + pushType + " devId: " + devId);
  }

  @Override
  public void onAlarmInfo(int pushType, String devId, Message message, MsgContent msgContent) {
    String pushMsg = G.ToString(msgContent.pData);
    System.out.println("onPush onAlarmInfo 接收到报警消息:" + pushMsg + " pushType: " + pushType + " devId: " + devId);
  }

  @Override
  public void onLinkDisconnect(int i, String s) {
    System.out.println("onPush onLinkDisconnect: " + i + s);
  }

  @Override
  public void onWeChatState(String s, int i, int i1) {
    System.out.println("onPush onWeChatState: " + i + s + i1);
  }

  @Override
  public void onThirdPushState(String info, int pushType, int state, int errorId) {
    System.out.println(
        "onPush onThirdPushState: " + info + " pushType: " + pushType + " state: " + state + " errorId: " + errorId);

  }

  @Override
  public void onAllUnLinkResult(boolean isSuccess) {
    System.out.println("onPush onAllUnLinkResult: " + isSuccess);
  }

  // Note: This class does not implement IFunSDKResult; remove @Override to avoid compilation issues
  public void onFunSDKResult(Message message, MsgContent msgContent) {
    // no-op
  }
}
