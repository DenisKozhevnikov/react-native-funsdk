package com.funsdk.manager.search;

import android.os.Message;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Arguments;

import com.basic.G;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FINDINFO;
import com.lib.sdk.struct.SDK_SearchByTime;
import com.lib.sdk.struct.SDK_SearchByTimeResult;
import com.manager.db.DevDataCenter;
import com.manager.device.media.attribute.RecordPlayerAttribute;

import java.util.Calendar;

import com.funsdk.utils.enums.EUIMSG;

public class SearchByTime implements IFunSDKResult {
  private DevDataCenter devDataCenter;
  private H264_DVR_FINDINFO fileInfo;
  private int userId;
  private String devId;
  private RecordPlayerAttribute playerAttribute;
  private Promise promise;

  public SearchByTime(String deviceId, Promise currentPromise) {
    devDataCenter = DevDataCenter.getInstance();
    fileInfo = new H264_DVR_FINDINFO();
    userId = FunSDK.GetId(userId, this);
    devId = deviceId;
    playerAttribute = new RecordPlayerAttribute(deviceId);
    promise = currentPromise;
  }

  public String getDevId() {
    return devId;
  }

  public int searchFileByTime(
      Calendar time,
      int streamType,
      int channelId,
      int fileType,
      int seq) {

    System.out.println("fileType: ");
    System.out.println(playerAttribute.getFileType());

    SDK_SearchByTime search_info = new SDK_SearchByTime();
    search_info.st_6_nHighStreamType = 0;
    search_info.st_7_nLowStreamType = streamType;

    if (channelId < 32) {
      search_info.st_1_nLowChannel = (1 << channelId);
    } else {
      search_info.st_0_nHighChannel = (1 << (channelId - 32));
    }

    search_info.st_2_nFileType = fileType;

    // передает данные только одного дня, пробовал на нескольких, но итог безутешный
    // start time
    search_info.st_3_stBeginTime.st_0_year = time.get(Calendar.YEAR);
    search_info.st_3_stBeginTime.st_1_month = time.get(Calendar.MONTH) + 1;
    search_info.st_3_stBeginTime.st_2_day = time.get(Calendar.DATE);
    search_info.st_3_stBeginTime.st_4_hour = 0;
    search_info.st_3_stBeginTime.st_5_minute = 0;
    search_info.st_3_stBeginTime.st_6_second = 0;

    // end time
    search_info.st_4_stEndTime.st_0_year = time.get(Calendar.YEAR);
    search_info.st_4_stEndTime.st_1_month = time.get(Calendar.MONTH) + 1;
    search_info.st_4_stEndTime.st_2_day = time.get(Calendar.DATE);
    search_info.st_4_stEndTime.st_4_hour = 23;
    search_info.st_4_stEndTime.st_5_minute = 59;
    search_info.st_4_stEndTime.st_6_second = 59;

    // https://developer.jftech.com/docs/?menusId=ab9a6dddd50c46a6af8a913b472ed015&siderid=1101ce00e1ad4b2e9de5ead32e1cb26c&lang=en#docs-hash-4
    FunSDK.DevFindFileByTime(userId, getDevId(), G.ObjToBytes(search_info), 10000, seq);
    return 0;
  }

