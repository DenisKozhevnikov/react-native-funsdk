package com.funsdk.utils;

import android.os.Message;

import com.facebook.react.bridge.Promise;

import com.lib.MsgContent;
import com.manager.account.BaseAccountManager;

public class Constants {
    public static final String USERNAME = "username";
    public static final String PASSWORD = "password";
    public static final String EMAIL = "email";
    public static final String PHONE_NUMBER = "phoneNumber";
    public static final String VERIFY_CODE = "verifyCode";
    public static final String CURRENT_PASSWORD = "currentPassword";
    public static final String NEW_PASSWORD = "newPassword";

    public static final String DEVICE_ID = "deviceId";
    public static final String DEVICE_TYPE = "deviceType";
    public static final String DEVICE_NAME = "deviceName";
    public static final String DEVICE_LOGIN = "deviceLogin";
    public static final String DEVICE_PASSWORD = "devicePassword";
    public static final String DEVICE_NEW_PASSWORD = "deviceNewPassword";
    public static final String DEVICE_CHANNEL = "deviceChannel";
    public static final String DEVICE_IS_DELETE_FROM_OTHERS = "isDevDeleteFromOthersUsers";
    public static final String DEVICE_IP = "deviceIp";
    public static final String DEVICE_PORT = "DMZTcpPort";
    public static final String DEVICE_ID_NUM = "deviceIdNum";

    public static final String RECORD_FILE_DATA = "recordFileData";

    public static final String JSON_AS_STRING = "jsonAsString";
    public static final String COMMAND = "command";
    public static final String B_STOP = "bStop";
    public static final String TOKEN = "token";
    public static final String PATH = "path";
    public static final String FUNCTION_NAME = "functionName";
    public static final String FUNCTION_COMMAND_STR = "functionCommandStr";
    public static final String METHOD_NAME = "methodName";
    public static final String SPEED = "speed";

    public static final String APP_UUID = "uuid";
    public static final String APP_KEY = "key";
    public static final String APP_SECRET = "secret";
    public static final String APP_MOVEDCARD = "movedCard";

    public static final String APP_CUSTOM_PWD_TYPE = "customPwdType";
    public static final String APP_CUSTOM_PWD = "customPwd";
    public static final String APP_CUSTOM_SERVER_ADDR = "customServerAddr";
    public static final String APP_CUSTOM_CUSTOM_PORT = "customPort";

    public static final String PASS_WIFI = "passwordWifi";

    public static final String FUN_STR_ATTR = "FunStrAttr";

    public static BaseAccountManager.OnAccountManagerListener getResultCallback(Promise promise) {
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
