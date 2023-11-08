package com.funsdk.utils;

import androidx.annotation.Nullable;
import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import com.manager.device.media.attribute.RecordPlayerAttribute;

import com.lib.sdk.struct.H264_DVR_FILE_DATA;

import java.util.Calendar;
import java.util.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class DataConverter {

  public static Date stringToDate(String time) {
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    try {
      Date date = dateFormat.parse(time);
      // System.out.println(date);
      if (null != date) {
        return date;
      }
    } catch (ParseException e) {
      e.printStackTrace();
      System.out.println("stringToDate error");
    }

    return Calendar.getInstance().getTime();
  }

  public static H264_DVR_FILE_DATA convertDataToH264(ReadableMap map) {

    String startTimeOfYear = map.getString("startTimeOfYear");
    String endTimeOfYear = map.getString("endTimeOfYear");
    int chnId = map.getInt("channel");
    int filesize = map.getInt("filesize");
    String filename = map.getString("filename");
    int streamType = map.getInt("streamType");
    int downloadStatus = map.getInt("downloadStatus");
    int downloadType = map.getInt("downloadType");
    boolean isChecked = map.getBoolean("isChecked");
    double currentPos = map.getDouble("currentPos");
    int seekPosition = map.getInt("seekPosition");
    boolean isEffective = map.getBoolean("isEffective");
    String alarmExFileInfo = map.getString("alarmExFileInfo");
    boolean recordLenTypeNormal = map.getBoolean("recordLenTypeNormal");
    RecordPlayerAttribute.RECORD_LEN_TYPE recordLenType = recordLenTypeNormal == true
        ? RecordPlayerAttribute.RECORD_LEN_TYPE.RECORD_LEN_NORMAL
        : RecordPlayerAttribute.RECORD_LEN_TYPE.RECORD_LEN_SHORT;
    Date sDate = stringToDate(startTimeOfYear);
    Date eDate = stringToDate(endTimeOfYear);

    H264_DVR_FILE_DATA data = new H264_DVR_FILE_DATA();
    // data.downloadType = Define.MEDIA_TYPE_CLOUD;

    data.st_3_beginTime.st_0_year = sDate.getYear() + 1900;
    data.st_3_beginTime.st_1_month = sDate.getMonth() + 1;
    data.st_3_beginTime.st_2_day = sDate.getDate();
    data.st_3_beginTime.st_4_hour = sDate.getHours();
    data.st_3_beginTime.st_5_minute = sDate.getMinutes();
    data.st_3_beginTime.st_6_second = sDate.getSeconds();
    data.st_4_endTime.st_0_year = eDate.getYear() + 1900;
    data.st_4_endTime.st_1_month = eDate.getMonth() + 1;
    data.st_4_endTime.st_2_day = eDate.getDate();
    data.st_4_endTime.st_4_hour = eDate.getHours();
    data.st_4_endTime.st_5_minute = eDate.getMinutes();
    data.st_4_endTime.st_6_second = eDate.getSeconds();
    data.st_2_fileName = filename.getBytes();
    data.st_1_size = filesize;
    data.st_6_StreamType = streamType;
    data.st_0_ch = chnId;
    data.downloadStatus = downloadStatus;
    data.downloadType = downloadType;
    data.isChecked = isChecked;
    data.currentPos = currentPos;
    data.seekPosition = seekPosition;
    data.isEffective = isEffective;
    data.setAlarmExFileInfo(alarmExFileInfo);
    data.setRecordLenType(recordLenType);

    return data;
  }

  public static HashMap<String, Object> parseToMap(ReadableMap readableMap) {
    ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
    HashMap<String, Object> deconstructedMap = new HashMap<>();
    while (iterator.hasNextKey()) {
      String key = iterator.nextKey();
      ReadableType type = readableMap.getType(key);
      switch (type) {
        case Null:
          deconstructedMap.put(key, null);
          break;
        case Boolean:
          deconstructedMap.put(key, readableMap.getBoolean(key));
          break;
        case Number:
          double value = readableMap.getDouble(key);
          try {
            // int和Long型支持，如果数字大于int, 且是整数
            if (value % 1 == 0) {
              if (value >= Integer.MIN_VALUE && value <= Integer.MAX_VALUE) {
                // int型支持
                deconstructedMap.put(key, (int) value);
              } else if (value > Integer.MAX_VALUE || value < Integer.MIN_VALUE) {
                // Long型支持，
                deconstructedMap.put(key, (long) value);
              }
            } else {
              deconstructedMap.put(key, value);
            }
          } catch (Exception e) {
            deconstructedMap.put(key, value);
          }
          break;
        case String:
          deconstructedMap.put(key, readableMap.getString(key));
          break;
        case Map:
          deconstructedMap.put(key, parseToMap(readableMap.getMap(key)));
          break;
        case Array:
          deconstructedMap.put(key, parseToList(readableMap.getArray(key)));
          break;
        default:
          // throw new IllegalArgumentException("Could not convert object with key: " +
          // key + ".");
      }

    }
    return deconstructedMap;
  }

  public static ArrayList<Object> parseToList(ReadableArray readableArray) {
    ArrayList<Object> deconstructedList = new ArrayList<>(readableArray.size());
    for (int i = 0; i < readableArray.size(); i++) {
      ReadableType indexType = readableArray.getType(i);
      switch (indexType) {
        case Null:
          deconstructedList.add(i, null);
          break;
        case Boolean:
          deconstructedList.add(i, readableArray.getBoolean(i));
          break;
        case Number:
          double value = readableArray.getDouble(i);
          try {
            // Long型支持，如果数字大于int, 且是整数,转化成long
            if (value % 1 == 0) {
              if (value >= Integer.MIN_VALUE && value <= Integer.MAX_VALUE) {
                // int型支持
                deconstructedList.add(i, (int) value);
              } else if (value > Integer.MAX_VALUE || value < Integer.MIN_VALUE) {
                // Long型支持，
                deconstructedList.add(i, (long) value);
              }
            } else {
              deconstructedList.add(i, value);
            }
          } catch (Exception e) {
            deconstructedList.add(i, value);
          }
          break;
        case String:
          deconstructedList.add(i, readableArray.getString(i));
          break;
        case Map:
          deconstructedList.add(i, parseToMap(readableArray.getMap(i)));
          break;
        case Array:
          deconstructedList.add(i, parseToList(readableArray.getArray(i)));
          break;
        default:
          // throw new IllegalArgumentException("Could not convert object at index " + i +
          // ".");
      }
    }
    return deconstructedList;
  }

  public static WritableMap parseToWritableMap(String s) {
    if (TextUtils.isEmpty(s))
      return Arguments.createMap();
    System.out.println("parseToWritableMap string to object: " + s);
    return parseToWritableMap(JSON.parseObject(s));
  }

  public static WritableMap parseToWritableMap(Object object) {
    if (null == object)
      return Arguments.createMap();
    return parseToWritableMap(JSON.toJSONString(object, SerializerFeature.DisableCircularReferenceDetect));
  }

  public static WritableMap parseToWritableMap(JSONObject json) {
    WritableMap map = Arguments.createMap();
    Set<Map.Entry<String, Object>> entries = json.entrySet();
    for (Map.Entry<String, Object> next : entries) {
      String key = next.getKey();
      Object obv = next.getValue();
      if (obv instanceof JSONObject) {
        map.putMap(key, parseToWritableMap((JSONObject) obv));
      } else if (obv instanceof Integer) {
        map.putInt(key, (Integer) obv);
      } else if (obv instanceof String) {
        map.putString(key, String.valueOf(obv));
      } else if (obv instanceof Boolean) {
        map.putBoolean(key, (Boolean) obv);
      } else if (obv instanceof Double) {
        map.putDouble(key, (Double) obv);
      } else if (obv instanceof JSONArray) {
        map.putArray(key, parseToWritableArray((JSONArray) obv));
      } else {
        map.putNull(key);
      }
    }
    return map;
  }

  public static WritableArray parseToWritableArray(JSONArray jsonArray) {
    WritableArray list = Arguments.createArray();
    for (Object obv : jsonArray.toArray()) {
      if (obv instanceof JSONObject) {
        list.pushMap(parseToWritableMap((JSONObject) obv));
      } else if (obv instanceof Integer) {
        list.pushInt((Integer) obv);
      } else if (obv instanceof String) {
        list.pushString(String.valueOf(obv));
      } else if (obv instanceof Boolean) {
        list.pushBoolean((Boolean) obv);
      } else if (obv instanceof Double) {
        list.pushDouble((Double) obv);
      } else if (obv instanceof JSONArray) {
        list.pushArray(list);
      } else {
        list.pushNull();
      }
    }
    return list;

  }

  public static WritableMap panelConfigToWritableMap(Map<String, Object> panelConfig) {
    WritableMap list = Arguments.createMap();

    if (panelConfig != null) {
      for (Map.Entry<String, Object> set : panelConfig.entrySet()) {
        String key = set.getKey();
        Object value = set.getValue();

        list.putString(key, value == null ? "" : JSONObject.toJSONString(value));
      }
    }
    return list;
  }
}
