package com.funsdk.ui.device.record;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;
import java.util.HashMap;
import java.util.Calendar;

import javax.annotation.Nullable;

public class FunSDKRecordPlayerManager extends SimpleViewManager<FunSDKRecordView> {
  public static final String REACT_CLASS = "RCTDevRecordMonitor";

  // понять надо ли это?
  ReactApplicationContext mCallerContext;

  // // понять надо ли это?
  public FunSDKRecordPlayerManager(ReactApplicationContext reactContext) {
    super();
    mCallerContext = reactContext;
  }

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  protected FunSDKRecordView createViewInstance(ThemedReactContext context) {
    return new FunSDKRecordView(context);
  }

  @Override
  public @Nullable Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
    for (String event : RecordEventEmitter.Events) {
      builder.put(event, MapBuilder.of("registrationName", event));
    }
    return builder.build();
  }

  @ReactProp(name = "devId")
  public void setDeviceId(FunSDKRecordView view, String devId) {
    // view.init(devId);
    view.setDevId(devId);
  }

  @ReactProp(name = "channelId")
  public void setDeviceId(FunSDKRecordView view, int channelId) {
    // view.init(devId);
    view.setChannelId(channelId);
  }

  private static final String COMMAND_INIT_RECORD = "init"; // +
  private static final int COMMAND_INIT_RECORD_ID = 9999;
  // не стоит использовать?
  private static final String COMMAND_START_PLAY_RECORD = "startPlayRecord"; // +
  private static final int COMMAND_START_PLAY_RECORD_ID = 1;
  private static final String COMMAND_SEARCH_RECORD_BY_FILE = "searchRecordByFile";
  private static final int COMMAND_SEARCH_RECORD_BY_FILE_ID = 2;
  private static final String COMMAND_CAPTURE = "capture";
  private static final int COMMAND_CAPTURE_ID = 3;
  private static final String COMMAND_START_RECORD = "startRecord";
  private static final int COMMAND_START_RECORD_ID = 4;
  private static final String COMMAND_STOP_RECORD = "stopRecord";
  private static final int COMMAND_STOP_RECORD_ID = 5;
  private static final String COMMAND_IS_RECORDING = "isRecording";
  private static final int COMMAND_IS_RECORDING_ID = 6;
  private static final String COMMAND_OPEN_VOICE = "openVoice";
  private static final int COMMAND_OPEN_VOICE_ID = 7;
  private static final String COMMAND_CLOSE_VOICE = "closeVoice";
  private static final int COMMAND_CLOSE_VOICE_ID = 8;
  private static final String COMMAND_PAUSE_PLAY = "pausePlay";
  private static final int COMMAND_PAUSE_PLAY_ID = 9;
  private static final String COMMAND_RE_PLAY = "rePlay";
  private static final int COMMAND_RE_PLAY_ID = 10;
  private static final String COMMAND_STOP_PLAY = "stopPlay";
  private static final int COMMAND_STOP_PLAY_ID = 11;
  private static final String COMMAND_DESTROY_PLAY = "destroyPlay";
  private static final int COMMAND_DESTROY_PLAY_ID = 12;
  private static final String COMMAND_IS_RECORD_PLAY = "isRecordPlay";
  private static final int COMMAND_IS_RECORD_PLAY_ID = 13;
  private static final String COMMAND_DOWNLOAD_FILE = "downloadFile";
  private static final int COMMAND_DOWNLOAD_FILE_ID = 14;
  private static final String COMMAND_SET_PLAY_SPEED = "setPlaySpeed";
  private static final int COMMAND_SET_PLAY_SPEED_ID = 15;
  // private static final String COMMAND_SEARCH_RECORD_FILE_BY_TIME =
  // "searchRecordFileByTime";
  // private static final int COMMAND_SEARCH_RECORD_FILE_BY_TIME_ID = 16;
  private static final String COMMAND_START_PLAY_RECORD_BY_TIME = "startPlayRecordByTime";
  private static final int COMMAND_START_PLAY_RECORD_BY_TIME_ID = 16;

  @Override
  public Map<String, Integer> getCommandsMap() {
    Map<String, Integer> commandsMap = new HashMap<>();
    commandsMap.put(COMMAND_INIT_RECORD, COMMAND_INIT_RECORD_ID);
    commandsMap.put(COMMAND_START_PLAY_RECORD, COMMAND_START_PLAY_RECORD_ID);
    commandsMap.put(COMMAND_SEARCH_RECORD_BY_FILE, COMMAND_SEARCH_RECORD_BY_FILE_ID);
    commandsMap.put(COMMAND_CAPTURE, COMMAND_CAPTURE_ID);
    commandsMap.put(COMMAND_START_RECORD, COMMAND_START_RECORD_ID);
    commandsMap.put(COMMAND_STOP_RECORD, COMMAND_STOP_RECORD_ID);
    commandsMap.put(COMMAND_IS_RECORDING, COMMAND_IS_RECORDING_ID);
    commandsMap.put(COMMAND_OPEN_VOICE, COMMAND_OPEN_VOICE_ID);
    commandsMap.put(COMMAND_CLOSE_VOICE, COMMAND_CLOSE_VOICE_ID);
    commandsMap.put(COMMAND_PAUSE_PLAY, COMMAND_PAUSE_PLAY_ID);
    commandsMap.put(COMMAND_RE_PLAY, COMMAND_RE_PLAY_ID);
    commandsMap.put(COMMAND_STOP_PLAY, COMMAND_STOP_PLAY_ID);
    commandsMap.put(COMMAND_DESTROY_PLAY, COMMAND_DESTROY_PLAY_ID);
    commandsMap.put(COMMAND_IS_RECORD_PLAY, COMMAND_IS_RECORD_PLAY_ID);
    commandsMap.put(COMMAND_DOWNLOAD_FILE, COMMAND_DOWNLOAD_FILE_ID);
    commandsMap.put(COMMAND_SET_PLAY_SPEED, COMMAND_SET_PLAY_SPEED_ID);
    // commandsMap.put(COMMAND_SEARCH_RECORD_FILE_BY_TIME,
    // COMMAND_SEARCH_RECORD_FILE_BY_TIME_ID);
    commandsMap.put(COMMAND_START_PLAY_RECORD_BY_TIME, COMMAND_START_PLAY_RECORD_BY_TIME_ID);

    return commandsMap;
  }

  @Override
  public void receiveCommand(FunSDKRecordView view, int commandId, ReadableArray args) {
    if (commandId == COMMAND_INIT_RECORD_ID) {
      view.init();
    }

    if (commandId == COMMAND_START_PLAY_RECORD_ID) {
      int position = args.getInt(0);
      view.startPlayRecord(position);
    }

    if (commandId == COMMAND_SEARCH_RECORD_BY_FILE_ID) {
      long startLong = (long) args.getDouble(0);
      long endLong = (long) args.getDouble(1);

      Calendar startTime = Calendar.getInstance();
      startTime.setTimeInMillis(startLong);
      Calendar endTime = Calendar.getInstance();
      endTime.setTimeInMillis(endLong);

      // for onDebugState
      int year = startTime.get(Calendar.YEAR);
      int month = startTime.get(Calendar.MONTH);
      int day = startTime.get(Calendar.DATE);
      int hour = startTime.get(Calendar.HOUR_OF_DAY);
      int minutes = startTime.get(Calendar.MINUTE);

      view.onDebugState(
          "searchRecordByFile start - startLong: " + startLong + " year: " + year + " month: " + month + " day: "
              + day + " hour: " + hour + " minutes: " + minutes);
      view.searchRecordByFile(startTime, endTime);
      // view.searchRecordByTime(startTime);
    }

    // if (commandId == COMMAND_SEARCH_RECORD_FILE_BY_TIME_ID) {
    // long startLong = (long) args.getDouble(0);

    // Calendar startTime = Calendar.getInstance();
    // startTime.setTimeInMillis(startLong);

    // // for onDebugState
    // int year = startTime.get(Calendar.YEAR);
    // int month = startTime.get(Calendar.MONTH);
    // int day = startTime.get(Calendar.DATE);
    // int hour = startTime.get(Calendar.HOUR_OF_DAY);
    // int minutes = startTime.get(Calendar.MINUTE);
    // view.onDebugState(
    // "searchRecordFileByTime start - startLong: " + startLong + " year: " + year +
    // " month: " + month + " day: "
    // + day + " hour: " + hour + " minutes: " + minutes);

    // view.searchRecordByTime(startTime);
    // }

    if (commandId == COMMAND_CAPTURE_ID) {
      String path = args.getString(0);
      String savedPath = view.capture(path);
      view.onCapture(savedPath);
    }

    if (commandId == COMMAND_START_RECORD_ID) {
      String path = args.getString(0);
      view.startRecord(path);
    }

    if (commandId == COMMAND_STOP_RECORD_ID) {
      view.stopRecord();
    }

    if (commandId == COMMAND_IS_RECORDING_ID) {
      view.isRecording();
    }

    if (commandId == COMMAND_OPEN_VOICE_ID) {
      view.openVoice();
    }

    if (commandId == COMMAND_CLOSE_VOICE_ID) {
      view.closeVoice();
    }

    if (commandId == COMMAND_PAUSE_PLAY_ID) {
      view.pausePlay();
    }

    if (commandId == COMMAND_RE_PLAY_ID) {
      view.rePlay();
    }

    if (commandId == COMMAND_STOP_PLAY_ID) {
      view.stopPlay();
    }

    if (commandId == COMMAND_DESTROY_PLAY_ID) {
      view.destroyPlay();
    }

    if (commandId == COMMAND_IS_RECORD_PLAY_ID) {
      view.isRecordPlay();
    }

    if (commandId == COMMAND_DOWNLOAD_FILE_ID) {
      int position = args.getInt(0);
      String path = args.getString(1);
      view.downloadFile(position, path);
    }

    // from -3 to +3 or -4+4
    if (commandId == COMMAND_SET_PLAY_SPEED_ID) {
      int playSpeed = args.getInt(0);
      view.setPlaySpeed(playSpeed);
    }

    if (commandId == COMMAND_START_PLAY_RECORD_BY_TIME_ID) {
      long startLong = (long) args.getDouble(0);
      long endLong = (long) args.getDouble(1);

      Calendar startTime = Calendar.getInstance();
      startTime.setTimeInMillis(startLong);
      Calendar endTime = Calendar.getInstance();
      endTime.setTimeInMillis(endLong);

      // for onDebugState
      int year = startTime.get(Calendar.YEAR);
      int month = startTime.get(Calendar.MONTH);
      int day = startTime.get(Calendar.DATE);
      int hour = startTime.get(Calendar.HOUR_OF_DAY);
      int minutes = startTime.get(Calendar.MINUTE);
      int second = startTime.get(Calendar.SECOND);

      view.onDebugState(
          "startPlayRecord start - startLong: " + startLong + " year: " + year + " month: " + month + " day: "
              + day + " hour: " + hour + " minutes: " + minutes + " second: " + second);

      // for onDebugState
      int year2 = endTime.get(Calendar.YEAR);
      int month2 = endTime.get(Calendar.MONTH);
      int day2 = endTime.get(Calendar.DATE);
      int hour2 = endTime.get(Calendar.HOUR_OF_DAY);
      int minutes2 = endTime.get(Calendar.MINUTE);
      int second2 = endTime.get(Calendar.SECOND);

      view.onDebugState(
          "startPlayRecord end - endLong: " + endLong + " year: " + year2 + " month: " + month2 + " day: "
              + day2 + " hour: " + hour2 + " minutes: " + minutes2 + " second2: " + second2);

      view.startPlayRecord(startTime, endTime);
    }
  }

}
