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

import com.funsdk.utils.enums.EUIMSG;

public class FunSDKDeviceImageModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private ReactApplicationContext reactContext;

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
    String timestamp = params.getString("timestamp");
    // уникальный номер
    int seq = params.getInt("seq");

    if (isFunSDKResultAdded == false) {
      mUserId = FunSDK.GetId(mUserId, this);
      isFunSDKResultAdded = true;
    }

    String path = mSaveImageDir + File.separator + mDevId + "_" + channelId + "_" + timestamp + "thumb.jpg";

    // размеры изображения
    int imgHeight = imgSizes.getInt("imgHeight"); // 160
    int imgWidth = imgSizes.getInt("imgWidth"); // 90

    // время изображения
    Date sDate = DataConverter.stringToDate(timestamp);

    int year = sDate.getYear() + 1900;
    int month = sDate.getMonth() + 1;
    int day = sDate.getDate();
    int hour = sDate.getHours();
    int minute = sDate.getMinutes();
    int second = sDate.getSeconds();

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
        0, down.mTimes, down.mPath, 0, down.mSeq);
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
    System.out.println(msgContent.toString());
    // System.out.println("onFunSDKResult message " + message.what);
    switch (message.what) {
      case EUIMSG.DOWN_RECODE_BPIC_START: // Начнется загрузка миниатюр видео
        // System.out.println("image load start");
        break;
      case EUIMSG.DOWN_RECODE_BPIC_FILE: // Загрузка миниатюр видео – возвращены результаты загрузки файла.
        // System.out.println("image load end");
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
          // if (mBitmapMaps == null) {
          // mBitmapMaps = new HashMap<>();
          // }

          DownItemData downItemData = mDownloadResultMap.get(msgContent.seq);

          // Bitmap bitmap;
          if (downItemData != null && downItemData.mWidth > 0) {
            // bitmap = XUtils.createImageThumbnail(msgContent.str);
            // mBitmapMaps.put(msgContent.str, bitmap);
          } else {
            // bitmap = BitmapFactory.decodeFile(msgContent.str);
            // mBitmapMaps.put(msgContent.str, bitmap);
          }

          if (downItemData != null && downItemData.mListener != null) {
            downItemData.mListener.onDownloadResult(true, msgContent.str, downItemData.mType, msgContent.seq);
          } else {
            System.out.println("mListener");
            // if (mListener != null) {
            // if (downItemData != null) {
            // mListener.onDownloadResult(true, msgContent.str, bitmap,
            // downItemData.mType, msgContent.seq);
            // } else {
            // mListener.onDownloadResult(true, msgContent.str, bitmap,
            // 0, msgContent.seq);
            // }
            // }
          }

          mDownloadResultMap.remove(msgContent.seq);
        }

        mIsDownloading = false;
        downloadImage();
        break;
      case EUIMSG.DOWN_RECODE_BPIC_COMPLETE: // Загрузка миниатюр видео завершена (окончание)
        // System.out.println("image load complete");
        break;
      default:
        // System.out.println("image load default " + message.what);
        break;
    }
    return 0;
  }

}
