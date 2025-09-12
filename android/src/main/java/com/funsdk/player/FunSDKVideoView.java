package com.funsdk.player;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.view.SurfaceView;
import android.view.Window;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.os.Build;
import android.graphics.PixelFormat;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import com.manager.device.DeviceManager;
import com.manager.device.media.TalkManager;
import com.manager.device.media.MediaManager;
import com.manager.device.media.attribute.PlayerAttribute;
import com.manager.device.media.monitor.MonitorManager;
import com.manager.ScreenOrientationManager;

import com.manager.device.media.playback.RecordManager;
import com.lib.FunSDK;
import com.lib.SDKCONST;
import com.lib.MsgContent;
import java.util.Calendar;

import java.util.HashMap;

public class FunSDKVideoView extends LinearLayout implements MediaManager.OnMediaManagerListener {
  private String devId;
  private int channelId;
  // streamType === SDKCONST.StreamType
  private int streamType;
  private final ThemedReactContext themedReactContext;
  private Activity activity = null;
  private final FunSDKVideoEventEmitter eventEmitter;

  // private HashMap<Integer, MonitorManager> monitorManagers;
  protected DeviceManager manager = this.getManager();
  private MonitorManager mediaManager;
  private RecordManager recordManager;
  private ScreenOrientationManager screenOrientationManager;// Screen rotation manager
  /**
   * 旋转类型：0 不旋转 1 旋转90度 2 旋转180度 3 旋转270度
   */
  // depreceated. Отсутствует в последней версии
  // private int videoFlip;

  /**
   * 对讲变声类型：0 正常 1 男 2 女
   * 0 normal, 1 male ,2 female
   */
  // private int speakerType = 0;

  // public FunSDKVideoView(ThemedReactContext context) {
  public FunSDKVideoView(ThemedReactContext context) {
    super(context);
    this.eventEmitter = new FunSDKVideoEventEmitter(context);
    this.themedReactContext = context;
    this.activity = ((ReactContext) getContext()).getCurrentActivity();

    // super(context.getCurrentActivity());
    // monitorManagers = new HashMap<>();
    // Устанавливаем ориентацию LinearLayout
    this.setOrientation(LinearLayout.VERTICAL);
  }

  // используется для того чтобы видеопроигрыватель смог использовать размеры
  // экрана
  @Override
  public void requestLayout() {
    super.requestLayout();

    // The spinner relies on a measure + layout pass happening after it calls
    // requestLayout().
    // Without this, the widget never actually changes the selection and doesn't
    // call the
    // appropriate listeners. Since we override onLayout in our ViewGroups, a layout
    // pass never
    // happens after a call to requestLayout, so we simulate one here.
    post(measureAndLayout);
  }

  private final Runnable measureAndLayout = new Runnable() {
    @Override
    public void run() {
      measure(
          MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
          MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
      layout(getLeft(), getTop(), getRight(), getBottom());
    }
  };

  @Override
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    super.onLayout(changed, left, top, right, bottom);
    adjustSurfaceChildren();
  }

  private void adjustSurfaceChildren() {
    int parentWidth = getWidth();
    int parentHeight = getHeight();
    try {
      setClipChildren(false);
      setClipToPadding(false);
      adjustNodeRecursively(this, parentWidth, parentHeight);
    } catch (Throwable ignored) {}
  }

  private void adjustNodeRecursively(View view, int parentWidth, int parentHeight) {
    if (view instanceof SurfaceView) {
      SurfaceView sv = (SurfaceView) view;
      ViewGroup.LayoutParams lp = sv.getLayoutParams();
      if (lp == null || lp.width != ViewGroup.LayoutParams.MATCH_PARENT || lp.height != ViewGroup.LayoutParams.MATCH_PARENT) {
        sv.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
      }
      sv.setZOrderOnTop(false);
      sv.setZOrderMediaOverlay(true);
      sv.setBackgroundColor(android.graphics.Color.TRANSPARENT);
      try {
        sv.getHolder().setFormat(PixelFormat.TRANSLUCENT);
      } catch (Throwable ignored) {}
      sv.layout(0, 0, parentWidth, parentHeight);
      sv.bringToFront();
      return;
    }
    if (view instanceof ViewGroup) {
      ViewGroup vg = (ViewGroup) view;
      for (int i = 0; i < vg.getChildCount(); i++) {
        adjustNodeRecursively(vg.getChildAt(i), parentWidth, parentHeight);
      }
    }
  }

