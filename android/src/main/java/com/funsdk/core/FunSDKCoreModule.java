package com.funsdk.core;

import static com.lib.EFUN_ATTR.LOGIN_SUP_RSA_ENC;

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
import android.text.TextUtils;

import com.lib.EFUN_ATTR;
import com.lib.FunSDK;
import com.lib.SDKCONST;
import com.manager.XMFunSDKManager;
import com.manager.account.countrycode.CountryCodeListener;
import com.manager.account.countrycode.CountryCodeManager;
import com.lib.sdk.bean.account.PhoneRuleAndRegionBean;

import com.funsdk.utils.Constants;
import com.funsdk.utils.ReactParamsCheck;

public class FunSDKCoreModule extends ReactContextBaseJavaModule {
  private XMFunSDKManager xmFunSDKManager;
  private ReactApplicationContext reactContext;

  @Override
  public String getName() {
    return "FunSDKCoreModule";
  }

  public FunSDKCoreModule(ReactApplicationContext context) {
    super(context);
    reactContext = context;
  }

  /**
   * 初始化 SDK
   * init SDK
   * 传入申请到的AppKey、movedCard和AppSecret等信息
   * input AppKey, movedCard, AppSecret and other information applied by the
   * platform
   *
   * 如果是P2P定制服务器的话请参考以下方法
   * If it is a P2P customized server, please refer to the following method
   * int customPwdType 加密类型 默认传0
   * The default encryption type is 0
   * String customPwd 加密字段 默认传 ""
   * The encryption field is passed "" by default.
   * String customServerAddr 定制服务器域名或IP
   * Customize the server domain name or IP address
   * int customPort 定制服务器端口
   * Customizing a server port
   *
   * XMFunSDKManager.getInstance(0,"",customServerAddr,customPort).initXMCloudPlatform(this,appUuid,appKey,appSecret,appMovedCard,true);
   */
  @ReactMethod
  public void init(ReadableMap params) {
    // Читаем кастомные серверы из JS (как рекомендует README демо)
    int customPwdType = 0;
    String customPwd = "";
    String customServerAddr = "";
    int customPort = 0;

    if (params != null) {
      try {
        if (params.hasKey("customPwdType") && !params.isNull("customPwdType")) {
          customPwdType = params.getInt("customPwdType");
        }
        if (params.hasKey("customPwd") && !params.isNull("customPwd")) {
          customPwd = params.getString("customPwd");
        }
        if (params.hasKey("customServerAddr") && !params.isNull("customServerAddr")) {
          customServerAddr = params.getString("customServerAddr");
        }
        if (params.hasKey("customPort") && !params.isNull("customPort")) {
          customPort = params.getInt("customPort");
        }
      } catch (Exception e) {
        Log.e("FunSDKCoreModule", "Error reading custom server params", e);
      }
    }

    if (!TextUtils.isEmpty(customServerAddr) && customPort > 0) {
      xmFunSDKManager = XMFunSDKManager.getInstance(customPwdType, customPwd, customServerAddr, customPort);
      Log.d("FunSDKCoreModule", "XMFunSDKManager instance created with custom server: " + customServerAddr + ":" + customPort);
    } else {
      xmFunSDKManager = XMFunSDKManager.getInstance();
      Log.d("FunSDKCoreModule", "XMFunSDKManager instance created with default server");
    }

    // SDK 5.0.7: Read credentials from AndroidManifest.xml
    // 从 AndroidManifest.xml 读取凭证
    try {
      android.content.pm.ApplicationInfo appInfo = reactContext.getPackageManager()
          .getApplicationInfo(reactContext.getPackageName(), android.content.pm.PackageManager.GET_META_DATA);
      
      if (appInfo.metaData == null) {
        Log.e("FunSDKCoreModule", "ERROR: No meta-data in AndroidManifest.xml!");
        return;
      }
      
      String appUuid = appInfo.metaData.getString("APP_UUID");
      String appKey = appInfo.metaData.getString("APP_KEY");
      String appSecret = appInfo.metaData.getString("APP_SECRET");
      int appMovedCard = appInfo.metaData.getInt("APP_MOVECARD", 2);
      
      Log.d("FunSDKCoreModule", "========== SDK INITIALIZATION ==========");
      Log.d("FunSDKCoreModule", "APP_UUID: " + (appUuid != null ? appUuid : "NULL"));
      Log.d("FunSDKCoreModule", "APP_KEY: " + (appKey != null ? appKey : "NULL"));
      Log.d("FunSDKCoreModule", "APP_SECRET: " + (appSecret != null ? appSecret.substring(0, Math.min(8, appSecret.length())) + "..." : "NULL"));
      Log.d("FunSDKCoreModule", "APP_MOVECARD: " + appMovedCard);
      
      if (appUuid == null || appUuid.isEmpty() || appKey == null || appKey.isEmpty() || 
          appSecret == null || appSecret.isEmpty() || appMovedCard <= 0) {
        Log.e("FunSDKCoreModule", "ERROR: Invalid credentials in AndroidManifest.xml!");
        Log.e("FunSDKCoreModule", "Please register at https://oppf.xmcsrv.com and set valid APP_UUID, APP_KEY, APP_SECRET, APP_MOVECARD");
        return;
      }
      
      // Initialize with explicit parameters (required in SDK 5.0.7)
      Log.d("FunSDKCoreModule", "Calling initXMCloudPlatform...");
      xmFunSDKManager.initXMCloudPlatform(reactContext, appUuid, appKey, appSecret, appMovedCard, true);
      Log.d("FunSDKCoreModule", "SDK 5.0.7 initialized successfully!");
      Log.d("FunSDKCoreModule", "========================================");
    } catch (Exception e) {
      Log.e("FunSDKCoreModule", "Failed to read credentials from AndroidManifest.xml", e);
      Log.e("FunSDKCoreModule", "Stack trace:", e);
    }

    Log.d("FunSDKCoreModule", "SDK initialization complete");

    /**
     * 有其他定制的服务，在initXMCloudPlatform之后再按照你的需求调用不同的接口
     * There are other customized services, after initXMCloudPlatform call different
     * interfaces according to your needs
     *
     * FunSDK.SysSetServerIPPort("APP_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port);
     * FunSDK.SysSetServerIPPort("STATUS_P2P_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // P2P状态查询/P2P Status Query
     * FunSDK.SysSetServerIPPort("STATUS_DSS_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // DSS状态查询/DSS Status Query
     * FunSDK.SysSetServerIPPort("STATUS_RPS_SERVER","服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // RPS状态查询/RPS Status Query
     * FunSDK.SysSetServerIPPort("STATUS_IDR_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // WPS状态查询/WPS Status Query
     *
     * FunSDK.SysSetServerIPPort("HLS_DSS_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // DSS码流请求/DSS stream request
     * FunSDK.SysSetServerIPPort("CONFIG_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // 配置管理中心/Configuration Management Center
     * FunSDK.SysSetServerIPPort("UPGRADE_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // 固件升级/Firmware Upgrade
     * FunSDK.SysSetServerIPPort("CAPS_SERVER", "服务器域名或IP/Domain name or IP",
     * 服务器端口/Port); // 能力集控制（和云存储有关）/Capability set control (cloud storage)
     */

    /**
     * 初始化 logcat上的日志，可以通过SDK_LOG过滤
     * Initialize the logs on logcat, which can be filtered by SDK_LOG
     */
    xmFunSDKManager.initLog();

    // /**
    // * 低功耗设备：包括 门铃、门锁等，需要调用此方法否则可能无法登录设备，其他设备无需调用
    // * Low-power devices: including doorbells, door locks, etc., you need to call
    // this method,
    // * otherwise you may not be able to log in to the device, and other devices do
    // not need to call
    // */
    FunSDK.SetFunIntAttr(EFUN_ATTR.SUP_RPS_VIDEO_DEFAULT, SDKCONST.Switch.Open);
  }
  // }

