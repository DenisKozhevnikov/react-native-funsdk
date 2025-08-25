package com.funsdk.ui.device.record;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;
import android.view.SurfaceView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.FrameLayout;
import android.os.Message;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import com.facebook.react.uimanager.ThemedReactContext;

import com.lib.FunSDK;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;

import com.manager.db.Define;
import com.manager.db.DevDataCenter;
import com.manager.db.DownloadInfo;
import com.manager.device.DeviceManager;
import com.manager.device.media.attribute.PlayerAttribute;
import com.manager.device.media.attribute.RecordPlayerAttribute;
import com.manager.device.media.calendar.MediaFileCalendarManager;
import com.manager.device.media.download.DownloadManager;
import com.manager.device.media.playback.DevRecordManager;
import com.manager.device.media.playback.RecordManager;
import com.manager.device.media.MediaManager;

// does not exist
// import com.manager.path.PathManager;
import com.utils.TimeUtils;

import static com.manager.db.Define.DOWNLOAD_VIDEO_BY_CLOUD;
import static com.manager.db.Define.DOWNLOAD_VIDEO_BY_FILE;
import static com.manager.device.media.MediaManager.PLAY_CLOUD_PLAYBACK;
// int 1
import static com.manager.device.media.MediaManager.PLAY_DEV_PLAYBACK;
import static com.manager.device.media.download.DownloadManager.DOWNLOAD_STATE_PROGRESS;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

import com.funsdk.utils.device.media.playback.UpdatedDevRecordManager;

