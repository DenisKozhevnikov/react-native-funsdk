package com.funsdk.user.device.add.qrcode;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.DhcpInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.format.Formatter;

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
import com.lib.sdk.bean.StringUtils;
import com.utils.XMWifiManager;
import com.manager.device.DeviceManager;
import com.manager.db.XMDevInfo;
import com.manager.account.AccountManager;
import com.manager.account.BaseAccountManager;
import com.manager.account.XMAccountManager;
import com.utils.XUtils;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;
import com.funsdk.utils.EventSender;
import com.funsdk.utils.DataConverter;

public class FunSDKDevQRCodeConnectModule extends ReactContextBaseJavaModule {
    public ReactApplicationContext reactContext;
    private static final String ON_SET_WIFI_DEBUG = "onSetWiFi";
    private static final String ON_ADD_DEVICE_STATUS = "onAddDeviceStatus";

    public FunSDKDevQRCodeConnectModule(ReactApplicationContext context) {
        super(context);
        this.reactContext = context;
    }

    @Override
    public String getName() {
        return "FunSDKDevQRCodeConnectModule";
    }

    // https://stackoverflow.com/a/69650217
    @ReactMethod
    public void addListener(String eventName) {

    }

    @ReactMethod
    public void removeListeners(Integer count) {

    }

    public void sendDeviceConnectStatus(String status, Object errorId, Object msgId) {
        WritableMap addDevResult = Arguments.createMap();
        addDevResult.putString("status", status);

        DataConverter.putToWritableMap(addDevResult, "errorId", errorId);
        DataConverter.putToWritableMap(addDevResult, "msgId", msgId);

        EventSender.sendEvent(getReactApplicationContext(), ON_ADD_DEVICE_STATUS, addDevResult);
    }

    // с изображением qr кода в виде base64
    public void sendDeviceConnectStatus(String status, Object errorId, Object msgId, String base64) {
        WritableMap addDevResult = Arguments.createMap();
        addDevResult.putString("status", status);

        DataConverter.putToWritableMap(addDevResult, "errorId", errorId);
        DataConverter.putToWritableMap(addDevResult, "msgId", msgId);

        addDevResult.putString("base64Image", base64);

        EventSender.sendEvent(getReactApplicationContext(), ON_ADD_DEVICE_STATUS, addDevResult);
    }

    // с данными об устройстве
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

    @ReactMethod
    public void startSetByQRCode(ReadableMap params) {
        if (ReactParamsCheck.checkParams(new String[] { Constants.PASS_WIFI, Constants.DEVICE_IS_DELETE_FROM_OTHERS },
                params)) {
            String passWifi = params.getString(Constants.PASS_WIFI);
            boolean isDevDeleteFromOthers = params.getBoolean(Constants.DEVICE_IS_DELETE_FROM_OTHERS);

            WritableMap result = Arguments.createMap();
            result.putString("status", "поиск начат");
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

            Bitmap bitmap = startSetDevToRouterByQrCode(passWifi, isDevDeleteFromOthers);
            String base64 = DataConverter.base64FromBitmap(bitmap);

            sendDeviceConnectStatus("start", null, null, base64);
        }
    }

    @ReactMethod
    public void stopSetByQRCode(Promise promise) {
        stopSetDevToRouterByQrCode();
        promise.resolve(true);
    }

    /**
     * Остановить поиск по qr коду
     */
    public void stopSetDevToRouterByQrCode() {
        DeviceManager.getInstance().unInitDevToRouterByQrCode();
    }

    boolean isInit = false;
    boolean isNeedGetDevRandomUserPwdAgain = true;// Необходимо ли снова получить случайное имя пользователя и пароль
                                                  // (используется после успешной настройки сети, поскольку порт 34567
                                                  // устройства еще не установлен, Приложение не сможет получить доступ
                                                  // к устройству по IP, так что надо повторить)

