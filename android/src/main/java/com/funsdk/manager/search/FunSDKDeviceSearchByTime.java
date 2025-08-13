package com.funsdk.manager.search;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
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

    int channelId = 0;
    try {
      if (params.hasKey(Constants.DEVICE_CHANNEL)) {
        if (params.getType(Constants.DEVICE_CHANNEL) == ReadableType.Number) {
          channelId = params.getInt(Constants.DEVICE_CHANNEL);
        } else if (params.getType(Constants.DEVICE_CHANNEL) == ReadableType.String) {
          channelId = Integer.parseInt(params.getString(Constants.DEVICE_CHANNEL));
        }
      }
    } catch (Exception ignored) {
    }

    int fileType = 0; // SDK_RECORD_ALL
    try {
      if (params.hasKey("fileType")) {
        if (params.getType("fileType") == ReadableType.Number) {
          fileType = params.getInt("fileType");
        } else if (params.getType("fileType") == ReadableType.String) {
          fileType = Integer.parseInt(params.getString("fileType"));
        }
      }
    } catch (Exception ignored) {
    }

    int streamType = 0; // 0 - main(hd?) 1 - extra(sd?)
    try {
      if (params.hasKey("streamType")) {
        if (params.getType("streamType") == ReadableType.Number) {
          streamType = params.getInt("streamType");
        } else if (params.getType("streamType") == ReadableType.String) {
          streamType = Integer.parseInt(params.getString("streamType"));
        }
      }
    } catch (Exception ignored) {
    }

    int seq = 0;
    try {
      if (params.hasKey("seq")) {
        if (params.getType("seq") == ReadableType.Number) {
          seq = params.getInt("seq");
        } else if (params.getType("seq") == ReadableType.String) {
          seq = Integer.parseInt(params.getString("seq"));
        }
      }
    } catch (Exception ignored) {
    }

    Calendar time = Calendar.getInstance();
    // Backward-compatible: allow either a numeric/string "time",
    // a structured "time" map, or a structured "start" date
    try {
      if (params.hasKey("time")) {
        ReadableType t = params.getType("time");
        if (t == ReadableType.Number) {
          long timeLong = (long) params.getDouble("time");
          time.setTimeInMillis(timeLong);
        } else if (t == ReadableType.String) {
          long timeLong = Long.parseLong(params.getString("time"));
          time.setTimeInMillis(timeLong);
        } else if (t == ReadableType.Map) {
          com.facebook.react.bridge.ReadableMap start = params.getMap("time");
          applyStartMapToCalendar(time, start);
        }
      } else if (params.hasKey("start") && params.getType("start") == ReadableType.Map) {
        com.facebook.react.bridge.ReadableMap start = params.getMap("start");
        applyStartMapToCalendar(time, start);
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

  private void applyStartMapToCalendar(Calendar time, ReadableMap start) {
    try {
      int year = start.hasKey("year") && start.getType("year") == ReadableType.Number ? start.getInt("year") : time.get(Calendar.YEAR);
      int month = start.hasKey("month") && start.getType("month") == ReadableType.Number ? start.getInt("month") : (time.get(Calendar.MONTH) + 1);
      int day = start.hasKey("day") && start.getType("day") == ReadableType.Number ? start.getInt("day") : time.get(Calendar.DATE);
      int hour = start.hasKey("hour") && start.getType("hour") == ReadableType.Number ? start.getInt("hour") : 0;
      int minute = start.hasKey("minute") && start.getType("minute") == ReadableType.Number ? start.getInt("minute") : 0;
      int second = start.hasKey("second") && start.getType("second") == ReadableType.Number ? start.getInt("second") : 0;

      // Calendar.MONTH is 0-based; incoming month is 1-based per TS docs
      time.set(Calendar.YEAR, year);
      time.set(Calendar.MONTH, Math.max(0, month - 1));
      time.set(Calendar.DATE, day);
      time.set(Calendar.HOUR_OF_DAY, hour);
      time.set(Calendar.MINUTE, minute);
      time.set(Calendar.SECOND, second);
      time.set(Calendar.MILLISECOND, 0);
    } catch (Exception ignored) {
    }
  }
}
