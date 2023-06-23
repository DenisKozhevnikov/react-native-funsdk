package com.funsdk.user.device.add.sn;

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

import com.basic.G;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.manager.account.AccountManager;
import com.manager.db.XMDevInfo;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKDevSnConnectModule extends ReactContextBaseJavaModule {
  public FunSDKDevSnConnectModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  public String getName() {
    return "FunSDKDevSnConnectModule";
  }

  /**
   * Add device
   *
   * @param DEVICE_ID   serial number
   * @param USERNAME    login userName
   * @param PASSWORD    login password
   * @param DEVICE_TYPE device Type
   */
  @ReactMethod
  public void addDev(ReadableMap params, Promise promise) {
    if (ReactParamsCheck.checkParams(
        new String[] { Constants.DEVICE_ID, Constants.PASSWORD, Constants.USERNAME, Constants.DEVICE_TYPE,
            Constants.DEVICE_NAME },
        params)) {
      SDBDeviceInfo deviceInfo = new SDBDeviceInfo();

      G.SetValue(deviceInfo.st_0_Devmac, params.getString(Constants.DEVICE_ID));
      G.SetValue(deviceInfo.st_5_loginPsw, params.getString(Constants.PASSWORD));
      G.SetValue(deviceInfo.st_4_loginName, params.getString(Constants.USERNAME));
      G.SetValue(deviceInfo.st_1_Devname, params.getString(Constants.DEVICE_NAME));

      // deviceInfo.st_7_nType = params.getInt(Constants.DEVICE_TYPE);

      XMDevInfo xmDevInfo = new XMDevInfo();
      xmDevInfo.sdbDevInfoToXMDevInfo(deviceInfo);
      // XMAccountManager.getInstance().checkPwd(
      // params.getString(Constants.EMAIL),
      // Constants.getResultCallback(promise)
      // );

      AccountManager.getInstance().addDev(xmDevInfo, Constants.getResultCallback(promise));
    }
  }
}