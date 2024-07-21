package com.funsdk.player;

import androidx.annotation.StringDef;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class FunSDKVideoEventEmitter {
  private final RCTEventEmitter eventEmitter;

  private int viewId = View.NO_ID;

  FunSDKVideoEventEmitter(ReactContext reactContext) {
    this.eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
  }

  public static final String EVENT_FAILED = "onFailed";
  public static final String EVENT_START_INIT = "onStartInit";
  public static final String EVENT_MEDIA_PLAY_STATE = "onMediaPlayState";
  public static final String EVENT_SHOW_RATE_AND_TIME = "onShowRateAndTime";
  public static final String EVENT_VIDEO_BUFFER_END = "onVideoBufferEnd";
  public static final String EVENT_GET_INFO = "onGetInfo";
  public static final String EVENT_CAPTURE_PATH = "onCapture";

  public static final String EVENT_DEBUG_STATE = "onDebugState";

  static final String[] Events = {
      EVENT_FAILED,
      EVENT_START_INIT,
      EVENT_DEBUG_STATE,
      EVENT_MEDIA_PLAY_STATE,
      EVENT_SHOW_RATE_AND_TIME,
      EVENT_VIDEO_BUFFER_END,
      EVENT_GET_INFO,
      EVENT_CAPTURE_PATH
  };

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