  // https://developer.jftech.com/docs/?menusId=8af0e7f3d4af49eab71cfdd8d7e47cef&siderid=c73c3a8ee303443694928c50a299f223&lang=en#docs-hash-6
  /// < The video recording uses 720 bytes of 5760 bits to represent 1440 minutes
  /// of the day
  /// < 0000: No recording 0001:F_COMMON 0002:F_ALERT 0003:F_DYNAMIC 0004:F_CARD
  /// 0005:F_HAND
  private void dealWithRecordTimeList(char[][] minutes) {
    WritableArray charArray = Arguments.createArray();
    WritableArray minutesStatusArray = Arguments.createArray();
    int charsCount = 0;
    int minutesCount = 0;

    for (char[] recordRow : minutes) {
      for (char recordChar : recordRow) {
        // recordInfo - варианты числе 0, 17, 19, 49, 51...
        int recordInfo = (int) recordChar;
        charArray.pushInt(recordInfo);
        charsCount++;

        // преобразует recordInfo в двоичный формат и выполняет побитовую операцию "и" с
        // 15(1111) получая номер статуса
        //
        // пример: 49 преобразует в 0011 0001
        // побитовая операция "и" 0011 0001 & 0000 1111
        // получает 1 для первой минуты
        int firstMinute = recordInfo & 15;
        minutesStatusArray.pushInt(firstMinute);
        minutesCount++;

        // сдвигает на 4 бита вправо
        //
        // пример: 49 преобразует в 0011 0001
        // сдвигает на 4 бита вправо и получает: 0011
        // побитовая операция "и" 0000 0011 & 0000 1111
        // получает 3 для второй минуты
        int secondMinute = recordInfo >> 4 & 15;
        minutesStatusArray.pushInt(secondMinute);
        minutesCount++;
      }
    }

    WritableMap map = Arguments.createMap();
    map.putArray("charList", charArray);
    map.putArray("minutesStatusList", minutesStatusArray);
    map.putInt("charsCount", charsCount);
    map.putInt("minutesCount", minutesCount);
    promise.resolve(map);
  }

  public void searchResult(Object data) {
    if (data != null) {
      dealWithRecordTimeList((char[][]) data);
    } else {
      promise.resolve(null);
    }
  }

  public void onFailed(int msgId, int errorId) {
    promise.reject(msgId + " " + errorId);
  }

  public byte[] getRecordTimes(int arg1, byte[] pData, String dataJson, int chnNum) {
    if (null == pData) {
      return null;
    }
    SDK_SearchByTimeResult info = new SDK_SearchByTimeResult();
    System.out.println("special pring pData[0-1]: " + pData[0] + pData[1]);

    G.BytesToObj(info, pData);
    return info.st_1_ByTimeInfo[0].st_1_cRecordBitMap;
  }

  private int showRecordType(int index, byte b) {
    int min = index * 2;
    int flag = 0;
    int first_min = 0;
    if ((b >> 4) != 0 || (b & 0xf) != 0)
      flag++;
    boolean hasRecord = ((b & 0xf) != 0) ? true : false;
    // 获取开始的录像时间
    if (hasRecord && flag == 1 && first_min == 0) {
      first_min = min;
    }
    devDataCenter.setHasRecordFile(min, hasRecord);
    min++;
    hasRecord = ((b >> 4) != 0) ? true : false;
    if (hasRecord && flag == 1 && first_min == 0) {
      first_min = min;
    }
    devDataCenter.setHasRecordFile(min, hasRecord);
    return flag > 0 ? first_min : -1;
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    switch (msg.what) {
      case EUIMSG.DEV_FIND_FILE_BY_TIME:
        boolean hasRecords = false;
        if (msg.arg1 < 0) {
          onFailed(msg.what, msg.arg1);
        } else {
          byte[] pRet = getRecordTimes(msg.arg2, ex.pData, ex.str, 1);
          if (null != pRet) {
            char[][] datas = new char[144][];
            for (int i = 0, k = 0; i < pRet.length; i += 5, k++) {
              char data[] = { (char) pRet[i], (char) pRet[i + 1], (char) pRet[i + 2], (char) pRet[i + 3],
                  (char) pRet[i + 4] };

              datas[k] = data;
            }
            for (int i = 0; i < pRet.length; i++) {
              int ret = showRecordType(i, pRet[i]);

              if (!hasRecords && ret >= 0) {
                hasRecords = true;
              }
            }
            if (null != promise) {
              System.out.println("searchResult first null " + msg.what);
              searchResult(hasRecords ? datas : null);
            }
          } else {
            System.out.println("searchResult second null " + msg.what);

            if (null != promise) {
              searchResult(null);
            }
          }
        }
        break;
      default:
        break;
    }
    return 0;
  }

}