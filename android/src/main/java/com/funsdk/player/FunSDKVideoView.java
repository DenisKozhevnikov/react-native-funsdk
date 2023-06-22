package com.funsdk.player;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.ReactContext;

import com.lib.SDKCONST;

import com.manager.device.DeviceManager;
import com.manager.device.media.TalkManager;
import com.manager.device.media.monitor.MonitorManager;

import java.util.HashMap;

public class FunSDKVideoView extends LinearLayout {
  private String devId;
  private final ThemedReactContext themedReactContext;
  private Activity activity = null;
  private HashMap<Integer, MonitorManager> monitorManagers;
  protected DeviceManager manager = this.getManager();
  private MonitorManager mediaManager;
  /**
   * 旋转类型：0 不旋转 1 旋转90度 2 旋转180度 3 旋转270度
   */
  private int videoFlip;
  /**
   * 对讲变声类型：0 正常 1 男 2 女
   * 0 normal, 1 male ,2 female
   */
  private int speakerType = 0;

  // public FunSDKVideoView(ThemedReactContext context) {
  public FunSDKVideoView(ThemedReactContext context) {
    super(context);
    this.themedReactContext = context;
    this.activity = ((ReactContext) getContext()).getCurrentActivity();

    // super(context.getCurrentActivity());
    monitorManagers = new HashMap<>();
    // Устанавливаем ориентацию LinearLayout
    this.setOrientation(LinearLayout.VERTICAL);
  }

  protected DeviceManager getManager() {
    return DeviceManager.getInstance();
  }

  public String getDevId() {
    return this.devId;
  }

  public void setDevId(String devId) {
    this.devId = devId;
    initMonitor();
  }

  public void initMonitor() {
    if (mediaManager != null) {
    } else {

      mediaManager = manager.createMonitorPlayer(this, getDevId());
      mediaManager.setHardDecode(false);
      mediaManager.setVideoFullScreen(false);
      mediaManager.startMonitor();
    }
  }

  public void PlayVideo() {
    if (mediaManager != null) {
      mediaManager.rePlay();
      // mediaManager.startMonitor();
    } else {

      // initMonitor();
    }
  }

  public void ReplayVideo() {
    if (mediaManager != null) {
      mediaManager.rePlay();
    }
  }

  public void PauseVideo() {
    if (mediaManager != null) {
      mediaManager.pausePlay();
    }
  }

  public void StopVideo() {
    if (mediaManager != null) {
      mediaManager.stopPlay();
    }
  }

  public void destroyVideo() {
    if (mediaManager != null) {
      mediaManager.destroyPlay();
    }
  }

  public void captureImage(String path) {
    if (mediaManager != null) {
      System.out.println("Capture image path: " + path);
      mediaManager.capture(path);
    }
  }

  public void startVideoRecord(String path) {
    if (mediaManager != null) {
      boolean isRecord = mediaManager.startRecord(path);
      // необходимо срабатывание ивента onRecordState
    }
  }

  public void stopVideoRecord() {
    if (mediaManager != null && mediaManager.isRecord()) {
      String isRecord = mediaManager.stopRecord();
      // необходимо срабатывание ивента onRecordState
    }
  }

  public void openVoice() {
    if (mediaManager != null) {
      mediaManager.openVoiceBySound();
      // необходимо срабатывание ивента onVoice
    }
  }

  public void closeVoice() {
    if (mediaManager != null) {
      mediaManager.openVoiceBySound();
      // необходимо срабатывание ивента onVoice
    }
  }

  public void setSpeakerType(int speakerType) {// Set the type of sound change
    if (mediaManager != null) {
      TalkManager talkManager = mediaManager.getTalkManager();
      if (talkManager != null) {
        talkManager.setSpeakerType(speakerType);
      }
    }
  }

  public void startSingleIntercomAndSpeak() {
    if (mediaManager != null) {
      mediaManager.startTalkByHalfDuplex(this.activity);
      mediaManager.getTalkManager().setSpeakerType(speakerType);
      // необходимо срабатывание ивента onSingleIntercome
    }
  }

  public void stopSingleIntercomAndHear() {
    if (mediaManager != null) {
      mediaManager.stopTalkByHalfDuplex();
      // необходимо срабатывание ивента onSingleIntercome
    }
  }

  public void startDoubleIntercom() {
    if (mediaManager != null) {
      mediaManager.startTalkByDoubleDirection(this.activity, true);
      mediaManager.getTalkManager().setSpeakerType(speakerType);
      // необходимо срабатывание ивента onDoubleIntercome
    }
  }

  public void stopDoubleIntercom() {
    if (mediaManager != null) {
      mediaManager.destroyTalk();
      // необходимо срабатывание ивента onDoubleIntercome
    }
  }

  public void SwitchStreamType() {
    if (mediaManager != null) {
      mediaManager.setStreamType(mediaManager.getStreamType() == SDKCONST.StreamType.Extra ? SDKCONST.StreamType.Main
          : SDKCONST.StreamType.Extra);
      mediaManager.stopPlay();
      mediaManager.startMonitor();
      // необходимо срабатывание ивента onStreamChange
    }
  }

  public void setVideoFullScreen(boolean isFullScreen) {
    if (mediaManager != null) {
      mediaManager.setVideoFullScreen(isFullScreen);
      // необходимо срабатывание ивента onVideoFullScreen
      // mediaManager.isVideoFullScreen()
    }
  }

  public void capturePicFromDevAndSave() {
    if (mediaManager != null) {

      manager.captureFromDevAndSaveToDev(getDevId(), 0, new DeviceManager.OnDevManagerListener() {
        @Override
        public void onSuccess(String s, int i, Object result) {
          // необходимо срабатывание ивента onCaptureFromDevAndSaveToDev
        }

        @Override
        public void onFailed(String s, int i, String s1, int i1) {
          // необходимо срабатывание ивента onCaptureFromDevAndSaveToDev
        }
      });
    }
  }

  public void setVideoFlip() {
    if (mediaManager != null) {
      videoFlip++;
      videoFlip %= 3;// 旋转类型：0 不旋转 1 旋转90度 2 旋转180度 3 旋转270度
      mediaManager.setVideoFlip(videoFlip);
    }
  }
}