  /**
   * 用户主动重新初始化SDK - 使用自定义的AppKey、AppSecret等参数
   * Re-initialize SDK with custom AppKey, AppSecret and other parameters
   * 
   * @param params {
   *   appUuid: string,      // APP_UUID from open platform
   *   appKey: string,       // APP_KEY from open platform  
   *   appSecret: string,    // APP_SECRET from open platform
   *   appMovedCard: number, // APP_MOVECARD from open platform (usually 2)
   *   customPwdType: number (optional), // 加密类型 默认0
   *   customPwd: string (optional),     // 加密字段 默认""
   *   customServerAddr: string (optional), // P2P服务器域名或IP
   *   customPort: number (optional)     // P2P服务器端口
   * }
   */
  @ReactMethod
  public void reInitByUser(ReadableMap params) {
    // Позволяем пользователю полностью переинициализировать SDK c указанием
    // APP-ключей и (опционально) кастомного P2P-сервера.
    if (!ReactParamsCheck.checkParams(
        new String[] { Constants.APP_UUID, Constants.APP_KEY, Constants.APP_SECRET, Constants.APP_MOVEDCARD },
        params)) {
      Log.e("FunSDKCoreModule",
          "reInitByUser: Missing required parameters (appUuid, appKey, appSecret, appMovedCard)");
      return;
    }

    // Кастомный P2P-сервер (аналогично init)
    int customPwdType = 0;
    String customPwd = "";
    String customServerAddr = "";
    int customPort = 0;

    if (params != null) {
      try {
        if (params.hasKey("customPwdType") && !params.isNull("customPwdType")) {
          customPwdType = params.getInt("customPwdType");
        }
        if (params.hasKey("customPwd") && !params.isNull("customPwd")) {
          customPwd = params.getString("customPwd");
        }
        if (params.hasKey("customServerAddr") && !params.isNull("customServerAddr")) {
          customServerAddr = params.getString("customServerAddr");
        }
        if (params.hasKey("customPort") && !params.isNull("customPort")) {
          customPort = params.getInt("customPort");
        }
      } catch (Exception e) {
        Log.e("FunSDKCoreModule", "reInitByUser: Error reading custom server params", e);
      }
    }

    String appUuid = params.getString(Constants.APP_UUID);
    String appKey = params.getString(Constants.APP_KEY);
    String appSecret = params.getString(Constants.APP_SECRET);
    int appMovedCard = params.getInt(Constants.APP_MOVEDCARD);

    if (!TextUtils.isEmpty(customServerAddr) && customPort > 0) {
      xmFunSDKManager = XMFunSDKManager.getInstance(customPwdType, customPwd, customServerAddr, customPort);
      Log.d("FunSDKCoreModule",
          "reInitByUser: XMFunSDKManager instance created with custom server: " + customServerAddr + ":" + customPort
              + ", pwdType=" + customPwdType + ", pwdLen=" + (customPwd != null ? customPwd.length() : -1));
    } else {
      xmFunSDKManager = XMFunSDKManager.getInstance();
      Log.d("FunSDKCoreModule", "reInitByUser: XMFunSDKManager instance created with default server");
    }

    Log.d("FunSDKCoreModule",
        "reInitByUser: Initializing with UUID: " + appUuid + ", Key: " + appKey + ", MovedCard: " + appMovedCard);

    // Initialize with explicit parameters from user
    xmFunSDKManager.initXMCloudPlatform(reactContext, appUuid, appKey, appSecret, appMovedCard, true);
    xmFunSDKManager.initLog();
    FunSDK.SetFunIntAttr(EFUN_ATTR.SUP_RPS_VIDEO_DEFAULT, SDKCONST.Switch.Open);

    Log.d("FunSDKCoreModule", "reInitByUser: SDK re-initialized successfully");
  }

