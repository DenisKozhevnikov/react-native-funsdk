package com.funsdk.user.device.add.quick;

import android.content.Context;
import android.net.DhcpInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;

import com.lib.FunSDK;
import com.lib.MsgContent;
import com.utils.XMWifiManager;
import com.manager.device.DeviceManager;
import com.manager.db.XMDevInfo;
import com.manager.account.AccountManager;
import com.manager.account.BaseAccountManager;
import com.utils.XUtils;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;
import com.funsdk.utils.EventSender;

public class FunSDKDevQuickConnectModule extends ReactContextBaseJavaModule {
  public ReactApplicationContext reactContext;
  public String EVENT_METHOD = "onSetWiFi";

  public FunSDKDevQuickConnectModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  @Override
  public String getName() {
    return "FunSDKDevQuickConnectModule";
  }

  // https://stackoverflow.com/a/69650217
  @ReactMethod
  public void addListener(String eventName) {

  }

  @ReactMethod
  public void removeListeners(Integer count) {

  }

  /**
   * poisk i podkliuchenie ustroistva v wifi
   * необходимо разрешение location в android
   */
  // @ReactMethod
  // public void startSetWiFi(ReadableMap params, Promise promise) {
  // if (ReactParamsCheck.checkParams(new String[] { Constants.PASS_WIFI },
  // params)) {
  // String passWifi = params.getString(Constants.PASS_WIFI);
  // startQuickSetWiFi(passWifi);
  // promise.resolve("nu ya gotov");
  // }
  // }
  @ReactMethod
  public void startSetWiFi(ReadableMap params) {
    if (ReactParamsCheck.checkParams(new String[] { Constants.PASS_WIFI }, params)) {
      String passWifi = params.getString(Constants.PASS_WIFI);

      WritableMap result = Arguments.createMap();
      result.putString("status", "поиск начат");
      EventSender.sendEvent(getReactApplicationContext(), EVENT_METHOD, result);

      startQuickSetWiFi(passWifi);
    }
  }

  public void startQuickSetWiFi(String pwd) {
    XMWifiManager xmWifiManager = XMWifiManager.getInstance((Context) reactContext);

    WifiManager wifiManager = (WifiManager) reactContext
        .getSystemService(Context.WIFI_SERVICE);

    // WifiInfo wifiInfo = wifiManager.getConnectionInfo();
    // DhcpInfo dhcpInfo = wifiManager.getDhcpInfo();
    WifiInfo wifiInfo = xmWifiManager.getWifiInfo();
    DhcpInfo dhcpInfo = xmWifiManager.getDhcpInfo();

    String curSSID = xmWifiManager.getSSID();

    // необходим доступ к локации в приложении, иначе будет <unknown ssid>
    // String curSSID = wifiInfo.getSSID();
    ScanResult scanResult = xmWifiManager.getCurScanResult(curSSID);

    WritableMap result = Arguments.createMap();
    result.putString("data", "curSSID: " + curSSID);
    result.putString("status", "поиск продолжается");
    EventSender.sendEvent(getReactApplicationContext(), EVENT_METHOD, result);

    if (scanResult != null && wifiInfo != null && dhcpInfo != null) {
      // manager.startQuickSetWiFi(XUtils.initSSID(wifiInfo.getSSID()), pwd,
      // scanResult.capabilities, dhcpInfo, 180 * 1000,
      // this);
      DeviceManager.getInstance().startQuickSetWiFi(XUtils.initSSID(curSSID), pwd, scanResult.capabilities, dhcpInfo,
          // 180 * 1000,
          100,
          new DeviceManager.OnQuickSetWiFiListener() {
            @Override
            public void onQuickSetResult(XMDevInfo xmDevInfo, int errorId) {
              System.out.println(" nu a eto kak vozmohno wifiManager null!" + errorId);

              if (xmDevInfo != null) {
                System.out.println(" chto to nashlo!");

                WritableMap result = Arguments.createMap();
                result.putString("status", "успешно найдено устройство");
                EventSender.sendEvent(getReactApplicationContext(), EVENT_METHOD, result);

              } else {
                WritableMap result = Arguments.createMap();
                result.putString("error", "errorId: " + errorId);
                result.putString("status", "ошибка при поиске");
                EventSender.sendEvent(getReactApplicationContext(), EVENT_METHOD, result);
              }
            }

          });
    }
  }

  /**
   * ostanovka poiska ustroistva v wifi
   */
  @ReactMethod
  public void stopSetWiFi(Promise promise) {
    DeviceManager.getInstance().stopQuickSetWiFi();
    promise.resolve(true);
  }

