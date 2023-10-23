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
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

public class FunSDKRecordView extends LinearLayout
    implements RecordManager.OnRecordManagerListener, DownloadManager.OnDownloadListener {
  private String devId;
  // нужен ли он?
  private final ThemedReactContext themedReactContext;
  // нужен ли он?
  private Activity activity = null;
  private final RecordEventEmitter eventEmitter;

  public static final int MN_COUNT = 8;
  public static final int TIME_UNIT = 60;

  private MediaFileCalendarManager mediaFileCalendarManager;
  private RecordManager recordManager;
  private Calendar calendarShow;
  private Calendar searchMonthCalendar = Calendar.getInstance();
  protected DeviceManager manager = this.getManager();
  private DownloadManager downloadManager;
  // список архивных элементов
  private List<H264_DVR_FILE_DATA> recordList;
  private List<Map<String, Object>> recordTimeList;
  private Map<String, Object> recordTimeMap;
  private TreeMap<Object, Boolean> haveRecordMap;
  private Calendar searchTime;
  private int timeUnit = TIME_UNIT;
  private int timeCount = MN_COUNT;
  private int playTimeBySecond;
  private int playTimeByMinute;
  // int 1
  private int recordPlayType = PLAY_DEV_PLAYBACK;
  private int playSpeed;

  // debug
  private LinearLayout debugLayout;

  public FunSDKRecordView(ThemedReactContext context) {
    super(context);
    this.eventEmitter = new RecordEventEmitter(context);
    this.themedReactContext = context;
    this.activity = ((ReactContext) getContext()).getCurrentActivity();
    recordList = new ArrayList<>();
    recordTimeList = new ArrayList<>();
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

  // @Override
  public void setId(int id) {
    super.setId(id);
    eventEmitter.setViewId(id);
  }

  protected DeviceManager getManager() {
    return DeviceManager.getInstance();
  }

  public void init(String devId) {
    WritableMap map = Arguments.createMap();
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_START_INIT);

    calendarShow = Calendar.getInstance();
    setDevId(devId);

    initRecordPlayer(this, recordPlayType);
    searchRecordByFile(calendarShow);
    searchRecordByTime(calendarShow);

    // mediaFileCalendarManager = new MediaFileCalendarManager(this);
    // mediaFileCalendarManager.init(devId, null, "h264");
  }

  public String getDevId() {
    return this.devId;
  }

  public void setDevId(String devId) {
    this.devId = devId;
  }

  public void initRecordPlayer(ViewGroup playView, int recordType) {
    recordManager = manager.createRecordPlayer(this, getDevId(), recordType);
    // TODO: сделать методы с каналами
    // recordManager.setChnId(getChnId());
    recordManager.setChnId(0);
    recordManager.setVideoFullScreen(false);// 默认按比例显示
    // назначаем в менеджер слушатели, примеры по которым будет ответ
    // OnFunSDKResult(this.playerAttribute, msg, ex) - 5101 обработается в
    // recordManager и ответ будет в searchResult
    // onFailed(this.playerAttribute, msg.what, msg.arg2)
    // onMediaPlayState(this.playerAttribute, 18)
    // onShowRateAndTime(this.playerAttribute, isShowTime, time,
    // FileUtils.FormetFileSize(Long.parseLong(value)) + "/S")
    // onVideoBufferEnd(this.playerAttribute, ex)
    // onPlayStateClick(v)
    // searchResult - результат поиска по 5101(DEV_FIND_FILE)
    recordManager.setOnMediaManagerListener(this);
    // recordManager.setOnMediaManagerListener(new MediaManagerListener());

    // recordManager.initVideoThumb(PathManager.getInstance(this.getContext()).getTempImages(),
    // getDevId(),
    // this);

  }

  public void searchRecordByTime(Calendar searchTime) {
    this.searchTime = searchTime;
    int[] times = new int[] {
        searchTime.get(Calendar.YEAR),
        searchTime.get(Calendar.MONTH) + 1,
        searchTime.get(Calendar.DATE)
    };
    recordManager.searchFileByTime(times);
  }

  public void searchRecordByFile(Calendar searchTime) {
    this.searchTime = searchTime;
    if (recordManager instanceof DevRecordManager) {
      searchTime.set(Calendar.HOUR_OF_DAY, 0);
      searchTime.set(Calendar.MINUTE, 0);
      searchTime.set(Calendar.SECOND, 0);

      Calendar endTime = (Calendar) searchTime.clone();
      endTime.set(Calendar.HOUR_OF_DAY, 23);
      endTime.set(Calendar.MINUTE, 59);
      endTime.set(Calendar.SECOND, 59);

      ((DevRecordManager) recordManager).searchFileByTime(searchTime, endTime);
    }
  }

  public void searchRecordByFile(Calendar startTime, Calendar endTime) {
    if (recordManager instanceof DevRecordManager) {
      ((DevRecordManager) recordManager).searchFileByTime(startTime, endTime);
    }
  }

  /**
   * @param position
   */
  // @Override
  public void startPlayRecord(int position) {
    H264_DVR_FILE_DATA recordInfo = recordList.get(position);
    Calendar playCalendar = TimeUtils.getNormalFormatCalender(recordInfo.getStartTimeOfYear());
    Calendar endCalendar;
    endCalendar = Calendar.getInstance();
    endCalendar.setTime(playCalendar.getTime());
    endCalendar.set(Calendar.HOUR_OF_DAY, 23);
    endCalendar.set(Calendar.MINUTE, 59);
    endCalendar.set(Calendar.SECOND, 59);

    recordManager.startPlay(playCalendar, endCalendar);
  }

  public void capture(String path) {
    recordManager.capture(path);
  }

  public void startRecord(String path) {
    if (!recordManager.isRecord()) {
      recordManager.startRecord(path);
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

  public boolean isRecordPlay() {
    return recordManager.getPlayState() == PlayerAttribute.E_STATE_PlAY;
  }

  public int getShowCount() {
    return timeCount;
  }

  public int getTimeUnit() {
    return timeUnit;
  }

  public void setPlayTimeBySecond(int secondTime) {
    this.playTimeBySecond = secondTime;
  }

  public int getPlayTimeBySecond() {
    return playTimeBySecond;
  }

  // TODO: переработать так как сейчас непонятно как работает
  public void seekToTime(int times) {
    int[] time = { searchTime.get(Calendar.YEAR), searchTime.get(Calendar.MONTH) + 1,
        searchTime.get(Calendar.DAY_OF_MONTH), 0, 0, 0 };
    int absTime = FunSDK.ToTimeType(time) + times;
    recordManager.seekToTime(times, absTime);
  }

  // TODO: понять зачем это надо
  public void setPlayTimeByMinute(int minute) {
    // result >= 0 返回有效的时间,< 0 保持原来的时间
    int result = recordManager.dealWithRecordEffectiveByMinute(minute);
    if (result >= 0) {
      playTimeByMinute = result;
      playTimeBySecond = 0;
    }
  }

  public int getPlayTimeByMinute() {
    return playTimeByMinute;
  }

  public void setRecordType(int recordType) {
    this.recordPlayType = recordType;
  }

  public void downloadFile(int position, String path) {
    if (position >= recordList.size()) {
      return;
    }

    H264_DVR_FILE_DATA data = recordList.get(position);
    if (data != null) {
      String fileName = data.getStartTimeOfYear() + "_" + data.getEndTimeOfYear() + ".mp4";
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

  public void setPlaySpeed(int playSpeed) {
    recordManager.setPlaySpeed(playSpeed);
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
        recordList.addAll(((DevRecordManager) recordManager).getFileDataList());

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

        dealWithRecordTimeList((char[][]) data);
        // TODO: отправить в реакт данные о том что поиск успешен
        // WritableMap map = Arguments.createMap();
        // map.putBoolean("isSearchResult2", true);
        // eventEmitter.sendEvent(map,
        // RecordEventEmitter.EVENT_SEARCH_RECORD_BY_FILES_RESULT);

      }

      // haveRecordMap = DevDataCenter.getInstance().getHasRecordFile();
    } else {
      // отправить в реакт данные о том что поиск не успешен
      // iDevRecordView.onSearchRecordByFileResult(false);
      WritableMap map = Arguments.createMap();
      map.putBoolean("isSearchResult3", false);
      eventEmitter.sendEvent(map,
          RecordEventEmitter.EVENT_SEARCH_RECORD_BY_FILES_RESULT);
    }
  }

  private void dealWithRecordTimeList(char[][] minutes) {
    recordTimeList.clear();
    int count = 24 * 60 / timeUnit;
    int n = timeUnit / 10;
    int i = 0, j = 0;

    for (i = 0; i < timeCount / 2; i++) {
      recordTimeMap = new HashMap<String, Object>();
      recordTimeList.add(recordTimeMap);
    }

    for (i = 0; i < count; i++) {

      String time = TimeUtils.formatTimes(i * timeUnit);
      System.out.println("time:" + time);
      char[][] data = new char[n][];

      recordTimeMap = new HashMap<String, Object>();
      for (j = 0; j < n; ++j) {
        data[j] = minutes[n * i + j];
      }

      recordTimeMap.put("data", data);
      recordTimeMap.put("time", time);
      recordTimeList.add(recordTimeMap);
    }

    for (i = 0; i < timeCount / 2; i++) {
      recordTimeMap = new HashMap<String, Object>();
      recordTimeList.add(recordTimeMap);
    }
  }

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
    playSpeed = ((RecordPlayerAttribute) attribute).getPlaySpeed();
    WritableMap map = Arguments.createMap();
    map.putInt("playSpeed", playSpeed);
    map.putInt("state", state);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_MEDIA_PLAY_STATE);
  }

  public void onFailed(PlayerAttribute attribute, int msgId, int errorId) {
    // в фансдк демо тут TODO и ничего нет
    WritableMap map = Arguments.createMap();
    map.putInt("msgId", msgId);
    map.putInt("errorId", errorId);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_FAILED);
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
      String time, String rate) {

    WritableMap map = Arguments.createMap();
    // map.putBoolean("isShowTime", isShowTime);
    map.putString("time", time);
    map.putString("rate", rate);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_SHOW_RATE_AND_TIME);
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
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_VIDEO_BUFFER_END);
  }

  public void onPlayStateClick(View view) {
    // в библиотеке тут пусто
  }
  // }

  public void onDebugState(String str) {
    WritableMap map = Arguments.createMap();
    map.putString("state", str);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DEBUG_STATE);
  }

  public void onDownloadProgress(int progress) {
    WritableMap map = Arguments.createMap();
    map.putInt("progress", progress);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DOWNLOAD_PROGRESS);
  }

  public void onDownloadState(int downloadState, String fileName) {
    WritableMap map = Arguments.createMap();
    map.putInt("downloadState", downloadState);
    map.putString("fileName", fileName);
    eventEmitter.sendEvent(map, RecordEventEmitter.EVENT_DOWNLOAD_STATE);
  }

  // слушатель для downloadmanager
  @Override
  public void onDownload(DownloadInfo downloadInfo) {
    if (downloadInfo != null) {
      if (downloadInfo.getDownloadState() == DOWNLOAD_STATE_PROGRESS) {
        int progress = (downloadInfo.getDownloadProgress() + 100 * downloadInfo.getSeq());
        // TODO: создать методы для отправки данных о прогрессе
        // iDevRecordView.onDownloadProgress(progress);
        onDownloadProgress(progress);
      } else {
        // TODO: создать методы для отправки данных о состоянии
        // public static final int DOWNLOAD_STATE_UNINT = 0;
        // public static final int DOWNLOAD_STATE_START = 1;
        // public static final int DOWNLOAD_STATE_PROGRESS = 2;
        // public static final int DOWNLOAD_STATE_COMPLETE = 3;
        // public static final int DOWNLOAD_STATE_STOP = 4;
        // public static final int DOWNLOAD_STATE_FAILED = 5;
        // public static final int DOWNLOAD_STATE_COMPLETE_ALL = 6;
        // iDevRecordView.onDownloadState(downloadInfo.getDownloadState(),
        // downloadInfo.getSaveFileName());
        onDownloadState(downloadInfo.getDownloadState(),
            downloadInfo.getSaveFileName());
      }

      System.out
          .println("download-->" + downloadInfo.getDownloadState() + " progress:" + downloadInfo.getDownloadProgress());
    }
  }
}
