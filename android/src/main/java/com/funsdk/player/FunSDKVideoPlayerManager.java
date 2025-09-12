package com.funsdk.player;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;
import java.util.HashMap;
import javax.annotation.Nullable;

public class FunSDKVideoPlayerManager extends SimpleViewManager<FunSDKVideoView> {

  public static final String REACT_CLASS = "RCTMonitor";
  // private static final String COMMAND_SET_VIDEO_FLIP = "setVideoFlip";
  // private static final int COMMAND_SET_VIDEO_FLIP_ID = 1;
  private static final String COMMAND_START_MONITOR = "startMonitor";
  private static final int COMMAND_START_MONITOR_ID = 2;
  private static final String COMMAND_PAUSE_MONITOR = "pauseMonitor";
  private static final int COMMAND_PAUSE_MONITOR_ID = 3;
  private static final String COMMAND_REPLAY_MONITOR = "replayMonitor";
  private static final int COMMAND_REPLAY_MONITOR_ID = 4;
  private static final String COMMAND_STOP_MONITOR = "stopMonitor";
  private static final int COMMAND_STOP_MONITOR_ID = 5;
  private static final String COMMAND_DESTROY_MONITOR = "destroyMonitor";
  private static final int COMMAND_DESTROY_MONITOR_ID = 5;
  private static final String COMMAND_CAPTURE_IMAGE = "captureImage";
  private static final int COMMAND_CAPTURE_IMAGE_ID = 6;
  private static final String COMMAND_START_VIDEO_RECORD = "startVideoRecord";
  private static final int COMMAND_START_VIDEO_RECORD_ID = 7;
  private static final String COMMAND_STOP_VIDEO_RECORD = "stopVideoRecord";
  private static final int COMMAND_STOP_VIDEO_RECORD_ID = 8;
  private static final String COMMAND_OPEN_VOICE = "openVoice";
  private static final int COMMAND_OPEN_VOICE_ID = 9;
  private static final String COMMAND_CLOSE_VOICE = "closeVoice";
  private static final int COMMAND_CLOSE_VOICE_ID = 10;
  // private static final String COMMAND_SET_SPEAKER_TYPE = "setSpeakerType";
  // private static final int COMMAND_SET_SPEAKER_TYPE_ID = 11;
  private static final String COMMAND_START_SINGLE_INTERCOM_AND_SPEAK = "startSingleIntercomAndSpeak";
  private static final int COMMAND_START_SINGLE_INTERCOM_AND_SPEAK_ID = 12;
  private static final String COMMAND_STOP_SINGLE_INTERCOM_AND_SPEAK = "stopSingleIntercomAndSpeak";
  private static final int COMMAND_STOP_SINGLE_INTERCOM_AND_SPEAK_ID = 13;
  private static final String COMMAND_START_DOUBLE_INTERCOM = "startDoubleIntercom";
  private static final int COMMAND_START_DOUBLE_INTERCOM_ID = 14;
  private static final String COMMAND_STOP_DOUBLE_INTERCOM = "stopDoubleIntercom";
  private static final int COMMAND_STOP_DOUBLE_INTERCOM_ID = 15;
  private static final String COMMAND_SWTICH_STREAM_TYPE_MONITOR = "switchStreamTypeMonitor";
  private static final int COMMAND_SWTICH_STREAM_TYPE_MONITOR_ID = 16;
  private static final String COMMAND_UPDATE_STREAM_TYPE_MONITOR = "updateStreamTypeMonitor";
  private static final int COMMAND_UPDATE_STREAM_TYPE_MONITOR_ID = 161;
  private static final String COMMAND_SET_VIDEO_FULLSCREEN = "setVideoFullScreen";
  private static final int COMMAND_SET_VIDEO_FULLSCREEN_ID = 1600;
  private static final String COMMAND_CAPTURE_PIC_FROM_DEV_AND_SAVE = "capturePicFromDevAndSave";
  private static final int COMMAND_CAPTURE_PIC_FROM_DEV_AND_SAVE_ID = 17;
  private static final String COMMAND_GET_STREAM_TYPE = "getStreamType";
  private static final int COMMAND_GET_STREAM_TYPE_ID = 18;
  // private static final String COMMAND_SEEK_TO_TIME = "seekToTime";
  // private static final int COMMAND_SEEK_TO_TIME_ID = 19;
  // private static final String COMMAND_CHANGE_VIDEO_RATIO = "changeVideoRatio";
  // private static final int COMMAND_CHANGE_VIDEO_RATIO_ID = 20;

