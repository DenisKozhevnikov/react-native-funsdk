package com.funsdk.utils;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class EventSender {
  // используется для того чтобы отсылать event на react native
  // https://reactnative.dev/docs/native-modules-android#sending-events-to-javascript
  public static void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
    reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
  }
}
