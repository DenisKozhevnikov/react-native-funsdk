package com.funsdk.core;

import static com.lib.EFUN_ATTR.LOGIN_SUP_RSA_ENC;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;

import com.lib.EFUN_ATTR;
import com.lib.FunSDK;
import com.lib.SDKCONST;
import com.manager.XMFunSDKManager;

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
    if (ReactParamsCheck.checkParamsV2(
        new String[] { Constants.APP_CUSTOM_PWD_TYPE, Constants.APP_CUSTOM_PWD, Constants.APP_CUSTOM_SERVER_ADDR,
            Constants.APP_CUSTOM_CUSTOM_PORT },
        params)) {
      int customPwdType = params.getInt(Constants.APP_CUSTOM_PWD_TYPE); // 0
      String customPwd = params.getString(Constants.APP_CUSTOM_PWD);
      String customServerAddr = params.getString(Constants.APP_CUSTOM_SERVER_ADDR);
      int customPort = params.getInt(Constants.APP_CUSTOM_CUSTOM_PORT);
      xmFunSDKManager = XMFunSDKManager.getInstance(customPwdType, customPwd, customServerAddr, customPort);
    } else {
      xmFunSDKManager = XMFunSDKManager.getInstance();
    }

    // public void init(String name, String location) {
    xmFunSDKManager.initXMCloudPlatform(reactContext);

    // uuid, key, secret, movedcard in AndroidManifest.xml
    // https://libraries.io/maven/io.github.xmcamera:libxmfunsdk - 2 paragraph
    // xmFunSDKManager.initXMCloudPlatform(
    // reactContext,
    // params.getString(Constants.APP_UUID),
    // params.getString(Constants.APP_KEY),
    // params.getString(Constants.APP_SECRET),
    // params.getInt(Constants.APP_MOVEDCARD),
    // true);

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

}
