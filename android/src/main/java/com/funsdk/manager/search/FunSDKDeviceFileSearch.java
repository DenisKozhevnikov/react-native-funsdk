package com.funsdk.manager.search;

import android.os.Message;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;

import com.basic.G;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.lib.sdk.struct.H264_DVR_FINDINFO;

import com.funsdk.utils.Constants;
import com.funsdk.utils.enums.EUIMSG;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class FunSDKDeviceFileSearch extends ReactContextBaseJavaModule implements IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private final Map<Integer, Promise> seqToPromise = new HashMap<>();
  private int userId = 0;
  private int seqCounter = 1;

  public FunSDKDeviceFileSearch(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    // Avoid calling FunSDK.GetId on create_react_context thread (no Looper).
    // Initialize lazily on main thread inside method call.
  }

  @Override
  public String getName() {
    return "FunSDKDeviceFileSearch";
  }

  @ReactMethod
  public void searchDeviceFilesByDate(ReadableMap params, Promise promise) {
    try {
      final String devId = params.getString(Constants.DEVICE_ID);
      final int channel = params.getInt(Constants.DEVICE_CHANNEL);
      final int fileType = params.getInt("fileType");
      final int maxFileCount = params.getInt("maxFileCount");
      final int timeoutIn = params.getInt("timeout");
      final int streamType = params.hasKey("streamType") ? params.getInt("streamType") : 0;
      final String fileName = params.hasKey("fileName") ? params.getString("fileName") : null;

      final ReadableMap start = params.getMap("start");
      final ReadableMap end = params.getMap("end");

      final int seq = ++seqCounter;
      seqToPromise.put(seq, promise);

      UiThreadUtil.runOnUiThread(() -> {
        try {
          if (userId == 0) {
            userId = FunSDK.GetId(userId, this);
          }

          H264_DVR_FINDINFO info = new H264_DVR_FINDINFO();
          info.st_0_nChannelN0 = channel;
          info.st_1_nFileType = fileType;
          info.st_6_StreamType = streamType;

          if (fileName != null) {
            try {
              java.lang.reflect.Field f = info.getClass().getDeclaredField("st_5_szFileName");
              f.setAccessible(true);
              byte[] nameBytes = fileName.getBytes();
              f.set(info, nameBytes);
            } catch (Throwable ignored) {}
          }

          // start
          info.st_2_startTime.st_0_dwYear = start.getInt("year");
          info.st_2_startTime.st_1_dwMonth = start.getInt("month");
          info.st_2_startTime.st_2_dwDay = start.getInt("day");
          info.st_2_startTime.st_3_dwHour = start.getInt("hour");
          info.st_2_startTime.st_4_dwMinute = start.getInt("minute");
          info.st_2_startTime.st_5_dwSecond = start.getInt("second");

          // end
          info.st_3_endTime.st_0_dwYear = end.getInt("year");
          info.st_3_endTime.st_1_dwMonth = end.getInt("month");
          info.st_3_endTime.st_2_dwDay = end.getInt("day");
          info.st_3_endTime.st_3_dwHour = end.getInt("hour");
          info.st_3_endTime.st_4_dwMinute = end.getInt("minute");
          info.st_3_endTime.st_5_dwSecond = end.getInt("second");

          int effectiveTimeout = timeoutIn < 15000 ? 15000 : timeoutIn;
          FunSDK.DevFindFile(userId, devId, G.ObjToBytes(info), maxFileCount, effectiveTimeout, seq);
        } catch (Throwable t) {
          Promise p = seqToPromise.remove(seq);
          if (p != null) {
            p.reject("searchDeviceFilesByDate_error", t);
          }
        }
      });
    } catch (Exception e) {
      promise.reject("searchDeviceFilesByDate_error", e);
    }
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    if (msg.what == EUIMSG.DEV_FIND_FILE) {
      // Use MsgContent.seq for reliable sequence retrieval
      Promise promise = null;
      if (ex != null) {
        promise = seqToPromise.remove(ex.seq);
      }
      if (promise == null) {
        promise = seqToPromise.remove(msg.arg2);
      }
      if (promise == null) {
        return 0;
      }

      if (msg.arg1 < 0) {
        promise.reject("searchDeviceFilesByDate_error", msg.what + " " + msg.arg1);
        return 0;
      }

      int fileCount = msg.arg1;
      if (fileCount <= 0) {
        promise.resolve(Arguments.createArray());
        return 0;
      }

      H264_DVR_FILE_DATA[] datas = new H264_DVR_FILE_DATA[fileCount];
      for (int i = 0; i < datas.length; i++) {
        datas[i] = new H264_DVR_FILE_DATA();
      }
      G.BytesToObj(datas, ex.pData);

      WritableArray results = Arguments.createArray();
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);

      for (H264_DVR_FILE_DATA file : datas) {
        WritableMap item = Arguments.createMap();
        try {
          // channel and size
          int channel = 0;
          try { channel = (int) file.getClass().getField("st_0_ch").get(file); } catch (Throwable ignored) {}
          int size = 0;
          try { size = (int) file.getClass().getField("st_1_size").get(file); } catch (Throwable ignored) {}

          String fileName = null;
          try { fileName = file.getFileName(); } catch (Throwable ignored) {}
          if (fileName == null) {
            try {
              Object raw = file.getClass().getField("sFileName").get(file);
              fileName = raw != null ? raw.toString() : "";
            } catch (Throwable ignored2) {
              fileName = "";
            }
          }

          int streamType = 0;
          try { streamType = file.getStreamType(); } catch (Throwable ignored) {}

          item.putInt("channel", channel);
          item.putInt("size", size);
          item.putString("fileName", fileName);
          item.putInt("streamType", streamType);

          // start/end time via string parsing
          String startStr = null;
          String endStr = null;
          try { startStr = file.getStartTimeOfYear(); } catch (Throwable ignored) {}
          try { endStr = file.getEndTimeOfYear(); } catch (Throwable ignored) {}

          WritableMap start = Arguments.createMap();
          WritableMap end = Arguments.createMap();

          if (startStr != null) {
            Calendar c = Calendar.getInstance();
            try { c.setTime(df.parse(startStr)); } catch (ParseException ignored) {}
            start.putInt("year", c.get(Calendar.YEAR));
            start.putInt("month", c.get(Calendar.MONTH) + 1);
            start.putInt("day", c.get(Calendar.DAY_OF_MONTH));
            start.putInt("hour", c.get(Calendar.HOUR_OF_DAY));
            start.putInt("minute", c.get(Calendar.MINUTE));
            start.putInt("second", c.get(Calendar.SECOND));
          }

          if (endStr != null) {
            Calendar c2 = Calendar.getInstance();
            try { c2.setTime(df.parse(endStr)); } catch (ParseException ignored) {}
            end.putInt("year", c2.get(Calendar.YEAR));
            end.putInt("month", c2.get(Calendar.MONTH) + 1);
            end.putInt("day", c2.get(Calendar.DAY_OF_MONTH));
            end.putInt("hour", c2.get(Calendar.HOUR_OF_DAY));
            end.putInt("minute", c2.get(Calendar.MINUTE));
            end.putInt("second", c2.get(Calendar.SECOND));
          }

          item.putMap("startTime", start);
          item.putMap("endTime", end);
        } catch (Throwable t) {
          // in case of unexpected struct mismatch, still push minimal info
        }

        results.pushMap(item);
      }

      promise.resolve(results);
      return 0;
    }
    return 0;
  }
}

