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
    public static final String ALARM_TYPE = "alarmType";
    public static final String ALARM_INFOS = "alarmInfos";
    public static final String SEARCH_TIME = "searchTime";
    public static final String SEARCH_DAYS = "searchDays";
    public static final String DELETE_TYPE = "deleteType";

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

    public static final String IMAGE_SIZES = "imgSizes";
    public static final String IMAGE_WIDTH = "imgWidth";
    public static final String IMAGE_HEIGHT = "imgHeight";

    public static BaseAccountManager.OnAccountManagerListener getResultCallback(Promise promise) {
        return new BaseAccountManager.OnAccountManagerListener() {
            @Override
            public void onSuccess(int msgId) {
                promise.resolve(msgId);
            }

            @Override
            public void onFailed(int msgId, int errorId) {
                // Формируем информативное сообщение об ошибке
                String errorMessage = getErrorMessage(msgId, errorId);
                String errorCode = msgId + " " + errorId;
                promise.reject(errorCode, errorMessage);
            }

            @Override
            public void onFunSDKResult(Message message, MsgContent msgContent) {
            }
        };
    }

    /**
     * Получить информативное сообщение об ошибке по кодам
     */
    private static String getErrorMessage(int msgId, int errorId) {
        // msgId 5000 = EMSG_SYS_GET_DEV_INFO_BY_USER (логин)
        // msgId 5004 = EMSG_SYS_ADD_DEVICE (добавление устройства)
        
        if (errorId == -603001) {
            return "Ошибка валидации JSON формата данных. Проверьте инициализацию SDK и параметры";
        } else if (errorId == -604000) {
            return "Неверное имя пользователя или пароль";
        } else if (errorId == -605009) {
            if (msgId == 5004) {
                return "Ошибка дешифрования: неверные учетные данные устройства (имя пользователя или пароль)";
            } else {
                return "Ошибка дешифрования: неверные учетные данные";
            }
        } else if (errorId == -99992 || errorId == -604101) {
            return "Устройство уже существует";
        } else if (msgId == 5000) {
            return "Ошибка входа: " + errorId;
        } else if (msgId == 5004) {
            return "Ошибка добавления устройства: " + errorId;
        } else {
            return "Ошибка (" + msgId + "): " + errorId;
        }
    }
}
