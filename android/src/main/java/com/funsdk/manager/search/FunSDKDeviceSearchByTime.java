package com.funsdk.manager.search;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Arguments;

import com.basic.G;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FINDINFO;
import com.lib.sdk.struct.SDK_SearchByTime;
import com.lib.sdk.struct.SDK_SearchByTimeResult;

import com.funsdk.utils.Constants;

import java.util.Calendar;

public class FunSDKDeviceSearchByTime extends ReactContextBaseJavaModule {
  private ReactApplicationContext reactContext;

  @Override
  public String getName() {
    return "FunSDKDeviceSearchByTime";
  }

  public FunSDKDeviceSearchByTime(ReactApplicationContext context) {
    super(context);
    reactContext = context;
  }

  @ReactMethod
  public void searchTimeinfo(ReadableMap params, Promise promise) {
    String devId = params.getString(Constants.DEVICE_ID);
    long timeLong = (long) params.getDouble("time");
    int channelId = params.getInt(Constants.DEVICE_CHANNEL); // 0 - default
    int fileType = params.getInt("fileType"); // 0 - SDK_RECORD_ALL
    int streamType = params.getInt("streamType"); // 0 - main(hd?) 1 - extra(sd?)
    int seq = params.getInt("seq");

    Calendar time = Calendar.getInstance();
    time.setTimeInMillis(timeLong);

    SearchByTime searchByTime = new SearchByTime(devId, promise);

    searchByTime.searchFileByTime(
        time,
        streamType,
        channelId,
        fileType,
        seq);
  }
}