  boolean isInit = false;
  boolean isNeedGetDevRandomUserPwdAgain = true;// 是否需要再次获取随机用户名密码（用于在配网成功后，因设备的34567端口还没有建立起来，App通过IP方式去访问设备会失败，所以需要重试）

  /**
   * 获取设备的随机用户名和密码
   */
  private void getDevRandomUserPwd(XMDevInfo xmDevInfo) {
    DeviceManager.getInstance().getDevRandomUserPwd(xmDevInfo, new DeviceManager.OnDevManagerListener() {
      @Override
      public void onSuccess(String devId, int operationType, Object result) {
        // 获取设备登录Token信息：先要登录设备，然后通过DevGetLocalEncToken来获取
        DeviceManager.getInstance().loginDev(devId, new DeviceManager.OnDevManagerListener() {
          @Override
          public void onSuccess(String devId, int operationType, Object result) {
            // 获取设备登录Token信息
            String devToken = FunSDK.DevGetLocalEncToken(devId);
            xmDevInfo.setDevToken(devToken);
            System.out.println("devToken:" + devToken);
            // XMPromptDlg.onShow(iDevQuickConnectView.getContext(),
            // iDevQuickConnectView.getContext().getString(R.string.is_need_delete_dev_from_other_account),
            // new View.OnClickListener() {
            // @Override
            // public void onClick(View v) {
            // addDevice(xmDevInfo, true);
            // }
            // }, new View.OnClickListener() {
            // @Override
            // public void onClick(View v) {
            // addDevice(xmDevInfo, false);
            // }
            // });
            // addDevice(xmDevInfo, false);
          }

          @Override
          public void onFailed(String devId, int msgId, String jsonName, int errorId) {
            System.out.println("login: " + errorId);
          }
        });
      }

      @Override
      public void onFailed(String devId, int msgId, String jsonName, int errorId) {
        System.out.println("errorId: " + errorId);
        if (isNeedGetDevRandomUserPwdAgain && (errorId == -10005 || errorId == -100000)) {
          // 如果获取随机用户名密码超时的话，可以延时1s重试一次
          new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
              getDevRandomUserPwd(xmDevInfo);
            }
          }, 1000);

          isNeedGetDevRandomUserPwdAgain = false;
          return;
        }

        if (errorId == -400009) {
          // 如果不支持随机用户名密码的话，就以 用户名：admin 密码为空登录设备
          // 是否要将该设备从其他账号下移除
          // XMPromptDlg.onShow(iDevQuickConnectView.getContext(),
          // iDevQuickConnectView.getContext().getString(R.string.is_need_delete_dev_from_other_account),
          // new View.OnClickListener() {
          // @Override
          // public void onClick(View v) {
          // addDevice(xmDevInfo, true);
          // }
          // }, new View.OnClickListener() {
          // @Override
          // public void onClick(View v) {
          // addDevice(xmDevInfo, false);
          // }
          // });
          addDevice(xmDevInfo, false);
        } else {
          // ToastUtils.showLong("配网失败：" + errorId);
          System.out.println("配网失败：" + errorId);
        }
      }
    });
  }

  /**
   * Add device to account
   *
   * @param xmDevInfo             Device Information
   * @param isUnbindDevUnderOther Do you want to unbind all accounts that have
   *                              been added to this device before?
   */
  private void addDevice(XMDevInfo xmDevInfo, boolean isUnbindDevUnderOther) {
    AccountManager.getInstance().addDev(xmDevInfo, isUnbindDevUnderOther,
        new BaseAccountManager.OnAccountManagerListener() {
          @Override
          public void onSuccess(int msgId) {
            System.out.println("addDevice onSuccess: " + msgId);
            // Toast.makeText(iDevQuickConnectView.getContext(), R.string.add_s,
            // Toast.LENGTH_LONG).show();
            // iDevQuickConnectView.onAddDevResult();
          }

          @Override
          public void onFailed(int msgId, int errorId) {
            System.out.println("addDevice onSuccess: " + msgId + " errorId: " + errorId);
            // Toast
            // .makeText(iDevQuickConnectView.getContext(),
            // iDevQuickConnectView.getContext().getString(R.string.add_f) + ":" + errorId,
            // Toast.LENGTH_LONG)
            // .show();
            // iDevQuickConnectView.onAddDevResult();
          }

          @Override
          public void onFunSDKResult(Message message, MsgContent msgContent) {

          }
        });
  }

}