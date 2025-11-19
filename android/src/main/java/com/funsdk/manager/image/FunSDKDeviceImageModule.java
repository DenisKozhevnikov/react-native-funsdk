package com.funsdk.manager.image;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Message;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Arguments;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.lib.SDKCONST;

import com.funsdk.utils.image.DevImageManager;
import com.funsdk.utils.image.BaseImageManager;
import com.funsdk.utils.Constants;
import com.funsdk.utils.DataConverter;
import com.utils.XUtils;

import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.Queue;
import java.util.Date;
import java.util.Calendar;

import com.funsdk.utils.enums.EUIMSG;

// Added imports for video file download by time
import com.manager.db.DownloadInfo;
import com.manager.db.Define;
import com.manager.device.media.download.DownloadManager;

public class FunSDKDeviceImageModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private ReactApplicationContext reactContext;
  private static final String TAG_DWL = "DOWNLOAD_BY_TIME";

  @Override
  public String getName() {
    return "FunSDKDeviceImageModule";
  }

  public FunSDKDeviceImageModule(ReactApplicationContext context) {
    super(context);
    reactContext = context;
  }

  protected int mUserId;
  protected boolean mIsDownloading;
  protected Queue<DownItemData> mDownloadQueue;
  protected HashMap<Integer, DownItemData> mDownloadResultMap;
  protected OnImageManagerListener mListener;
  protected boolean isFunSDKResultAdded = false;

  public class DownItemData implements Serializable {
    public static final int ORIGINAL_IMG = 0; // Оригинальное изображение
    public static final int THUMB_IMG = 1; // Миниатюрное изображение
    String mDevId;
    int mChannelId;
    int mType;
    int mSeq;
    int mWidth = 0; // Размер изображения (0 для оригинального размера)
    int mHeight = 0;
    int mTimes; // Время изображения
    String mPath;
    String mDownloadJsonData; // Исходные данные JSON для сообщений о тревоге или хранения оригинальных данных
                              // видеозаписей
    OnImageManagerListener mListener;
  }

  @ReactMethod
  public void downloadSingleImage(ReadableMap params, Promise promise) {
    String mDevId = params.getString(Constants.DEVICE_ID);
    int channelId = params.getInt(Constants.DEVICE_CHANNEL);
    String mSaveImageDir = params.getString("mSaveImageDir");
    ReadableMap imgSizes = params.getMap("imgSizes");
    // Support both iOS-style { time: {year,month,...} } and Android-style { timestamp: string }
    ReadableMap timeMap = params.hasKey("time") ? params.getMap("time") : null;
    String timestamp = params.hasKey("timestamp") ? params.getString("timestamp") : null;
    // уникальный номер
    int seq = params.getInt("seq");

    if (isFunSDKResultAdded == false) {
      mUserId = FunSDK.GetId(mUserId, this);
      isFunSDKResultAdded = true;
    }

    // Treat mSaveImageDir as a full file path if provided; otherwise build default path
    String path = mSaveImageDir;
    if (path == null || path.isEmpty()) {
      String safeTs = timestamp != null ? timestamp : "";
      path = File.separator + mDevId + "_" + channelId + "_" + safeTs + "thumb.jpg";
    }

    // размеры изображения
    int imgHeight = imgSizes.getInt("imgHeight"); // 160
    int imgWidth = imgSizes.getInt("imgWidth"); // 90

    // Время изображения
    int year, month, day, hour, minute, second;
    if (timeMap != null) {
      year = timeMap.getInt("year");
      month = timeMap.getInt("month");
      day = timeMap.getInt("day");
      hour = timeMap.getInt("hour");
      minute = timeMap.getInt("minute");
      second = timeMap.getInt("second");
    } else {
      // Fallback to string timestamp (e.g. "2025-08-21 00:00:00")
      Date sDate = DataConverter.stringToDate(timestamp);
      year = sDate.getYear() + 1900;
      month = sDate.getMonth() + 1;
      day = sDate.getDate();
      hour = sDate.getHours();
      minute = sDate.getMinutes();
      second = sDate.getSeconds();
    }

    int times = FunSDK.ToTimeType(new int[] { year,
        month, day,
        hour, minute,
        second });

    DownItemData down = new DownItemData();
    down.mHeight = Math.max(imgHeight, 0);
    down.mWidth = Math.max(imgWidth, 0);
    down.mPath = path;
    down.mTimes = times;
    down.mType = SDKCONST.MediaType.VIDEO;
    down.mDevId = mDevId;
    down.mChannelId = channelId;
    down.mSeq = seq;
    down.mListener = getResultCallback(promise);

    if (mDownloadQueue == null) {
      mDownloadQueue = new LinkedBlockingDeque<>();
    }

    if (!mDownloadQueue.contains(down)) {
      mDownloadQueue.add(down);
    }

    if (!mIsDownloading) {
      downloadImage();
    }
  }

  private void downloadImage() {
    if (mDownloadQueue == null || mDownloadQueue.isEmpty()) {
      mIsDownloading = false;
      return;
    }

    if (mDownloadResultMap == null) {
      mDownloadResultMap = new HashMap<>();
    }

    DownItemData down = mDownloadQueue.poll();
    mDownloadResultMap.put(down.mSeq, down);

    FunSDK.DownloadRecordBImage(mUserId, down.mDevId,
        down.mChannelId, down.mTimes, down.mPath, 0, down.mSeq);
  }

  public static FunSDKDeviceImageModule.OnImageManagerListener getResultCallback(Promise promise) {
    return new FunSDKDeviceImageModule.OnImageManagerListener() {

      public void onDownloadResult(boolean isSuccess, String imagePath, int mediaType, int seq) {
        WritableMap map = Arguments.createMap();
        map.putBoolean("isSuccess", isSuccess);
        map.putString("imagePath", imagePath);
        // TODO: convert bitmap to string?
        map.putInt("mediaType", mediaType);
        map.putInt("seq", seq);

        promise.resolve(map);
      }

      public void onDeleteResult(boolean isSuccess, int seq) {
        promise.reject(seq + " " + isSuccess);
      }
    };
  }

  public interface OnImageManagerListener {
    /**
     * Результат обратного вызова для загрузки
     *
     * @param isSuccess успешно ли
     * @param imagePath путь к изображению
     * @param bitmap    изображение// удалено
     * @param mediaType тип медиа
     * @param seq
     */
    void onDownloadResult(boolean isSuccess, String imagePath, int mediaType, int seq);

    /**
     * Результат обратного вызова для удаления изображения
     *
     * @param isSuccess
     * @param seq
     */
    void onDeleteResult(boolean isSuccess, int seq);
  }

  @Override
  public int OnFunSDKResult(Message message, MsgContent msgContent) {
    // System.out.println(msgContent.toString());
    // System.out.println("onFunSDKResult message " + message.what);
    switch (message.what) {
      case EUIMSG.DOWN_RECODE_BPIC_START: // Начнется загрузка миниатюр видео
        break;
      case EUIMSG.DOWN_RECODE_BPIC_FILE: // Загрузка миниатюр видео – возвращены результаты загрузки файла.
        if (message.arg1 < 0) {
          DownItemData downItemData = mDownloadResultMap.get(msgContent.seq);
          if (downItemData != null && downItemData.mListener != null) {
            downItemData.mListener.onDownloadResult(false, null,
                downItemData.mType, msgContent.seq);
          } else if (mListener != null) {
            if (downItemData != null) {
              mListener.onDownloadResult(false, msgContent.str,
                  downItemData.mType, msgContent.seq);
            } else {
              mListener.onDownloadResult(false, null,
                  0, msgContent.seq);
            }
          }
        } else {
          DownItemData downItemData = mDownloadResultMap.get(msgContent.seq);
          if (downItemData != null && downItemData.mListener != null) {
            downItemData.mListener.onDownloadResult(true, msgContent.str, downItemData.mType, msgContent.seq);
          }
          mDownloadResultMap.remove(msgContent.seq);
        }

        mIsDownloading = false;
        downloadImage();
        break;
      case EUIMSG.DOWN_RECODE_BPIC_COMPLETE: // Загрузка миниатюр видео завершена (окончание)
        break;
      default:
        break;
    }
    return 0;
  }

  // New: download video file by time for Android (parity with iOS)
  @ReactMethod
  public void downloadSingleFileByTime(ReadableMap params, final Promise promise) {
    try {
      final String devId = params.getString(Constants.DEVICE_ID);
      final String savePath = params.getString("mSaveImageDir");
      final ReadableMap start = params.getMap("startTime");
      final ReadableMap end = params.getMap("endTime");
      final int channel = params.hasKey(Constants.DEVICE_CHANNEL) ? params.getInt(Constants.DEVICE_CHANNEL) : 0;
      final int streamType = params.hasKey("streamType") ? params.getInt("streamType") : 0;
      final int fileType = params.hasKey("fileType") ? params.getInt("fileType") : 0;
      android.util.Log.e(TAG_DWL, "downloadSingleFileByTime call: devId=" + devId + ", path=" + savePath + ", ch=" + channel + ", streamType=" + streamType + ", fileType=" + fileType + ", start=" + start + ", end=" + end);
      startDownloadByTime(devId, savePath, start, end, channel, streamType, fileType, promise);
    } catch (Exception e) {
      android.util.Log.e(TAG_DWL, "downloadSingleFileByTime exception", e);
      promise.reject("ANDROID_DOWNLOAD_BY_TIME_ERROR", e);
    }
  }

  // New: download video file by filename signature (JS calls this on Android too)
  @ReactMethod
  public void downloadSingleFile(ReadableMap params, final Promise promise) {
    try {
      final String devId = params.getString(Constants.DEVICE_ID);
      final String savePath = params.getString("mSaveImageDir");
      final ReadableMap start = params.getMap("startTime");
      final ReadableMap end = params.getMap("endTime");
      final int channel = params.hasKey(Constants.DEVICE_CHANNEL) ? params.getInt(Constants.DEVICE_CHANNEL) : 0;
      final int streamType = params.hasKey("streamType") ? params.getInt("streamType") : 0;
      final String fileName = params.hasKey("fileName") ? params.getString("fileName") : "";

      if (devId == null || devId.isEmpty()) {
        promise.reject("ANDROID_DOWNLOAD_INVALID_PARAMS", "deviceId is null or empty");
        return;
      }
      if (savePath == null || savePath.isEmpty()) {
        promise.reject("ANDROID_DOWNLOAD_INVALID_PARAMS", "mSaveImageDir (file path) is null or empty");
        return;
      }

      Calendar startCal = Calendar.getInstance();
      startCal.set(start.getInt("year"), start.getInt("month") - 1, start.getInt("day"),
          start.getInt("hour"), start.getInt("minute"), start.getInt("second"));

      Calendar endCal = Calendar.getInstance();
      endCal.set(end.getInt("year"), end.getInt("month") - 1, end.getInt("day"),
          end.getInt("hour"), end.getInt("minute"), end.getInt("second"));

      final DownloadManager dm = DownloadManager.getInstance(new DownloadManager.OnDownloadListener() {
        @Override
        public void onDownload(DownloadInfo info) {
          if (info == null) {
            return;
          }
          if (info.getDownloadState() != DownloadManager.DOWNLOAD_STATE_PROGRESS) {
            WritableMap map = Arguments.createMap();
            boolean success = false;
            try {
              String fp = info.getSaveFileName();
              success = fp != null && !fp.isEmpty() && new File(fp).exists();
            } catch (Throwable ignored) {}
            map.putBoolean("isSuccess", success);
            map.putString("filePath", info.getSaveFileName());
            map.putInt("seq", info.getSeq());
            promise.resolve(map);
          }
        }
      });

      try {
        DownloadInfo di = new DownloadInfo();
        di.setStartTime(startCal);
        di.setEndTime(endCal);
        di.setDevId(devId);

        H264_DVR_FILE_DATA data = new H264_DVR_FILE_DATA();
        // begin
        data.st_3_beginTime.st_0_year = startCal.get(Calendar.YEAR);
        data.st_3_beginTime.st_1_month = startCal.get(Calendar.MONTH) + 1;
        data.st_3_beginTime.st_2_day = startCal.get(Calendar.DAY_OF_MONTH);
        data.st_3_beginTime.st_4_hour = startCal.get(Calendar.HOUR_OF_DAY);
        data.st_3_beginTime.st_5_minute = startCal.get(Calendar.MINUTE);
        data.st_3_beginTime.st_6_second = startCal.get(Calendar.SECOND);
        // end
        data.st_4_endTime.st_0_year = endCal.get(Calendar.YEAR);
        data.st_4_endTime.st_1_month = endCal.get(Calendar.MONTH) + 1;
        data.st_4_endTime.st_2_day = endCal.get(Calendar.DAY_OF_MONTH);
        data.st_4_endTime.st_4_hour = endCal.get(Calendar.HOUR_OF_DAY);
        data.st_4_endTime.st_5_minute = endCal.get(Calendar.MINUTE);
        data.st_4_endTime.st_6_second = endCal.get(Calendar.SECOND);
        data.st_0_ch = channel;
        data.st_6_StreamType = streamType;
        data.st_2_fileName = (fileName != null ? fileName : "").getBytes();

        di.setObj(data);
        di.setSaveFileName(savePath);
        di.setDownloadType(Define.DOWNLOAD_VIDEO_BY_FILE);
        dm.addDownload(di);
        dm.startDownload();
      } catch (Exception e) {
        promise.reject("ANDROID_DOWNLOAD_START_ERROR", e);
      }
    } catch (Exception e) {
      promise.reject("ANDROID_DOWNLOAD_FILE_ERROR", e);
    }
  }

  private void startDownloadByTime(String devId, String savePath, ReadableMap start, ReadableMap end,
      int channel, int streamType, int fileType, final Promise promise) {
    if (devId == null || devId.isEmpty()) {
      promise.reject("ANDROID_DOWNLOAD_INVALID_PARAMS", "deviceId is null or empty");
      return;
    }
    if (savePath == null || savePath.isEmpty()) {
      promise.reject("ANDROID_DOWNLOAD_INVALID_PARAMS", "mSaveImageDir (file path) is null or empty");
      return;
    }
    try {
      File parent = new File(savePath).getParentFile();
      if (parent != null && !parent.exists()) {
        parent.mkdirs();
      }
    } catch (Throwable ignored) {}
    Calendar startCal = Calendar.getInstance();
    startCal.set(start.getInt("year"), start.getInt("month") - 1, start.getInt("day"),
        start.getInt("hour"), start.getInt("minute"), start.getInt("second"));

    Calendar endCal = Calendar.getInstance();
    endCal.set(end.getInt("year"), end.getInt("month") - 1, end.getInt("day"),
        end.getInt("hour"), end.getInt("minute"), end.getInt("second"));

    android.util.Log.e(TAG_DWL, "startDownloadByTime params: devId=" + devId
        + ", savePath=" + savePath
        + ", startCal=" + startCal.getTime()
        + ", endCal=" + endCal.getTime()
        + ", ch=" + channel
        + ", streamType=" + streamType
        + ", fileType=" + fileType);

    final DownloadManager dm = DownloadManager.getInstance(new DownloadManager.OnDownloadListener() {
      @Override
      public void onDownload(DownloadInfo info) {
        if (info == null) {
          return;
        }
        android.util.Log.e(TAG_DWL, "onDownload state=" + info.getDownloadState() + ", file=" + info.getSaveFileName() + ", seq=" + info.getSeq());
        if (info.getDownloadState() != DownloadManager.DOWNLOAD_STATE_PROGRESS) {
          WritableMap map = Arguments.createMap();
          boolean success = false;
          try {
            String fp = info.getSaveFileName();
            success = fp != null && !fp.isEmpty() && new File(fp).exists();
          } catch (Throwable ignored) {}
          map.putBoolean("isSuccess", success);
          map.putString("filePath", info.getSaveFileName());
          map.putInt("seq", info.getSeq());
          android.util.Log.e(TAG_DWL, "download finished: success=" + success + ", filePath=" + info.getSaveFileName());
          promise.resolve(map);
        }
      }
    });

    try {
      DownloadInfo di = new DownloadInfo();
      di.setStartTime(startCal);
      di.setEndTime(endCal);
      di.setDevId(devId);

      // Build minimal file info to avoid internal null filename usage
      H264_DVR_FILE_DATA data = new H264_DVR_FILE_DATA();
      // begin time
      data.st_3_beginTime.st_0_year = startCal.get(Calendar.YEAR);
      data.st_3_beginTime.st_1_month = startCal.get(Calendar.MONTH) + 1;
      data.st_3_beginTime.st_2_day = startCal.get(Calendar.DAY_OF_MONTH);
      data.st_3_beginTime.st_4_hour = startCal.get(Calendar.HOUR_OF_DAY);
      data.st_3_beginTime.st_5_minute = startCal.get(Calendar.MINUTE);
      data.st_3_beginTime.st_6_second = startCal.get(Calendar.SECOND);
      // end time
      data.st_4_endTime.st_0_year = endCal.get(Calendar.YEAR);
      data.st_4_endTime.st_1_month = endCal.get(Calendar.MONTH) + 1;
      data.st_4_endTime.st_2_day = endCal.get(Calendar.DAY_OF_MONTH);
      data.st_4_endTime.st_4_hour = endCal.get(Calendar.HOUR_OF_DAY);
      data.st_4_endTime.st_5_minute = endCal.get(Calendar.MINUTE);
      data.st_4_endTime.st_6_second = endCal.get(Calendar.SECOND);
      // channel and stream
      data.st_0_ch = channel;
      data.st_6_StreamType = streamType;
      // Avoid null filename usage inside SDK consumers
      data.st_2_fileName = new byte[0];

      di.setObj(data);
      di.setSaveFileName(savePath);
      // Download by time
      di.setDownloadType(Define.DOWNLOAD_VIDEO_BY_TIME);
      android.util.Log.e(TAG_DWL, "enqueue download: savePath=" + savePath + ", downloadType=DOWNLOAD_VIDEO_BY_TIME");
      dm.addDownload(di);
      android.util.Log.e(TAG_DWL, "startDownload()");
      dm.startDownload();
    } catch (Exception e) {
      android.util.Log.e(TAG_DWL, "download start exception", e);
      promise.reject("ANDROID_DOWNLOAD_START_ERROR", e);
    }
  }
}