  // @Override
  public void setId(int id) {
    super.setId(id);
    eventEmitter.setViewId(id);
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    destroyMonitor();
  }

  protected DeviceManager getManager() {
    return DeviceManager.getInstance();
  }

  public String getDevId() {
    return this.devId;
  }

  public void setDevId(String devId) {
    this.devId = devId;
    // initMonitor();
  }

  public int getChannelId() {
    return this.channelId;
  }

  public void setChannelId(int channelId) {
    this.channelId = channelId;
  }

  public void setStreamType(int streamType) {
    this.streamType = streamType;
  }

  public int getStreamType() {
    return this.streamType;
  }

  public void initMonitor() {
    if (mediaManager != null) {
    } else {
      WritableMap map = Arguments.createMap();
      eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_START_INIT);
      mediaManager = manager.createMonitorPlayer(this, getDevId());
      mediaManager.setHardDecode(false);
      mediaManager.setOnMediaManagerListener(this);
      mediaManager.setChnId(getChannelId());
      mediaManager.setStreamType(getStreamType());
      mediaManager.setVideoFullScreen(false);
      mediaManager.startMonitor();
      // Дождаться добавления SurfaceView и растянуть его на весь контейнер
      post(new Runnable() {
        @Override
        public void run() {
          adjustSurfaceChildren();
        }
      });
    }
  }

  public void destroyMonitor() {
    // public void destroyMonitor(int chnId) {
    // if (!monitorManagers.containsKey(chnId)) {
    // return;
    // }

    // MonitorManager mediaManager = monitorManagers.get(chnId);
    if (mediaManager != null) {
      mediaManager.destroyPlay();
    }
  }

  public void PlayVideo() {
    if (mediaManager != null) {
      // mediaManager.rePlay();
      mediaManager.startMonitor();
    } else {
      initMonitor();
    }
  }

  public void ReplayVideo() {
    if (mediaManager != null) {
      mediaManager.rePlay();
    }
  }

  public void sendStreamType() {
    if (mediaManager != null) {
      int answer = mediaManager.getStreamType();

      WritableMap map = Arguments.createMap();
      map.putString("type", "streamType");
      map.putInt("streamType", answer);
      eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_GET_INFO);
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

  public String captureImage(String path) {
    if (mediaManager != null) {
      return mediaManager.capture(path);
    }

    return null;
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
      mediaManager.closeVoiceBySound();

      // необходимо срабатывание ивента onVoice
    }
  }

  // depreceated (no method found in 2.4 version)
  // https://libraries.io/maven/io.github.xmcamera:libxmfunsdk
  // public void setSpeakerType(int speakerType) {// Set the type of sound change
  // if (mediaManager != null) {
  // TalkManager talkManager = mediaManager.getTalkManager();
  // if (talkManager != null) {
  // talkManager.setSpeakerType(speakerType);
  // }
  // }
  // }

  public void startSingleIntercomAndSpeak() {
    if (mediaManager != null) {
      mediaManager.startTalkByHalfDuplex(this.activity);
      // mediaManager.getTalkManager().setSpeakerType(speakerType);
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
      // mediaManager.getTalkManager().setSpeakerType(speakerType);
      // необходимо срабатывание ивента onDoubleIntercome
    }
  }

  public void stopDoubleIntercom() {
    if (mediaManager != null) {
      mediaManager.stopTalkByDoubleDirection();
      mediaManager.destroyTalk();
      // необходимо срабатывание ивента onDoubleIntercome
    }
  }

  public void switchStreamTypeMonitor() {
    if (mediaManager != null) {
      mediaManager.setStreamType(mediaManager.getStreamType() == SDKCONST.StreamType.Extra ? SDKCONST.StreamType.Main
          : SDKCONST.StreamType.Extra);
      mediaManager.stopPlay();
      mediaManager.startMonitor();
      // необходимо срабатывание ивента onStreamChange
    }
  }

  public void updateStreamTypeMonitor(int streamType) {
    if (mediaManager != null) {
      mediaManager.setStreamType(streamType);
      mediaManager.stopPlay();
      mediaManager.startMonitor();
    }
  }

  public void setVideoFullScreen(boolean isFullScreen) {
    /*
     * if(mediaManager.getStreamType() == SDKCONST.StreamType.Main) {
     * System.out.println("StreamType.Main: ");
     * mediaManager.setStreamType(mediaManager.getStreamType() ==
     * SDKCONST.StreamType.Extra ? SDKCONST.StreamType.Main
     * : SDKCONST.StreamType.Extra);
     * mediaManager.stopPlay();
     * mediaManager.startMonitor();
     * }
     */
    screenOrientationManager = ScreenOrientationManager.getInstance();
    if (isFullScreen) {
      screenOrientationManager.landscapeScreen(this.activity, true);
      setImmersiveMode(true);
    } else {
      screenOrientationManager.portraitScreen(this.activity, true);
      setImmersiveMode(false);
    }

  }

  private void setImmersiveMode(boolean enable) {
    if (this.activity == null) return;
    try {
      Window window = this.activity.getWindow();
      View decorView = window.getDecorView();
      if (enable) {
        if (Build.VERSION.SDK_INT >= 30) {
          window.setDecorFitsSystemWindows(false);
          WindowInsetsController controller = window.getInsetsController();
          if (controller != null) {
            controller.hide(WindowInsets.Type.statusBars() | WindowInsets.Type.navigationBars());
            controller.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
          }
        } else {
          int flags = View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
              | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
              | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
              | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_FULLSCREEN;
          decorView.setSystemUiVisibility(flags);
        }
      } else {
        if (Build.VERSION.SDK_INT >= 30) {
          WindowInsetsController controller = window.getInsetsController();
          if (controller != null) {
            controller.show(WindowInsets.Type.statusBars() | WindowInsets.Type.navigationBars());
          }
          window.setDecorFitsSystemWindows(true);
        } else {
          decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
        }
      }
    } catch (Throwable ignored) {}
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

  // public void changeVideoRatio() {
  // if (mediaManager != null) {
  // mediaManager.setVideoFullScreen(false);
  // // mediaManager.setVideoFullScreen(true);
  // }
  // }

  // public void seekToTime() {
  // int times = 150;
  // Calendar searchTime = Calendar.getInstance();
  // System.out.println("searchTime123: " + searchTime.get(Calendar.YEAR));
  // // if (recordManager != null) {
  // int[] time = { searchTime.get(Calendar.YEAR), searchTime.get(Calendar.MONTH)
  // + 1,
  // searchTime.get(Calendar.DAY_OF_MONTH), 0, 0, 0 };
  // System.out.println("time: " + time);
  // int absTime = FunSDK.ToTimeType(time) + times;
  // System.out.println("absTime: " + absTime);

  // recordManager.seekToTime(times, absTime);
  // // необходимо срабатывание ивента seekToTime
  // // }
  // }

  // depreceated (no method found in 2.4 version)
  // https://libraries.io/maven/io.github.xmcamera:libxmfunsdk
  // public void setVideoFlip() {
  // if (mediaManager != null) {
  // videoFlip++;
  // videoFlip %= 3;// 旋转类型：0 不旋转 1 旋转90度 2 旋转180度 3 旋转270度
  // mediaManager.setVideoFlip(videoFlip);
  // }
  // }

  /**
   * Обратные вызовы для состояний воспроизведения
   * public static final int E_STATE_UNINIT = -1; // Не инициализировано
   * public static final int E_STATE_PlAY = 0; // Воспроизведение
   * public static final int E_STATE_PAUSE = 1; // Пауза
   * public static final int E_STATE_BUFFER = 2; // Получение данных
   * public static final int E_STATE_REFRESH = 3; // Обновление
   * public static final int E_STATE_STOP = 4; // Остановка
   * public static final int E_STATE_RESUME = 5; // Возобновление
   * public static final int E_STATE_CANNOT_PLAY = 6; // Невозможно воспроизвести
   * public static final int E_STATE_READY_PLAY = 7; // Готово к воспроизведению
   * public static final int E_STATE_MEDIA_DISCONNECT = 8; // Разрыв
   * медиасоединения
   * public static final int E_STATE_MEDIA_SOUND_ON = 9; // Звук включен
   * public static final int E_STATE_MEDIA_SOUND_OFF = 10; // Звук выключен
   * public static final int E_STATE_RECONNECT = 11; // Повторное соединение
   * public static final int E_STATE_CHANGE_VR_MODE = 12; // Режим виртуальной
   * реальности
   * public static final int E_HARDDECODER_FAILURE = -5; // Сбой аппаратной
   * декодирования
   * public static final int E_OPEN_FAILED = 13; // Ошибка подключения,
   * пожалуйста, обновите (используется в xmeye)
   * public static final int E_NO_VIDEO = 14; // Видео отсутствует (используется в
   * xmeye)
   * public static final int E_STATE_SET_PLAY_VIEW = 15; // Обратный вызов для
   * настройки воспроизведения
   * public static final int E_STATE_PLAY_COMPLETED = 16; // Воспроизведение
   * завершено, обычно используется для воспроизведения записей
   * public static final int E_STATE_PLAY_SEEK = 17; // Поиск при воспроизведении
   * записей
   * public static final int E_STATE_SAVE_RECORD_FILE_S = 18; // Сохранение записи
   * успешно
   * public static final int E_STATE_SAVE_PIC_FILE_S = 19; // Сохранение
   * изображения успешно
   *
   * Получайте константы из import static
   * com.manager.device.media.attribute.PlayerAttribute.E_STATE_CANNOT_PLAY;
   *
   * @param attribute
   * @param state
   */
  @Override
  public void onMediaPlayState(PlayerAttribute attribute, int state) {
    WritableMap map = Arguments.createMap();
    map.putInt("state", state);
    eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_MEDIA_PLAY_STATE);
  }

  public void onFailed(PlayerAttribute attribute, int msgId, int errorId) {
    // в фансдк демо тут TODO и ничего нет
    WritableMap map = Arguments.createMap();
    map.putInt("msgId", msgId);
    map.putInt("errorId", errorId);
    eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_FAILED);
  }

  /**
   * Показывает битрейт и временную метку
   *
   * @param attribute
   * @param isShowTime
   * @param time
   * @param rate
   */
  @Override
  public void onShowRateAndTime(PlayerAttribute attribute, boolean isShowTime,
      String time, long rate) {
    // String time, String rate) {

    WritableMap map = Arguments.createMap();
    // map.putBoolean("isShowTime", isShowTime);
    map.putString("time", time);
    map.putDouble("rate", (double) rate);
    eventEmitter.sendEvent(map,
        FunSDKVideoEventEmitter.EVENT_SHOW_RATE_AND_TIME);
  }

  /**
   * Обратный вызов завершения буферизации видео
   *
   * @param attribute
   * @param ex
   */
  @Override
  public void onVideoBufferEnd(PlayerAttribute attribute, MsgContent ex) {
    WritableMap map = Arguments.createMap();
    map.putBoolean("isBufferEnd", true);
    eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_VIDEO_BUFFER_END);
  }

  public void onPlayStateClick(View view) {
    // в библиотеке тут пусто
  }

  public void onCapture(String path) {
    WritableMap map = Arguments.createMap();
    map.putString("path", path);
    eventEmitter.sendEvent(map, FunSDKVideoEventEmitter.EVENT_CAPTURE_PATH);
  }

  public interface OnMediaManagerListener {
    void onMediaPlayState(PlayerAttribute var1, int var2);

    void onFailed(PlayerAttribute var1, int var2, int var3);

    void onShowRateAndTime(PlayerAttribute var1, boolean var2, String var3, String var4);

    void onVideoBufferEnd(PlayerAttribute var1, MsgContent var2);

    void onPlayStateClick(View var1);
  }
}
