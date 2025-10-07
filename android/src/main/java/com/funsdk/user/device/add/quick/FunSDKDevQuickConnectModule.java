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
import com.manager.db.DevDataCenter;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.basic.G;
import com.utils.XUtils;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;
import com.funsdk.utils.EventSender;
import com.funsdk.utils.DataConverter;

public class FunSDKDevQuickConnectModule extends ReactContextBaseJavaModule {
  public ReactApplicationContext reactContext;
  private static final String ON_SET_WIFI_DEBUG = "onSetWiFi";
  private static final String ON_ADD_DEVICE_STATUS = "onAddDeviceStatus";

  public FunSDKDevQuickConnectModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  /**
   * Поиск устройств через Wi‑Fi с явным ssid (аналог iOS startDeviceSearch)
   */
  @ReactMethod
  public void startDeviceSearch(ReadableMap params) {
    try {
      String ssidWifi = params.hasKey("ssidWifi") && !params.isNull("ssidWifi") ? params.getString("ssidWifi") : null;
      String passWifi = params.hasKey(Constants.PASS_WIFI) && !params.isNull(Constants.PASS_WIFI)
          ? params.getString(Constants.PASS_WIFI)
          : null;
      boolean isDevDeleteFromOthers = params.hasKey(Constants.DEVICE_IS_DELETE_FROM_OTHERS)
          && !params.isNull(Constants.DEVICE_IS_DELETE_FROM_OTHERS)
              ? params.getBoolean(Constants.DEVICE_IS_DELETE_FROM_OTHERS)
              : false;

      WritableMap result = Arguments.createMap();
      result.putString("status", "поиск начат");
      EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);
      sendDeviceConnectStatus("start", null, null, null);

      XMWifiManager xmWifiManager = XMWifiManager.getInstance((Context) reactContext);
      // если ssid не передан — используем текущий
      String targetSsid = ssidWifi != null && !ssidWifi.isEmpty() ? ssidWifi : xmWifiManager.getSSID();

      WifiInfo wifiInfo = xmWifiManager.getWifiInfo();
      DhcpInfo dhcpInfo = xmWifiManager.getDhcpInfo();
      ScanResult scanResult = xmWifiManager.getCurScanResult(targetSsid);

      if (scanResult == null || wifiInfo == null || dhcpInfo == null) {
        WritableMap err = Arguments.createMap();
        err.putString("data", "curSSID: " + targetSsid);
        err.putString("status", "ошибка при получении wifi данных");
        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, err);
        sendDeviceConnectStatus("error-wifi", null, null, null);
        return;
      }

