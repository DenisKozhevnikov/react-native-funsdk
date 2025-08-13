package com.funsdk;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.funsdk.core.FunSDKCoreModule;
import com.funsdk.user.register.FunSDKRegisterModule;
import com.funsdk.user.modify.FunSDKModifyModule;
import com.funsdk.user.login.FunSDKLoginModule;
import com.funsdk.user.info.FunSDKInfoModule;
import com.funsdk.user.forget.FunSDKForgetModule;
import com.funsdk.user.device.add.ap.FunSDKDevApConnectModule;
import com.funsdk.user.device.add.list.FunSDKDevListConnectModule;
import com.funsdk.user.device.add.quick.FunSDKDevQuickConnectModule;
import com.funsdk.user.device.add.share.FunSDKDevShareManagerModule;
import com.funsdk.user.device.add.qrcode.FunSDKDevQRCodeConnectModule;
import com.funsdk.user.device.add.sn.FunSDKDevSnConnectModule;
import com.funsdk.user.device.status.FunSDKDevStatusModule;
import com.funsdk.user.device.alarm.FunSDKDevAlarmModule;
import com.funsdk.manager.image.FunSDKDeviceImageModule;
import com.funsdk.manager.search.FunSDKDeviceSearchByTime;
import com.funsdk.manager.search.FunSDKDeviceFileSearch;
import com.funsdk.manager.push.FunSDKPushMessageModule;

import com.funsdk.player.FunSDKVideoPlayerManager;
import com.funsdk.ui.device.record.FunSDKRecordPlayerManager;

public class FunsdkPackage implements ReactPackage {
  @NonNull
  @Override
  public List<NativeModule> createNativeModules(@NonNull ReactApplicationContext reactContext) {
    List<NativeModule> modules = new ArrayList<>();
    // modules.add(new FunsdkModule(reactContext));
    modules.add(new FunSDKCoreModule(reactContext));
    modules.add(new FunSDKRegisterModule(reactContext));
    modules.add(new FunSDKModifyModule(reactContext));
    modules.add(new FunSDKLoginModule(reactContext));
    modules.add(new FunSDKInfoModule(reactContext));
    modules.add(new FunSDKForgetModule(reactContext));
    modules.add(new FunSDKDevApConnectModule(reactContext));
    modules.add(new FunSDKDevListConnectModule(reactContext));
    modules.add(new FunSDKDevSnConnectModule(reactContext));
    modules.add(new FunSDKDevStatusModule(reactContext));
    modules.add(new FunSDKDeviceImageModule(reactContext));
    modules.add(new FunSDKDeviceSearchByTime(reactContext));
    modules.add(new FunSDKDeviceFileSearch(reactContext));
    modules.add(new FunSDKDevQuickConnectModule(reactContext));
    modules.add(new FunSDKDevQRCodeConnectModule(reactContext));
    modules.add(new FunSDKPushMessageModule(reactContext));
    modules.add(new FunSDKDevShareManagerModule(reactContext));
    modules.add(new FunSDKDevAlarmModule(reactContext));

    return modules;
  }

  @NonNull
  @Override
  public List<ViewManager> createViewManagers(@NonNull ReactApplicationContext reactContext) {
    // return Collections.emptyList();
    List<ViewManager> viewManagers = new ArrayList<>();

    viewManagers.add(new FunSDKVideoPlayerManager(reactContext));
    viewManagers.add(new FunSDKRecordPlayerManager(reactContext));

    return viewManagers;
  }
}