    /**
     * Получите QR-код с информацией о конфигурации сети и начните настройку
     * устройства на маршрутизаторе.
     * Get the QR code with the distribution network information and start
     * configuring the device to the router
     *
     * @param wifiPwd
     * @param isDevDeleteFromOthers
     * @return
     */
    public Bitmap startSetDevToRouterByQrCode(String wifiPwd, boolean isDevDeleteFromOthers) {

        // восстанавливаем значения по умолчанию
        isInit = false;
        isNeedGetDevRandomUserPwdAgain = true;

        XMWifiManager xmWifiManager = XMWifiManager.getInstance((Context) reactContext);

        WifiInfo wifiInfo = xmWifiManager.getWifiInfo();
        DhcpInfo dhcpInfo = xmWifiManager.getDhcpInfo();
        String ssid = XUtils.initSSID(xmWifiManager.getSSID());
        ScanResult scanResult = xmWifiManager.getCurScanResult(ssid);// The ScanResult object obtained through the ssid
                                                                     // contains more network information objects

        if (scanResult == null || wifiInfo == null || dhcpInfo == null) {
            WritableMap result = Arguments.createMap();
            result.putString("data", "curSSID: " + ssid);
            result.putString("status", "ошибка при получении wifi данных");
            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

            // проверьте подключение к wifi, настройки доступа к location в android (?)
            sendDeviceConnectStatus("error-wifi", null, null);
            return null;
        }

        int pwdType = XUtils.getEncrypPasswordType(scanResult.capabilities);
        if (pwdType == 3 && (wifiPwd.length() == 10 || wifiPwd.length() == 26)) {
            wifiPwd = XUtils.asciiToString(wifiPwd);
        }
        String ipAddress = Formatter.formatIpAddress(dhcpInfo.ipAddress);
        String macAddress = XMWifiManager.getWiFiMacAddress().replace(":", "");

        WritableMap result = Arguments.createMap();
        result.putString("data", "curSSID: " + ssid + " ipAddress: " + ipAddress + " macAddress: " + macAddress);
        result.putString("status", "поиск продолжается");
        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, result);