      WritableMap step = Arguments.createMap();
      step.putString("data", "curSSID: " + targetSsid);
      step.putString("status", "поиск продолжается");
      EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, step);

      final String ssidInited = XUtils.initSSID(targetSsid);
      final String pwd = passWifi != null ? passWifi : "";

      DeviceManager.getInstance().startQuickSetWiFi(
          ssidInited,
          pwd,
          scanResult.capabilities,
          dhcpInfo,
          180 * 1000,
          new DeviceManager.OnQuickSetWiFiListener() {
            @Override
            public void onQuickSetResult(XMDevInfo xmDevInfo, int errorId) {
              if (xmDevInfo != null) {
                WritableMap ok = Arguments.createMap();
                ok.putString("status",
                    "успешно найдено устройство, идём получать случайное имя пользователя и пароль");
                EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, ok);

                isNeedGetDevRandomUserPwdAgain = true;
                getDevRandomUserPwd(xmDevInfo, isDevDeleteFromOthers);
              } else {
                WritableMap fail = Arguments.createMap();
                fail.putString("error", "errorId: " + errorId);
                fail.putString("status", "ошибка при поиске");
                EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, fail);
                sendDeviceConnectStatus("error", errorId, null, null);
              }
            }
          });
    } catch (Throwable t) {
      WritableMap err = Arguments.createMap();
      err.putString("status", "ошибка при запуске поиска: " + t.getMessage());
      EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, err);
      sendDeviceConnectStatus("error", -1, null, null);
    }
  }

  /**
   * Добавление найденного устройства (аналог iOS addFoundDevice)
   * deviceInfo: { deviceMac, deviceName, loginName, loginPassword, deviceType }
   */
  @ReactMethod
  public void addFoundDevice(ReadableMap deviceInfo, Promise promise) {
    try {
      SDBDeviceInfo sdb = new SDBDeviceInfo();

      if (deviceInfo.hasKey("deviceMac") && !deviceInfo.isNull("deviceMac")) {
        G.SetValue(sdb.st_0_Devmac, deviceInfo.getString("deviceMac"));
      }
      if (deviceInfo.hasKey("deviceName") && !deviceInfo.isNull("deviceName")) {
        G.SetValue(sdb.st_1_Devname, deviceInfo.getString("deviceName"));
      }
      if (deviceInfo.hasKey("deviceIp") && !deviceInfo.isNull("deviceIp")) {
        G.SetValue(sdb.st_2_Devip, deviceInfo.getString("deviceIp"));
      }
      if (deviceInfo.hasKey("loginName") && !deviceInfo.isNull("loginName")) {
        G.SetValue(sdb.st_4_loginName, deviceInfo.getString("loginName"));
      }
      if (deviceInfo.hasKey("loginPassword") && !deviceInfo.isNull("loginPassword")) {
        G.SetValue(sdb.st_5_loginPsw, deviceInfo.getString("loginPassword"));
      }
      if (deviceInfo.hasKey("deviceType") && !deviceInfo.isNull("deviceType")) {
        sdb.st_7_nType = deviceInfo.getInt("deviceType");
      }

      XMDevInfo xmDevInfo = new XMDevInfo();
      xmDevInfo.sdbDevInfoToXMDevInfo(sdb);

      AccountManager.getInstance().addDev(xmDevInfo, false,
          new BaseAccountManager.OnAccountManagerListener() {
            @Override
            public void onSuccess(int msgId) {
              WritableMap res = Arguments.createMap();
              res.putBoolean("success", true);
              res.putString("deviceMac", xmDevInfo.getDevId());
              res.putString("deviceName", xmDevInfo.getDevName());
              res.putString("message", "added");
              promise.resolve(res);
            }

            @Override
            public void onFailed(int msgId, int errorId) {
              promise.reject("addFoundDevice_error", msgId + " " + errorId);
            }

            @Override
            public void onFunSDKResult(Message message, MsgContent msgContent) {
            }
          });
    } catch (Throwable t) {
      promise.reject("addFoundDevice_exception", t);
    }
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

  public void sendDeviceConnectStatus(String status, Object errorId, Object msgId, XMDevInfo xmDevInfo) {
    WritableMap addDevResult = Arguments.createMap();
    addDevResult.putString("status", status);

    DataConverter.putToWritableMap(addDevResult, "errorId", errorId);
    DataConverter.putToWritableMap(addDevResult, "msgId", msgId);

    if (xmDevInfo != null) {
      WritableMap deviceData = Arguments.createMap();

      DataConverter.putToWritableMap(deviceData, "devId", xmDevInfo.getDevId());
      DataConverter.putToWritableMap(deviceData, "devName", xmDevInfo.getDevName());
      DataConverter.putToWritableMap(deviceData, "devUserName", xmDevInfo.getDevUserName());
      DataConverter.putToWritableMap(deviceData, "devPassword", xmDevInfo.getDevPassword());
      DataConverter.putToWritableMap(deviceData, "devIp", xmDevInfo.getDevIp());
      DataConverter.putToWritableMap(deviceData, "devPort", xmDevInfo.getDevPort());
      DataConverter.putToWritableMap(deviceData, "devType", xmDevInfo.getDevType());
      DataConverter.putToWritableMap(deviceData, "devState", xmDevInfo.getDevState());
      DataConverter.putToWritableMap(deviceData, "string", xmDevInfo.toString());
      DataConverter.putToWritableMap(deviceData, "pid", xmDevInfo.getPid());
      DataConverter.putToWritableMap(deviceData, "mac", xmDevInfo.getMac());
      DataConverter.putToWritableMap(deviceData, "devToken", xmDevInfo.getDevToken());
      DataConverter.putToWritableMap(deviceData, "cloudCryNum", xmDevInfo.getCloudCryNum());

      addDevResult.putMap("deviceData", deviceData);
    }

    EventSender.sendEvent(getReactApplicationContext(), ON_ADD_DEVICE_STATUS, addDevResult);
  }

  /**
   * poisk i podkliuchenie ustroistva v wifi
   * необходимо разрешение location в android
   */
  @ReactMethod
  public void startSetWiFi(ReadableMap params) {
    if (ReactParamsCheck.checkParams(new String[] { Constants.PASS_WIFI, Constants.DEVICE_IS_DELETE_FROM_OTHERS },
        params)) {
      String passWifi = params.getString(Constants.PASS_WIFI);
      boolean isDevDeleteFromOthers = params.getBoolean(Constants.DEVICE_IS_DELETE_FROM_OTHERS);

      WritableMap result = Arguments.createMap();
      result.putString("status", "поиск начат");
      EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

      sendDeviceConnectStatus("start", null, null, null);

      startQuickSetWiFi(passWifi, isDevDeleteFromOthers);
    }
  }

  public void startQuickSetWiFi(String pwd, boolean isDevDeleteFromOthers) {
    XMWifiManager xmWifiManager = XMWifiManager.getInstance((Context) reactContext);

    // не нужен?
    // WifiManager wifiManager = (WifiManager) reactContext
    // .getSystemService(Context.WIFI_SERVICE);

    // WifiInfo wifiInfo = wifiManager.getConnectionInfo();
    // DhcpInfo dhcpInfo = wifiManager.getDhcpInfo();
    WifiInfo wifiInfo = xmWifiManager.getWifiInfo();
    DhcpInfo dhcpInfo = xmWifiManager.getDhcpInfo();

    String curSSID = xmWifiManager.getSSID();

    // необходим доступ к локации в приложении, иначе будет <unknown ssid>
    // String curSSID = wifiInfo.getSSID();
    ScanResult scanResult = xmWifiManager.getCurScanResult(curSSID);

    if (scanResult == null || wifiInfo == null || dhcpInfo == null) {
      WritableMap result = Arguments.createMap();
      result.putString("status", "ошибка при получении wifi данных");
      EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

      // проверьте подключение к wifi, настройки доступа к location в android (?)
      sendDeviceConnectStatus("error-wifi", null, null, null);
      return;
    }

    WritableMap result = Arguments.createMap();
    result.putString("data", "curSSID: " + curSSID);
    result.putString("status", "поиск продолжается");
    EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

    if (scanResult != null && wifiInfo != null && dhcpInfo != null) {
      DeviceManager.getInstance().startQuickSetWiFi(XUtils.initSSID(curSSID), pwd, scanResult.capabilities, dhcpInfo,
          180 * 1000,
          new DeviceManager.OnQuickSetWiFiListener() {
            @Override
            public void onQuickSetResult(XMDevInfo xmDevInfo, int errorId) {

              if (xmDevInfo != null) {
                WritableMap result = Arguments.createMap();
                result.putString("status",
                    "успешно найдено устройство, идём получать случайное имя пользователя и пароль");
                EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

                // сбрасываем значение на дефолтное (вдруг мы до этого уже искали)
                isNeedGetDevRandomUserPwdAgain = true;
                // проверяем возможно ли залогиниться с рандомным именем/паролем
                getDevRandomUserPwd(xmDevInfo, isDevDeleteFromOthers);
              } else {
                WritableMap result = Arguments.createMap();
                result.putString("error", "errorId: " + errorId);
                result.putString("status", "ошибка при поиске");
                EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

                sendDeviceConnectStatus("error", errorId, null, null);
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
  // Вам нужно снова получить случайное имя пользователя и пароль (используется
  // после успешной настройки сети, поскольку порт 34567 устройства еще не
  // установлен, приложению не удастся получить доступ к устройству через IP,
  // поэтому вам нужно повторить попытку)
  boolean isNeedGetDevRandomUserPwdAgain = true;

  /**
   * Получите случайное имя пользователя и пароль для устройства
   */
  private void getDevRandomUserPwd(XMDevInfo xmDevInfo, boolean isDevDeleteFromOthers) {
    DeviceManager.getInstance().getDevRandomUserPwd(xmDevInfo, new DeviceManager.OnDevManagerListener() {
      @Override
      public void onSuccess(String devId, int operationType, Object result) {
        // Получите информацию о токене входа в устройство: сначала войдите на
        // устройство, а затем получите ее через DevGetLocalEncToken.
        DeviceManager.getInstance().loginDev(devId, new DeviceManager.OnDevManagerListener() {
          @Override
          public void onSuccess(String devId, int operationType, Object result) {
            WritableMap resultMap = Arguments.createMap();
            resultMap.putString("status", "успешно авторизовано на устройстве");
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultMap);

            // Получить информацию о токене входа в систему устройства
            String devToken = FunSDK.DevGetLocalEncToken(devId);
            xmDevInfo.setDevToken(devToken);

            WritableMap resultToken = Arguments.createMap();
            resultToken.putString("status", "Начинаем добавление устройства. Токен устройства - " + devToken);
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultToken);

            // если будет необходимо выбирать на этой стадии добавлять устройство или нет,
            // то надо будет переделать
            addDevice(xmDevInfo, isDevDeleteFromOthers);
          }

          @Override
          public void onFailed(String devId, int msgId, String jsonName, int errorId) {
            WritableMap result = Arguments.createMap();
            result.putString("error", "errorId: " + errorId);
            result.putString("status", "ошибка при авторизации на устройстве");
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

            sendDeviceConnectStatus("error", errorId, null, null);
          }
        });
      }

      @Override
      public void onFailed(String devId, int msgId, String jsonName, int errorId) {
        WritableMap result = Arguments.createMap();
        result.putString("error", "errorId: " + errorId);
        result.putString("msgId", "msgId: " + msgId);
        result.putString("devId", "devId: " + devId);
        result.putString("status", "ошибка при авторизации на устройстве. Возможно попробуем ещё раз");
        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

        if (isNeedGetDevRandomUserPwdAgain && (errorId == -10005 || errorId == -100000)) {
          // Если время получения случайного имени пользователя и пароля истекло, вы
          // можете подождать 1 секунду и повторить попытку.
          new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
              WritableMap result = Arguments.createMap();
              result.putString("status", "идём опять получать случайное имя и пароль");
              EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

              getDevRandomUserPwd(xmDevInfo, isDevDeleteFromOthers);
            }
          }, 1000);

          isNeedGetDevRandomUserPwdAgain = false;
          return;
        }

        if (errorId == -400009) {
          // Если случайное имя пользователя и пароль не поддерживаются, войдите на
          // устройство с именем пользователя: admin и пустым паролем.
          // Вы хотите удалить это устройство из других учетных записей?
          WritableMap resultErr = Arguments.createMap();
          resultErr.putString("status", "ошибка: -400009 но всё равно идём авторизовываться");
          EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultErr);

          // если будет необходимо выбирать на этой стадии добавлять устройство или нет,
          // то надо будет переделать
          addDevice(xmDevInfo, isDevDeleteFromOthers);
        } else {
          // Не удалось настроить сеть:
          // ToastUtils.showLong("配网失败：" + errorId);
          WritableMap resultErr = Arguments.createMap();
          resultErr.putString("status", "Не удалось настроить сеть - " + errorId);
          EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultErr);

          sendDeviceConnectStatus("error", errorId, null, null);
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
            WritableMap result = Arguments.createMap();
            result.putString("status", "Устройство успешно добавлено на вашем аккаунте");
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

            sendDeviceConnectStatus("success", null, msgId, xmDevInfo);
          }

          @Override
          public void onFailed(int msgId, int errorId) {
            // System.out.println("addDevice onSuccess: " + msgId + " errorId: " + errorId);
            WritableMap result = Arguments.createMap();
            result.putString("status", "Ошибка добавления устройства на вашем аккаунте");
            result.putString("error", "errorId: " + errorId);
            result.putString("msgId", "msgId: " + msgId);
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

            sendDeviceConnectStatus("error", errorId, null, null);
          }

          @Override
          public void onFunSDKResult(Message message, MsgContent msgContent) {

          }
        });
  }

}