  /**
   * 更新区域代码并配置 MI_SERVER / CAPS_SERVER
   */
  @ReactMethod
  public void updateAreaCode(final Promise promise) {
    try {
      CountryCodeManager.getInstance().getSupportAreaCodeList("", new CountryCodeListener() {
        @Override
        public void onSupportAreaCodeList(PhoneRuleAndRegionBean phoneRuleAndRegion, int errorId) {
          if (errorId >= 0 && phoneRuleAndRegion != null && phoneRuleAndRegion.getDefaultCountry() != null) {
            String amsUrl = phoneRuleAndRegion.getDefaultCountry().getAmsUrl();
            String capsUrl = phoneRuleAndRegion.getDefaultCountry().getCapsUrl();

            Log.d("FunSDKCoreModule",
                "updateAreaCode: errorId=" + errorId + ", amsUrl=" + amsUrl + ", capsUrl=" + capsUrl);

            String miServer = !TextUtils.isEmpty(amsUrl) ? amsUrl : "https://rs.xmeye.net";
            String capsServer = !TextUtils.isEmpty(capsUrl) ? capsUrl : "https://caps.jftechws.com";

            FunSDK.SysSetServerIPPort("MI_SERVER", miServer, 443);
            FunSDK.SysSetServerIPPort("CAPS_SERVER", capsServer, 443);

            Log.d("FunSDKCoreModule",
                "updateAreaCode: MI_SERVER=" + miServer + ":443, CAPS_SERVER=" + capsServer + ":443");

            if (promise != null) {
              promise.resolve("success");
            }
          } else {
            if (promise != null) {
              promise.reject("AreaCodeError", "errorId=" + errorId);
            }
          }
        }
      });
    } catch (Throwable t) {
      if (promise != null) {
        promise.reject("updateAreaCode", t);
      }
    }
  }

  @ReactMethod
  public void SysSetServerIPPort(ReadableMap params) {
    if (ReactParamsCheck.checkParams(new String[] { "serverKey", "serverIpOrDomain", "serverPort" },
        params)) {
      String serverKey = params.getString("serverKey");
      String serverIpOrDomain = params.getString("serverIpOrDomain");
      int serverPort = params.getInt("serverPort");

      Log.d("FunSDKCoreModule",
          "SysSetServerIPPort: key=" + serverKey + ", addr=" + serverIpOrDomain + ", port=" + serverPort);
      xmFunSDKManager.sysSetServerIPPort(serverKey, serverIpOrDomain, serverPort);
    }
  }
}