  ReactApplicationContext mCallerContext;

  public FunSDKVideoPlayerManager(ReactApplicationContext reactContext) {
    mCallerContext = reactContext;
  }

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public FunSDKVideoView createViewInstance(ThemedReactContext context) {
    return new FunSDKVideoView(context);
  }

  @Override
  public @Nullable Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
    for (String event : FunSDKVideoEventEmitter.Events) {
      builder.put(event, MapBuilder.of("registrationName", event));
    }
    return builder.build();
  }

  // region Direct manipulation with ref
  @Override
  public Map<String, Integer> getCommandsMap() {
    Map<String, Integer> commandsMap = new HashMap<>();
    // commandsMap.put(COMMAND_SET_VIDEO_FLIP, COMMAND_SET_VIDEO_FLIP_ID);
    commandsMap.put(COMMAND_START_MONITOR, COMMAND_START_MONITOR_ID);
    commandsMap.put(COMMAND_PAUSE_MONITOR, COMMAND_PAUSE_MONITOR_ID);
    commandsMap.put(COMMAND_REPLAY_MONITOR, COMMAND_REPLAY_MONITOR_ID);
    commandsMap.put(COMMAND_STOP_MONITOR, COMMAND_STOP_MONITOR_ID);
    commandsMap.put(COMMAND_DESTROY_MONITOR, COMMAND_DESTROY_MONITOR_ID);
    commandsMap.put(COMMAND_CAPTURE_IMAGE, COMMAND_CAPTURE_IMAGE_ID);
    commandsMap.put(COMMAND_START_VIDEO_RECORD, COMMAND_START_VIDEO_RECORD_ID);
    commandsMap.put(COMMAND_STOP_VIDEO_RECORD, COMMAND_STOP_VIDEO_RECORD_ID);
    commandsMap.put(COMMAND_GET_STREAM_TYPE, COMMAND_GET_STREAM_TYPE_ID);
    // commandsMap.put(COMMAND_SEEK_TO_TIME, COMMAND_SEEK_TO_TIME_ID);
    commandsMap.put(COMMAND_OPEN_VOICE, COMMAND_OPEN_VOICE_ID);
    commandsMap.put(COMMAND_CLOSE_VOICE, COMMAND_CLOSE_VOICE_ID);
    // commandsMap.put(COMMAND_SET_SPEAKER_TYPE, COMMAND_SET_SPEAKER_TYPE_ID);
    commandsMap.put(COMMAND_START_SINGLE_INTERCOM_AND_SPEAK, COMMAND_START_SINGLE_INTERCOM_AND_SPEAK_ID);
    commandsMap.put(COMMAND_STOP_SINGLE_INTERCOM_AND_SPEAK, COMMAND_STOP_SINGLE_INTERCOM_AND_SPEAK_ID);
    commandsMap.put(COMMAND_START_DOUBLE_INTERCOM, COMMAND_START_DOUBLE_INTERCOM_ID);
    commandsMap.put(COMMAND_STOP_DOUBLE_INTERCOM, COMMAND_STOP_DOUBLE_INTERCOM_ID);
    commandsMap.put(COMMAND_SWTICH_STREAM_TYPE_MONITOR, COMMAND_SWTICH_STREAM_TYPE_MONITOR_ID);
    commandsMap.put(COMMAND_UPDATE_STREAM_TYPE_MONITOR, COMMAND_UPDATE_STREAM_TYPE_MONITOR_ID);
    commandsMap.put(COMMAND_SET_VIDEO_FULLSCREEN, COMMAND_SET_VIDEO_FULLSCREEN_ID);
    commandsMap.put(COMMAND_CAPTURE_PIC_FROM_DEV_AND_SAVE, COMMAND_CAPTURE_PIC_FROM_DEV_AND_SAVE_ID);
    // commandsMap.put(COMMAND_CHANGE_VIDEO_RATIO, COMMAND_CHANGE_VIDEO_RATIO_ID);

    return commandsMap;
  }

  @Override
  public void receiveCommand(FunSDKVideoView view, int commandId, ReadableArray args) {
    // if (commandId == COMMAND_SET_VIDEO_FLIP_ID) {
    // view.setVideoFlip();
    // }
    if (commandId == COMMAND_START_MONITOR_ID) {
      System.out.println("commandId PlayVideo");
      view.PlayVideo();
    }
    if (commandId == COMMAND_PAUSE_MONITOR_ID) {
      System.out.println("commandId PauseVideo");
      view.PauseVideo();
    }
    if (commandId == COMMAND_REPLAY_MONITOR_ID) {
      view.ReplayVideo();
    }
    if (commandId == COMMAND_STOP_MONITOR_ID) {
      view.StopVideo();
    }
    if (commandId == COMMAND_DESTROY_MONITOR_ID) {
      view.destroyVideo();
    }
    if (commandId == COMMAND_CAPTURE_IMAGE_ID) {
      String path = args.getString(0);
      String savedPath = view.captureImage(path);

      System.out.println("funsdk captureImage path: " + savedPath);
      if (savedPath != null) {
        view.onCapture(savedPath);
      }
    }
    if (commandId == COMMAND_START_VIDEO_RECORD_ID) {
      String path = args.getString(0);
      view.startVideoRecord(path);
    }
    if (commandId == COMMAND_STOP_VIDEO_RECORD_ID) {
      view.stopVideoRecord();
    }
    if (commandId == COMMAND_GET_STREAM_TYPE_ID) {
      view.sendStreamType();
    }
    // if (commandId == COMMAND_SEEK_TO_TIME_ID) {
    // view.seekToTime();
    // }
    if (commandId == COMMAND_OPEN_VOICE_ID) {
      view.openVoice();
    }
    if (commandId == COMMAND_CLOSE_VOICE_ID) {
      view.closeVoice();
    }
    // if (commandId == COMMAND_SET_SPEAKER_TYPE_ID) {
    // int speakerType = args.getInt(0);
    // view.setSpeakerType(speakerType);
    // }
    if (commandId == COMMAND_START_SINGLE_INTERCOM_AND_SPEAK_ID) {
      view.startSingleIntercomAndSpeak();
    }
    if (commandId == COMMAND_STOP_SINGLE_INTERCOM_AND_SPEAK_ID) {
      view.stopSingleIntercomAndHear();
    }
    if (commandId == COMMAND_START_DOUBLE_INTERCOM_ID) {
      view.startDoubleIntercom();
    }
    if (commandId == COMMAND_STOP_DOUBLE_INTERCOM_ID) {
      view.stopDoubleIntercom();
    }
    if (commandId == COMMAND_SWTICH_STREAM_TYPE_MONITOR_ID) {
      view.switchStreamTypeMonitor();
    }
    if (commandId == COMMAND_UPDATE_STREAM_TYPE_MONITOR_ID) {
      int streamType = args.getInt(0);
      view.updateStreamTypeMonitor(streamType);
    }
    if (commandId == COMMAND_SET_VIDEO_FULLSCREEN_ID) {
      boolean speakerType = args.getBoolean(0);
      view.setVideoFullScreen(speakerType);
    }
    if (commandId == COMMAND_CAPTURE_PIC_FROM_DEV_AND_SAVE_ID) {
      view.capturePicFromDevAndSave();
    }
    // if (commandId == COMMAND_CHANGE_VIDEO_RATIO_ID) {
    // view.changeVideoRatio();
    // }
  }

  @ReactProp(name = "devId")
  public void setDeviceId(FunSDKVideoView view, String devId) {
    view.setDevId(devId);
  }

  @ReactProp(name = "channelId")
  public void setChannelId(FunSDKVideoView view, int channelId) {
    view.setChannelId(channelId);
  }

  @ReactProp(name = "streamType")
  public void setStreamType(FunSDKVideoView view, int streamType) {
    view.setStreamType(streamType);
  }
}