// public class FunSDKRecordView extends LinearLayout {
public class FunSDKRecordView extends LinearLayout
    implements MediaManager.OnMediaManagerListener, RecordManager.OnRecordManagerListener, DownloadManager.OnDownloadListener {
  private String devId;
  private int channelId;
  // нужен ли он?
  private final ThemedReactContext themedReactContext;
  // нужен ли он?
  private Activity activity = null;
  private final RecordEventEmitter eventEmitter;

  private UpdatedDevRecordManager recordManager;
  private DownloadManager downloadManager;
  private List<H264_DVR_FILE_DATA> recordList;
  private int recordPlayType = PLAY_DEV_PLAYBACK;

  public FunSDKRecordView(ThemedReactContext context) {
    super(context);
    this.eventEmitter = new RecordEventEmitter(context);
    this.themedReactContext = context;
    this.activity = ((ReactContext) getContext()).getCurrentActivity();
    recordList = new ArrayList<>();
    downloadManager = DownloadManager.getInstance(this);
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
    } catch (Throwable t) {
      android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - adjustSurfaceChildren error: " + t.getMessage());
    }
  }

  private void adjustNodeRecursively(View view, int parentWidth, int parentHeight) {
    if (view instanceof SurfaceView) {
      SurfaceView sv = (SurfaceView) view;
      // Ensure full-bleed fill for the surface view
      ViewGroup.LayoutParams lp = sv.getLayoutParams();
      if (lp == null || lp.width != ViewGroup.LayoutParams.MATCH_PARENT || lp.height != ViewGroup.LayoutParams.MATCH_PARENT) {
        sv.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
      }
      sv.setBackgroundColor(Color.TRANSPARENT);
      sv.setZOrderOnTop(false);
      sv.setZOrderMediaOverlay(true);
      sv.setX(parentWidth);
      sv.setY(0);
      sv.layout(0, 0, parentWidth, parentHeight);
      sv.bringToFront();
      try {
        // Let Surface buffer follow layout size automatically
        sv.getHolder().setFormat(android.graphics.PixelFormat.TRANSLUCENT);
      } catch (Throwable ignored) {}
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

  protected DeviceManager getManager() {
    return DeviceManager.getInstance();
  }

  public void init() {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putString("status", "start");
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_START_INIT);

    recordManager = new UpdatedDevRecordManager(this, new RecordPlayerAttribute(getDevId()));
    recordManager.setChnId(getChannelId());
    recordManager.setVideoFullScreen(false);
    recordManager.setOnMediaManagerListener(this);

    // Log view dimensions
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - init() view dimensions: width=" + getWidth() + ", height=" + getHeight());
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - init() view visibility: " + getVisibility());
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - child count: " + getChildCount());
    
    // Check if SurfaceView was created by RecordManager and adjust z-order
    for (int i = 0; i < getChildCount(); i++) {
      View child = getChildAt(i);
      android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - child " + i + ": " + child.getClass().getSimpleName());
      if (child instanceof SurfaceView) {
        SurfaceView surfaceView = (SurfaceView) child;
        android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - Found SurfaceView: width=" + surfaceView.getWidth() + ", height=" + surfaceView.getHeight());
        // Ensure SurfaceView renders above RN content if needed
        try {
          surfaceView.setZOrderOnTop(false);
          surfaceView.setZOrderMediaOverlay(true);
          surfaceView.bringToFront();
        } catch (Throwable t) {
          android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - SurfaceView z-order setup error: " + t.getMessage());
        }
      }
    }

    WritableMap initMap = Arguments.createMap();
    initMap.putInt("target", getId());
    initMap.putString("status", "initialized");
    eventEmitter.sendEvent(initMap, RecordEventEmitter.EVENT_START_INIT);
  }

  public String getDevId() {
    return this.devId;
  }

  public void setDevId(String devId) {
    this.devId = devId;
  }

  public int getChannelId() {
    return this.channelId;
  }

  public void setChannelId(int channelId) {
    this.channelId = channelId;
  }

  public void initRecordPlayer() {
    if (recordManager == null) {
      recordManager = new UpdatedDevRecordManager(this, new RecordPlayerAttribute(getDevId()));
      recordManager.setChnId(getChannelId());
      recordManager.setVideoFullScreen(false);
      recordManager.setOnMediaManagerListener(this);
    }
  }

  // вынес в отдельный класс SearchByTime
  // public void searchRecordByTime(Calendar searchTime) {
  // this.searchTime = searchTime;
  // int[] times = new int[] {
  // searchTime.get(Calendar.YEAR),
  // searchTime.get(Calendar.MONTH) + 1,
  // searchTime.get(Calendar.DATE)
  // };
  // recordManager.searchFileByTime(times);
  // }

  public void searchRecordByFile(Calendar startTime, Calendar endTime) {
    recordManager.searchFileByTime(startTime, endTime);
  }

  /**
   * @param position
   */
  // @Override
  public void startPlayRecord(int position) {
    android.util.Log.d("FunSDKRecordView", "startPlayRecord(int) called with position: " + position);
    android.util.Log.d("FunSDKRecordView", "recordList size: " + (recordList != null ? recordList.size() : "null"));
    android.util.Log.d("FunSDKRecordView", "recordManager: " + (recordManager != null ? "exists" : "null"));
    
    H264_DVR_FILE_DATA recordInfo = recordList.get(position);
    Calendar playCalendar = TimeUtils.getNormalFormatCalender(recordInfo.getStartTimeOfYear());
    Calendar endCalendar = Calendar.getInstance();
    endCalendar.setTime(playCalendar.getTime());
    endCalendar.set(Calendar.HOUR_OF_DAY, 23);
    endCalendar.set(Calendar.MINUTE, 59);
    endCalendar.set(Calendar.SECOND, 59);

    android.util.Log.d("FunSDKRecordView", "About to call recordManager.startPlay()");
    recordManager.startPlay(playCalendar, endCalendar);
  }

  public void startPlayRecord(Calendar startTime, Calendar endTime) {
    android.util.Log.d("FunSDKRecordView", "startPlayRecord(Calendar) called");
    android.util.Log.d("FunSDKRecordView", "recordManager: " + (recordManager != null ? "exists" : "null"));
    // Defer start until we have non-zero size to avoid a 0x0 surface
    if (getWidth() == 0 || getHeight() == 0) {
      android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - view size is 0, deferring start until layout");
      getViewTreeObserver().addOnGlobalLayoutListener(new android.view.ViewTreeObserver.OnGlobalLayoutListener() {
        @Override
        public void onGlobalLayout() {
          getViewTreeObserver().removeOnGlobalLayoutListener(this);
          startPlayWithAdjustments(startTime, endTime);
        }
      });
    } else {
      startPlayWithAdjustments(startTime, endTime);
    }
  }

    public void startPlayRecordByTime(Map<String, Object> start, Map<String, Object> end) {
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - startPlayRecordByTime called");
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - recordManager: " + (recordManager != null ? "exists" : "null"));
    
    Calendar startCalendar = Calendar.getInstance();
    Calendar endCalendar = Calendar.getInstance();
    
    startCalendar.set(
      (Integer) start.get("year"),
      (Integer) start.get("month") - 1,
      (Integer) start.get("day"),
      (Integer) start.get("hour"),
      (Integer) start.get("minute"),
      (Integer) start.get("second")
    );
    
    endCalendar.set(
      (Integer) end.get("year"),
      (Integer) end.get("month") - 1,
      (Integer) end.get("day"),
      (Integer) end.get("hour"),
      (Integer) end.get("minute"),
      (Integer) end.get("second")
    );
    
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - About to call recordManager.startPlay() with time range");
    // Defer start until we have non-zero size to avoid a 0x0 surface
    if (getWidth() == 0 || getHeight() == 0) {
      android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - view size is 0, deferring start until layout (by time)");
      getViewTreeObserver().addOnGlobalLayoutListener(new android.view.ViewTreeObserver.OnGlobalLayoutListener() {
        @Override
        public void onGlobalLayout() {
          getViewTreeObserver().removeOnGlobalLayoutListener(this);
          startPlayWithAdjustments(startCalendar, endCalendar);
        }
      });
    } else {
      startPlayWithAdjustments(startCalendar, endCalendar);
    }
  }

  private void startPlayWithAdjustments(Calendar startCalendar, Calendar endCalendar) {
    recordManager.startPlay(startCalendar, endCalendar);
    // Post to adjust SurfaceView after RecordManager attaches it
    post(new Runnable() {
      @Override
      public void run() {
        for (int i = 0; i < getChildCount(); i++) {
          View child = getChildAt(i);
          if (child instanceof SurfaceView) {
            try {
              // Ensure the render view fills parent
              ViewGroup.LayoutParams lp = child.getLayoutParams();
              if (lp == null || lp.width != ViewGroup.LayoutParams.MATCH_PARENT || lp.height != ViewGroup.LayoutParams.MATCH_PARENT) {
                child.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
              }
              ((SurfaceView) child).setZOrderOnTop(false);
              ((SurfaceView) child).setZOrderMediaOverlay(true);
              child.bringToFront();
              child.requestLayout();
              invalidate();
            } catch (Throwable t) {
              android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - SurfaceView layout/z-order setup error: " + t.getMessage());
            }
          }
        }
      }
    });
  }

  public void seekToTime(int addTime, int absTime) {
    recordManager.seekToTime(addTime, absTime);
  }

  public String capture(String path) {
    if (path != null && !path.isEmpty()) {
      return recordManager.capture(path);
    } else {
      return recordManager.capture(null);
    }
  }

  public void startRecord(String path) {
    if (!recordManager.isRecord()) {
      if (path != null && !path.isEmpty()) {
        recordManager.startRecord(path);
      } else {
        recordManager.startRecord(null);
      }
    }
  }

  public void stopRecord() {
    if (recordManager.isRecord()) {
      recordManager.stopRecord();
    }
  }

  public boolean isRecording() {
    return recordManager.isRecord();
  }

  public void openVoice() {
    recordManager.openVoiceBySound();
  }

  public void closeVoice() {
    recordManager.closeVoiceBySound();
  }

  public void pausePlay() {
    recordManager.pausePlay();
  }

  public void rePlay() {
    recordManager.rePlay();
  }

  public void stopPlay() {
    recordManager.stopPlay();
  }

  public void destroyPlay() {
    recordManager.destroyPlay();
  }

  public void onDebugState(String state) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putString("state", state);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DEBUG_STATE);
  }

  public boolean isRecordPlay() {
    return recordManager.getPlayState() == PlayerAttribute.E_STATE_PlAY;
  }

  public void setPlaySpeed(int speed) {
    recordManager.setPlaySpeed(speed);
  }

  public void downloadFile(int position, String path) {
    if (position >= recordList.size()) {
      return;
    }

    H264_DVR_FILE_DATA data = recordList.get(position);
    if (data != null) {
      String rawName = data.getStartTimeOfYear() + "_" + data.getEndTimeOfYear() + ".mp4";
      // Sanitize for Android filesystem
      String fileName = rawName.replace(":", "-").replace(" ", "_");
      try {
        File dir = new File(path);
        if (!dir.exists()) {
          // Ensure directory exists
          dir.mkdirs();
        }
      } catch (Throwable ignored) {}
      DownloadInfo downloadInfo = new DownloadInfo();
      downloadInfo.setStartTime(TimeUtils.getNormalFormatCalender(data.getStartTimeOfYear()));
      downloadInfo.setEndTime(TimeUtils.getNormalFormatCalender(data.getEndTimeOfYear()));
      downloadInfo.setDevId(getDevId());
      downloadInfo.setObj(data);
      downloadInfo.setDownloadType(recordPlayType == PLAY_CLOUD_PLAYBACK
          ? DOWNLOAD_VIDEO_BY_CLOUD
          : DOWNLOAD_VIDEO_BY_FILE);
      downloadInfo.setSaveFileName(path + File.separator + fileName);
      downloadManager.addDownload(downloadInfo);
      downloadManager.startDownload();
    }
  }

  // public void searchMediaFileCalendar(Calendar searchCalendar) {
  // if (recordPlayType == PLAY_CLOUD_PLAYBACK) {
  // mediaFileCalendarManager.searchFile(searchCalendar, Define.MEDIA_TYPE_CLOUD,
  // 0);
  // } else {
  // mediaFileCalendarManager.searchFile(searchCalendar, Define.MEDIA_TYPE_DEVICE,
  // 0);
  // }
  // }

  // LISTENERS

  // как минимум для mediaFileCalendarManager
  // @Override
  public void onFailed(int msgId, int errorId) {
    WritableMap map = Arguments.createMap();
    map.putInt("msgId", msgId);
    map.putInt("errorId", errorId);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_FAILED);
  }

  /**
   * Успешный результат запроса видеофайла или датчиков видео
   *
   * @param attribute
   * @param data
   */
  @Override
  public void searchResult(PlayerAttribute attribute, Object data) {
    if (data != null) {
      if (data instanceof H264_DVR_FILE_DATA[]) {
        recordList.clear();
        recordList.addAll(recordManager.getFileDataList());

        WritableMap holder = Arguments.createMap();
        WritableArray array = Arguments.createArray();

        for (H264_DVR_FILE_DATA fileData : recordList) {
          WritableMap map = Arguments.createMap();

          map.putInt("channel", fileData.st_0_ch);
          map.putInt("filesize", fileData.st_1_size);
          map.putString("filename", fileData.getFileName());
          map.putString("startDate", fileData.getStartDate());
          map.putString("startTimeOfDay", fileData.getStartTimeOfDay());
          map.putString("startTimeOfYear", fileData.getStartTimeOfYear());
          map.putDouble("startTimeLong", fileData.getLongStartTime());
          map.putString("endTimeOfDay", fileData.getEndTimeOfDay());
          map.putString("endTimeOfYear", fileData.getEndTimeOfYear());
          map.putDouble("endTimeLong", fileData.getLongEndTime());
          map.putDouble("endTimeLong24Hours", fileData.getLongEndTime24Hours());
          // map.putString("recordLenType", fileData.getRecordLenType());
          map.putString("alarmExFileInfo", fileData.getAlarmExFileInfo());
          map.putInt("fileTimeLong", fileData.getFileTimeLong());
          map.putInt("streamType", fileData.getStreamType());

          map.putInt("downloadStatus", fileData.downloadStatus);
          map.putInt("downloadType", fileData.downloadType);
          map.putBoolean("isChecked", fileData.isChecked);
          map.putDouble("currentPos", fileData.currentPos);
          map.putDouble("st_5_wnd", fileData.st_5_wnd);
          map.putInt("seekPosition", fileData.seekPosition);
          map.putBoolean("isEffective", fileData.isEffective);
          map.putBoolean("recordLenTypeNormal",
              fileData.getRecordLenType() == RecordPlayerAttribute.RECORD_LEN_TYPE.RECORD_LEN_NORMAL);

          SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
          String startTimeOfYear = fileData.getStartTimeOfYear();
          try {
            Date startDate = dateFormat.parse(startTimeOfYear);

            map.putDouble("startTimestamp", startDate.getTime());

          } catch (ParseException e) {
            e.printStackTrace(); // Handle the exception appropriately
          }
          array.pushMap(map);
        }
        holder.putArray("list", array);
        holder.putString("type", "recordfiles");

        eventEmitter.sendEvent(holder,
            RecordEventEmitter.EVENT_SEARCH_RECORD_BY_FILES_RESULT);

      } else {
        // для загрузки из cloud
        // if (recordManager instanceof CloudRecordManager) {
        // recordList.clear();
        // recordList.addAll(((CloudRecordManager)
        // recordManager).getCloudMediaFiles().cloudMediaInfoToH264FileData());
        // }

        // выделен в отдельный класс SearchByTime
        // dealWithRecordTimeList((char[][]) data);
      }

      // haveRecordMap = DevDataCenter.getInstance().getHasRecordFile();
    } else {
      // отправить в реакт данные о том что поиск не успешен
      // iDevRecordView.onSearchRecordByFileResult(false);
      WritableMap map = Arguments.createMap();
      map.putBoolean("isSearchResult", false);
      eventEmitter.sendEvent(map,
          RecordEventEmitter.EVENT_SEARCH_RECORD_BY_FILES_RESULT);
      // eventEmitter.sendEvent(map,
      // RecordEventEmitter.EVENT_SEARCH_RECORD_BY_TIMES_RESULT);
    }
  }

  // public void charToString(String time, char[][] data) {
  // StringBuilder sb = new StringBuilder();
  // for (int i = 0; i < data.length; i++) {
  // sb.append(i + " ");
  // for (int j = 0; j < data[i].length; j++) {
  // char currentChar = data[i][j];
  // int charValue = (int) currentChar;
  // sb.append(" ");
  // sb.append(charValue);
  // }
  // sb.append("\n");
  // }
  // String result = sb.toString();

  // WritableMap map = Arguments.createMap();
  // String res = "time: " + time + " res: " + "\n" + result;
  // map.putString("list", res);
  // eventEmitter.sendEvent(map,
  // RecordEventEmitter.EVENT_SEARCH_RECORD_BY_TIMES_RESULT);
  // }

  // https://developer.jftech.com/docs/?menusId=8af0e7f3d4af49eab71cfdd8d7e47cef&siderid=c73c3a8ee303443694928c50a299f223&lang=en#docs-hash-6
  /// < The video recording uses 720 bytes of 5760 bits to represent 1440 minutes
  /// of the day
  /// < 0000: No recording 0001:F_COMMON 0002:F_ALERT 0003:F_DYNAMIC 0004:F_CARD
  /// 0005:F_HAND
  // private void dealWithRecordTimeList(char[][] minutes) {
  // WritableArray charArray = Arguments.createArray();
  // WritableArray minutesStatusArray = Arguments.createArray();
  // int charsCount = 0;
  // int minutesCount = 0;

  // for (char[] recordRow : minutes) {
  // for (char recordChar : recordRow) {
  // // recordInfo - варианты числе 0, 17, 19, 49, 51...
  // int recordInfo = (int) recordChar;
  // charArray.pushInt(recordInfo);
  // charsCount++;

  // // преобразует recordInfo в двоичный формат и выполняет побитовую операцию
  // "и" с
  // // 15(1111) получая номер статуса
  // //
  // // пример: 49 преобразует в 0011 0001
  // // побитовая операция "и" 0011 0001 & 0000 1111
  // // получает 1 для первой минуты
  // int firstMinute = recordInfo & 15;
  // minutesStatusArray.pushInt(firstMinute);
  // minutesCount++;

  // // сдвигает на 4 бита вправо
  // //
  // // пример: 49 преобразует в 0011 0001
  // // сдвигает на 4 бита вправо и получает: 0011
  // // побитовая операция "и" 0000 0011 & 0000 1111
  // // получает 3 для второй минуты
  // int secondMinute = recordInfo >> 4 & 15;
  // minutesStatusArray.pushInt(secondMinute);
  // minutesCount++;
  // }
  // }

  // WritableMap map = Arguments.createMap();
  // map.putArray("charList", charArray);
  // map.putArray("minutesStatusList", minutesStatusArray);
  // map.putInt("charsCount", charsCount);
  // map.putInt("minutesCount", minutesCount);
  // eventEmitter.sendEvent(map,
  // RecordEventEmitter.EVENT_SEARCH_RECORD_BY_TIMES_RESULT);

  // recordTimeList.clear();
  // int count = 24 * 60 / timeUnit; // 24
  // int n = timeUnit / 10; // 6
  // int i = 0, j = 0;

  // for (i = 0; i < timeCount / 2; i++) {
  // recordTimeMap = new HashMap<String, Object>();
  // recordTimeList.add(recordTimeMap);
  // }

  // for (i = 0; i < count; i++) {

  // String time = TimeUtils.formatTimes(i * timeUnit);

  // char[][] data = new char[n][];

  // recordTimeMap = new HashMap<String, Object>();
  // for (j = 0; j < n; ++j) {
  // data[j] = minutes[n * i + j];
  // }

  // recordTimeMap.put("data", data);
  // recordTimeMap.put("time", time);

  // // Вывод содержимого массива с char[] в читаемом формате
  // // charToString(time, data);
  // recordTimeList.add(recordTimeMap);
  // }
  // for (i = 0; i < timeCount / 2; i++) {
  // recordTimeMap = new HashMap<String, Object>();
  // recordTimeList.add(recordTimeMap);
  // }
  // }

  public interface OnMediaManagerListener {
    void onMediaPlayState(PlayerAttribute var1, int var2);

    void onFailed(PlayerAttribute var1, int var2, int var3);

    void onShowRateAndTime(PlayerAttribute var1, boolean var2, String var3,
        String var4);

    void onVideoBufferEnd(PlayerAttribute var1, MsgContent var2);

    void onPlayStateClick(View var1);
  }

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
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - onMediaPlayState called with state: " + state);
    android.util.Log.e("RECORD_DEBUG", "FunSDKRecordView - State meanings: 0=PLAY, 1=PAUSE, 2=BUFFER, 4=STOP, 6=CANNOT_PLAY");
    
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putInt("state", state);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_MEDIA_PLAY_STATE);
  }

  @Override
  public void onFailed(PlayerAttribute attribute, int msgId, int errorId) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putInt("msgId", msgId);
    map.putInt("errorId", errorId);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_FAILED);
  }

  @Override
  public void onShowRateAndTime(PlayerAttribute attribute, boolean isShowTime,
      String time, long rate) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putString("time", time);
    map.putString("rate", String.format("%d/S", rate));
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_SHOW_RATE_AND_TIME);
  }

  @Override
  public void onVideoBufferEnd(PlayerAttribute attribute, MsgContent ex) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putBoolean("isBufferEnd", true);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_VIDEO_BUFFER_END);
  }

  @Override
  public void onPlayStateClick(View view) {
    // Not used in iOS implementation
  }

  public void onCapture(String path) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putString("path", path);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_CAPTURE_PATH);
  }

  public void onDownloadProgress(int progress) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putInt("progress", progress);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DOWNLOAD_PROGRESS);
  }

  public void onDownloadState(int downloadState, String fileName) {
    WritableMap map = Arguments.createMap();
    map.putInt("target", getId());
    map.putInt("state", downloadState);
    map.putString("fileName", fileName);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DOWNLOAD_STATE);
  }

  @Override
  public void onDownload(DownloadInfo downloadInfo) {
    if (downloadInfo != null) {
      if (downloadInfo.getDownloadState() == DOWNLOAD_STATE_PROGRESS) {
        int progress = (downloadInfo.getDownloadProgress() + 100 * downloadInfo.getSeq());
        onDownloadProgress(progress);
      } else {
        onDownloadState(downloadInfo.getDownloadState(), downloadInfo.getSaveFileName());
      }
    }
  }
}