        Bitmap bitmap = DeviceManager.getInstance().initDevToRouterByQrCode(ssid, wifiPwd, pwdType, macAddress,
                ipAddress, new DeviceManager.OnDevWiFiSetListener() {
                    @Override
                    public void onDevWiFiSetState(int result) {
                        WritableMap debugResult = Arguments.createMap();
                        debugResult.putString("data", "result: " + result);
                        debugResult.putString("status", "onDevWiFiSetState (поиск чего-то?)");
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, debugResult);

                        System.out.println("result:" + result);
                        if (result < 0) {
                            // iSetDevToRouterByQrCodeView.onSetDevToRouterResult(false, null);
                            // После неудачного получения необходимо подождать некоторое время и попытаться
                            // снова активно получить результаты конфигурации сети.
                            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    if (!isInit) {
                                        DeviceManager.getInstance().startDevToRouterByQrCode();
                                    }
                                }
                            }, 2000);

                        }
                    }

                    @Override
                    public void onDevWiFiSetResult(XMDevInfo xmDevInfo) {
                        WritableMap debugResult = Arguments.createMap();
                        debugResult.putString("data", "devId: " + xmDevInfo.getDevId());
                        debugResult.putString("status", "успешно найдено устройство");
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, debugResult);

                        // После успешной настройки сети остановите настройку сети с помощью QR-кода
                        DeviceManager.getInstance().stopDevToRouterByQrCode();
                        if (!isInit) {
                            // Если вы можете получить токен при использовании QR-кода для настройки сети,
                            // вам не нужно получать токен, получая случайное имя пользователя и пароль.
                            if (StringUtils.isStringNULL(xmDevInfo.getDevToken())) {
                                getDevRandomUserPwd(xmDevInfo, isDevDeleteFromOthers);
                            } else {
                                // Вы хотите удалить это устройство из других учетных записей?
                                // XMPromptDlg.onShow(iSetDevToRouterByQrCodeView.getContext(),
                                // iSetDevToRouterByQrCodeView.getContext().getString(R.string.is_need_delete_dev_from_other_account),
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
                                addDevice(xmDevInfo, isDevDeleteFromOthers);
                            }

                            // iSetDevToRouterByQrCodeView.onSetDevToRouterResult(true, xmDevInfo);
                            isInit = true;
                        }
                    }
                });

        DeviceManager.getInstance().startDevToRouterByQrCode();

        return bitmap;
    }

    private void addDevice(XMDevInfo xmDevInfo, boolean isUnbindDevUnderOther) {
        // После успешной настройки сети добавьте устройство в учетную запись.
        XMAccountManager.getInstance().addDev(xmDevInfo, isUnbindDevUnderOther,
                new BaseAccountManager.OnAccountManagerListener() {
                    @Override
                    public void onSuccess(int msgId) {
                        WritableMap debugResult = Arguments.createMap();
                        debugResult.putString("status", "Устройство успешно добавлено на вашем аккаунте");
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, debugResult);

                        sendDeviceConnectStatus("success", null, msgId, xmDevInfo);
                    }

                    @Override
                    public void onFailed(int msgId, int errorId) {
                        WritableMap debugResult = Arguments.createMap();
                        debugResult.putString("status", "Ошибка добавления устройства на вашем аккаунте");
                        debugResult.putString("error", "errorId: " + errorId);
                        debugResult.putString("msgId", "msgId: " + msgId);
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, debugResult);

                        sendDeviceConnectStatus("error", errorId, null);
                    }

                    @Override
                    public void onFunSDKResult(Message msg, MsgContent ex) {

                    }
                });
    }

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
                        WritableMap resultDebug = Arguments.createMap();
                        resultDebug.putString("status", "успешно авторизовано на устройстве");
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultDebug);

                        // Получить информацию о токене входа в систему устройства
                        String devToken = FunSDK.DevGetLocalEncToken(devId);
                        xmDevInfo.setDevToken(devToken);
                        System.out.println("devToken:" + devToken);

                        // Вы хотите удалить это устройство из других учетных записей?
                        addDevice(xmDevInfo, isDevDeleteFromOthers);
                    }

                    @Override
                    public void onFailed(String devId, int msgId, String jsonName, int errorId) {
                        WritableMap resultDebug = Arguments.createMap();
                        resultDebug.putString("error", "errorId: " + errorId);
                        resultDebug.putString("status", "ошибка при авторизации на устройстве");
                        EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultDebug);

                        System.out.println("login:" + errorId);

                        sendDeviceConnectStatus("error", errorId, null);
                    }
                });
            }

            @Override
            public void onFailed(String devId, int msgId, String jsonName, int errorId) {
                WritableMap resultDebug = Arguments.createMap();
                resultDebug.putString("error", "errorId: " + errorId);
                resultDebug.putString("msgId", "msgId: " + msgId);
                resultDebug.putString("devId", "devId: " + devId);
                resultDebug.putString("status", "ошибка при авторизации на устройстве. Возможно попробуем ещё раз");
                EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultDebug);

                System.out.println("errorId:" + errorId);
                if (isNeedGetDevRandomUserPwdAgain && (errorId == -10005 || errorId == -100000)) {
                    // Если время получения случайного имени пользователя и пароля истекло, вы
                    // можете подождать 1 секунду и повторить попытку.
                    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            WritableMap resultDebug = Arguments.createMap();
                            resultDebug.putString("status", "идём опять получать случайное имя и пароль");
                            EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultDebug);

                            getDevRandomUserPwd(xmDevInfo, isDevDeleteFromOthers);
                        }
                    }, 1000);

                    isNeedGetDevRandomUserPwdAgain = false;
                    return;
                }

                if (errorId == -400009) {
                    // Если случайное имя пользователя и пароль не поддерживаются, войдите на
                    // устройство с именем пользователя: admin и пустым паролем.
                    WritableMap resultErr = Arguments.createMap();
                    resultErr.putString("status", "ошибка: -400009 но всё равно идём авторизовываться");
                    EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultErr);

                    // Хотите удалить устройство из других учетных записей?
                    addDevice(xmDevInfo, isDevDeleteFromOthers);
                } else {
                    WritableMap resultErr = Arguments.createMap();
                    resultErr.putString("status", "Не удалось настроить сеть - " + errorId);
                    EventSender.sendEvent(getReactApplicationContext(), ON_SET_WIFI_DEBUG, resultErr);

                    sendDeviceConnectStatus("error", errorId, null);
                }
            }
        });
    }
}
