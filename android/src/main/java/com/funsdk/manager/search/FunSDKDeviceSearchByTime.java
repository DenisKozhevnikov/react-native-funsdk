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
    int channelId = params.getInt(Constants.DEVICE_CHANNEL); // 0 - default
    int fileType = params.getInt("fileType"); // 0 - SDK_RECORD_ALL
    int streamType = params.getInt("streamType"); // 0 - main(hd?) 1 - extra(sd?)
    int seq = params.getInt("seq");

    Calendar time = Calendar.getInstance();
    // Backward-compatible: allow either a numeric "time" or a structured "start" date
    try {
      if (params.hasKey("time")) {
        long timeLong = (long) params.getDouble("time");
        time.setTimeInMillis(timeLong);
      } else if (params.hasKey("start") && params.getMap("start") != null) {
        com.facebook.react.bridge.ReadableMap start = params.getMap("start");
        int year = start.hasKey("year") ? start.getInt("year") : time.get(Calendar.YEAR);
        int month = start.hasKey("month") ? start.getInt("month") : (time.get(Calendar.MONTH) + 1);
        int day = start.hasKey("day") ? start.getInt("day") : time.get(Calendar.DATE);
        int hour = start.hasKey("hour") ? start.getInt("hour") : 0;
        int minute = start.hasKey("minute") ? start.getInt("minute") : 0;
        int second = start.hasKey("second") ? start.getInt("second") : 0;

        // Calendar.MONTH is 0-based; incoming month is 1-based per TS docs
        time.set(Calendar.YEAR, year);
        time.set(Calendar.MONTH, Math.max(0, month - 1));
        time.set(Calendar.DATE, day);
        time.set(Calendar.HOUR_OF_DAY, hour);
        time.set(Calendar.MINUTE, minute);
        time.set(Calendar.SECOND, second);
        time.set(Calendar.MILLISECOND, 0);
      }
    } catch (Exception ignored) {
      // If anything goes wrong, keep current calendar (now)
    }

    SearchByTime searchByTime = new SearchByTime(devId, promise);

    searchByTime.searchFileByTime(
        time,
        streamType,
        channelId,
        fileType,
        seq);
  }
}
