package com.funsdk.ui.device.record;

import androidx.annotation.StringDef;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class RecordEventEmitter {
  private final RCTEventEmitter eventEmitter;

  private int viewId = View.NO_ID;

  RecordEventEmitter(ReactContext reactContext) {
    this.eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
  }

  public static final String EVENT_MEDIA_PLAY_STATE = "onMediaPlayState";
  public static final String EVENT_SHOW_RATE_AND_TIME = "onShowRateAndTime";
  public static final String EVENT_VIDEO_BUFFER_END = "onVideoBufferEnd";
  public static final String EVENT_SEARCH_RECORD_BY_FILES_RESULT = "onSearchRecordByFilesResult";
  public static final String EVENT_SEARCH_RECORD_BY_TIMES_RESULT = "onSearchRecordByTimesResult";
  public static final String EVENT_FAILED = "onFailed";
  public static final String EVENT_START_INIT = "onStartInit";
  public static final String EVENT_DOWNLOAD_PROGRESS = "onDownloadProgress";
  public static final String EVENT_DOWNLOAD_STATE = "onDownloadState";
  public static final String EVENT_CAPTURE_PATH = "onCapture";

  public static final String EVENT_DEBUG_STATE = "onDebugState";

  static final String[] Events = {
      EVENT_MEDIA_PLAY_STATE,
      EVENT_SHOW_RATE_AND_TIME,
      EVENT_VIDEO_BUFFER_END,
      EVENT_SEARCH_RECORD_BY_FILES_RESULT,
      EVENT_SEARCH_RECORD_BY_TIMES_RESULT,
      EVENT_FAILED,
      EVENT_START_INIT,
      EVENT_DEBUG_STATE,
      EVENT_DOWNLOAD_PROGRESS,
      EVENT_DOWNLOAD_STATE,
      EVENT_CAPTURE_PATH
  };

  // понять зачем это надо
  // @Retention(RetentionPolicy.SOURCE)
  // @StringDef({
  // EVENT_MEDIA_PLAY_STATE,
  // EVENT_SHOW_RATE_AND_TIME,
  // EVENT_VIDEO_BUFFER_END,
  // EVENT_SEARCH_RECORD_BY_FILES_RESULT,
  // EVENT_FAILED,
  // EVENT_START_INIT
  // });

  @interface VideoEvents {
  }

  void setViewId(int viewId) {
    this.viewId = viewId;
  }

  void sendEvent(WritableMap map, String event) {
    receiveEvent(event, map);
  }

  private void receiveEvent(@VideoEvents String type, WritableMap event) {
    eventEmitter.receiveEvent(viewId, type, event);
  }
}
