package com.funsdk.utils.device.media.playback;

import android.os.Message;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.basic.G;
import com.lib.EFUN_ATTR;
import com.lib.EUIMSG;
import com.lib.FunSDK;
import com.lib.MsgContent;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.lib.sdk.struct.H264_DVR_FINDINFO;
import com.lib.sdk.struct.SDK_SearchByTime;
import com.lib.sdk.struct.SDK_SearchByTimeResult;
import com.manager.device.media.MediaManager;
import com.manager.device.media.attribute.RecordPlayerAttribute;
import com.manager.device.media.playback.RecordManager;

import com.utils.TimeUtils;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static com.manager.db.Define.MEDIA_DATA_TYPE_NOT_DECODE;
import static com.manager.db.Define.MEDIA_DATA_TYPE_YUV_NOT_DISPLAY;
import static com.manager.device.media.attribute.PlayerAttribute.E_STATE_PLAY_SEEK;
import static com.manager.device.media.attribute.PlayerAttribute.E_STATE_READY_PLAY;

public class UpdatedDevRecordManager extends RecordManager {

  private H264_DVR_FINDINFO fileInfo;
  private List<H264_DVR_FILE_DATA> fileDataList;

  public UpdatedDevRecordManager(ViewGroup playView, RecordPlayerAttribute playerAttribute) {
    super(playView, playerAttribute);
    fileInfo = new H264_DVR_FINDINFO();
    fileInfo.st_0_nChannelN0 = playerAttribute.getChnnel();
    fileInfo.st_1_nFileType = playerAttribute.getFileType();
    fileInfo.st_6_StreamType = playerAttribute.getStreamType();
  }

  @Override
  public int searchFile() {
    if (!isSearching) {
      if (fileDataList != null) {
        fileDataList.clear();
      }
      stopDevSearchPic();
      int iret = FunSDK.DevFindFile(userId, getDevId(), G.ObjToBytes(fileInfo), 2000, 10000, 0);
      isSearching = true;
      return iret;
    }
    return 0;
  }

  @Override
  public int searchFileByTime(int[] time) {
    fileInfo.st_3_endTime.st_0_dwYear = fileInfo.st_2_startTime.st_0_dwYear = time[0];
    fileInfo.st_3_endTime.st_1_dwMonth = fileInfo.st_2_startTime.st_1_dwMonth = time[1];
    fileInfo.st_3_endTime.st_2_dwDay = fileInfo.st_2_startTime.st_2_dwDay = time[2];
    SDK_SearchByTime search_info = new SDK_SearchByTime();
    search_info.st_6_nHighStreamType = 0;
    search_info.st_7_nLowStreamType = fileInfo.st_6_StreamType;
    if (fileInfo.st_0_nChannelN0 < 32) {
      search_info.st_1_nLowChannel = (1 << fileInfo.st_0_nChannelN0);
    } else {
      search_info.st_0_nHighChannel = (1 << (fileInfo.st_0_nChannelN0 - 32));
    }
    search_info.st_2_nFileType = fileInfo.st_1_nFileType;
    search_info.st_3_stBeginTime.st_0_year = time[0];
    search_info.st_3_stBeginTime.st_1_month = time[1];
    search_info.st_3_stBeginTime.st_2_day = time[2];
    if (time.length > 3) {
      search_info.st_3_stBeginTime.st_4_hour = time[3];
      search_info.st_3_stBeginTime.st_5_minute = time[4];
      search_info.st_3_stBeginTime.st_6_second = time[5];
    } else {
      search_info.st_3_stBeginTime.st_4_hour = 0;
      search_info.st_3_stBeginTime.st_5_minute = 0;
      search_info.st_3_stBeginTime.st_6_second = 0;
    }
    search_info.st_4_stEndTime.st_0_year = time[0];
    search_info.st_4_stEndTime.st_1_month = time[1];
    search_info.st_4_stEndTime.st_2_day = time[2];
    search_info.st_4_stEndTime.st_4_hour = 23;
    search_info.st_4_stEndTime.st_5_minute = 59;
    search_info.st_4_stEndTime.st_6_second = 59;
    FunSDK.DevFindFileByTime(userId, getDevId(), G.ObjToBytes(search_info), 10000, 0);
    return 0;
  }

  public int searchFileByTime(@NonNull Calendar startTime, @NonNull Calendar endTime) {
    if (fileDataList != null) {
      fileDataList.clear();
    }

    int begin[] = { startTime.get(Calendar.YEAR),
        startTime.get(Calendar.MONTH) + 1,
        startTime.get(Calendar.DATE),
        startTime.get(Calendar.HOUR_OF_DAY),
        startTime.get(Calendar.MINUTE),
        startTime.get(Calendar.SECOND) };
    int end[] = { endTime.get(Calendar.YEAR),
        endTime.get(Calendar.MONTH) + 1,
        endTime.get(Calendar.DATE),
        endTime.get(Calendar.HOUR_OF_DAY),
        endTime.get(Calendar.MINUTE),
        endTime.get(Calendar.SECOND) };

    fileInfo.st_2_startTime.st_0_dwYear = begin[0];
    fileInfo.st_2_startTime.st_1_dwMonth = begin[1];
    fileInfo.st_2_startTime.st_2_dwDay = begin[2];
    fileInfo.st_2_startTime.st_3_dwHour = begin[3];
    fileInfo.st_2_startTime.st_4_dwMinute = begin[4];
    fileInfo.st_2_startTime.st_5_dwSecond = begin[5];

    fileInfo.st_3_endTime.st_0_dwYear = end[0];
    fileInfo.st_3_endTime.st_1_dwMonth = end[1];
    fileInfo.st_3_endTime.st_2_dwDay = end[2];
    fileInfo.st_3_endTime.st_3_dwHour = end[3];
    fileInfo.st_3_endTime.st_4_dwMinute = end[4];
    fileInfo.st_3_endTime.st_5_dwSecond = end[5];

    int ret = FunSDK.DevFindFile(userId, getDevId(), G.ObjToBytes(fileInfo), 2000, 10000, 0);
    return ret;
  }

  @Override
  public MediaManager setChnId(int chnId) {
    fileInfo.st_0_nChannelN0 = chnId;
    return super.setChnId(chnId);
  }

  @Override
  public int startPlay(Calendar startTimes, Calendar endTimes) {
    if (startTimes == null || endTimes == null) {
      return 0;
    }

    super.start();

    int[] sTime = {
        startTimes.get(Calendar.YEAR),
        startTimes.get(Calendar.MONTH) + 1,
        startTimes.get(Calendar.DAY_OF_MONTH),
        startTimes.get(Calendar.HOUR_OF_DAY),
        startTimes.get(Calendar.MINUTE),
        startTimes.get(Calendar.SECOND) };

    int[] eTime = {
        endTimes.get(Calendar.YEAR),
        endTimes.get(Calendar.MONTH) + 1,
        endTimes.get(Calendar.DAY_OF_MONTH),
        endTimes.get(Calendar.HOUR_OF_DAY),
        endTimes.get(Calendar.MINUTE),
        endTimes.get(Calendar.SECOND) };

    fileInfo.st_2_startTime.st_0_dwYear = sTime[0];
    fileInfo.st_2_startTime.st_1_dwMonth = sTime[1];
    fileInfo.st_2_startTime.st_2_dwDay = sTime[2];
    fileInfo.st_2_startTime.st_3_dwHour = sTime[3];
    fileInfo.st_2_startTime.st_4_dwMinute = sTime[4];
    fileInfo.st_2_startTime.st_5_dwSecond = sTime[5];

    // в оригинальном devrecordmanager передавался год/месяц/день из sTime
    fileInfo.st_3_endTime.st_0_dwYear = eTime[0];
    fileInfo.st_3_endTime.st_1_dwMonth = eTime[1];
    fileInfo.st_3_endTime.st_2_dwDay = eTime[2];
    fileInfo.st_3_endTime.st_3_dwHour = eTime[3];
    fileInfo.st_3_endTime.st_4_dwMinute = eTime[4];
    fileInfo.st_3_endTime.st_5_dwSecond = eTime[5];
    fileInfo.st_6_StreamType = playerAttribute.getStreamType();
    int lPlayHandle = FunSDK.MediaNetRecordPlayByTime(userId,
        getDevId(), G.ObjToBytes(fileInfo), surfaceView, 0);
    if (playMode == MEDIA_DATA_TYPE_YUV_NOT_DISPLAY) {
      FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_VIEW_VISUAL, userId);
      FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_MEDIA_YUV_USER, userId);
    } else if (playMode == MEDIA_DATA_TYPE_NOT_DECODE) {
      FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_DATA_USER_AND_NO_DEC, userId);
    } else {
      FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_VIEW_VISUAL, userId);
    }
    FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_PCM_SET_SOUND, 100);
    playerAttribute.setPlayHandle(lPlayHandle);
    setPlayState(E_STATE_READY_PLAY);
    return 0;
  }

  @Override
  public int seekToTime(int nTimes, int absTime) {
    super.start();
    if (playerAttribute.getPlayHandle() == 0) {
      fileInfo.st_2_startTime.st_3_dwHour = nTimes / 3600;
      fileInfo.st_2_startTime.st_4_dwMinute = (nTimes % 3600) / 60;
      fileInfo.st_2_startTime.st_5_dwSecond = (nTimes % 3600) % 60;
      fileInfo.st_3_endTime.st_3_dwHour = 23;
      fileInfo.st_3_endTime.st_4_dwMinute = 59;
      fileInfo.st_3_endTime.st_5_dwSecond = 59;
      fileInfo.st_6_StreamType = playerAttribute.getStreamType();
      int lPlayHandle = FunSDK.MediaNetRecordPlayByTime(userId,
          getDevId(), G.ObjToBytes(fileInfo), surfaceView, 0);
      if (playMode == MEDIA_DATA_TYPE_YUV_NOT_DISPLAY) {
        FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_VIEW_VISUAL, userId);
        FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_MEDIA_YUV_USER, userId);
      } else if (playMode == MEDIA_DATA_TYPE_NOT_DECODE) {
        FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_DATA_USER_AND_NO_DEC, userId);
      } else {
        FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_SET_MEDIA_VIEW_VISUAL, userId);
      }
      FunSDK.SetIntAttr(lPlayHandle, EFUN_ATTR.EOA_PCM_SET_SOUND, 100);
      playerAttribute.setPlayHandle(lPlayHandle);
      setPlayState(E_STATE_READY_PLAY);
    } else {
      stopRecord();
      setPlaySpeed(0);
      FunSDK.MediaSeekToTime(playerAttribute.getPlayHandle(), 0, absTime, 0);
      setPlayState(E_STATE_PLAY_SEEK);
    }
    return 0;
  }

  @Override
  public byte[] getRecordTimes(int arg1, byte[] pData, String dataJson, int chnNum) {
    if (null == pData) {
      return null;
    }
    SDK_SearchByTimeResult info = new SDK_SearchByTimeResult();
    G.BytesToObj(info, pData);
    return info.st_1_ByTimeInfo[0].st_1_cRecordBitMap;
  }

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    switch (msg.what) {
      case EUIMSG.DEV_FIND_FILE:
        boolean hasRecords = false;
        if (msg.arg1 >= 0) {
          if (fileDataList == null) {
            fileDataList = new ArrayList<>();
          }
          fileDataList.clear();
          H264_DVR_FILE_DATA datas[] = new H264_DVR_FILE_DATA[msg.arg1];
          for (int i = 0; i < datas.length; i++) {
            datas[i] = new H264_DVR_FILE_DATA();
          }
          G.BytesToObj(datas, ex.pData);
          for (int i = 0; i < datas.length; i++) {
            hasRecords = true;
            fileDataList.add(datas[i]);
          }

          if (null != mediaManagerLs) {
            mediaManagerLs.searchResult(playerAttribute, hasRecords ? datas : null);
          }
        } else {
          if (null != mediaManagerLs) {
            mediaManagerLs.onFailed(playerAttribute, msg.what, msg.arg1);
            mediaManagerLs.searchResult(playerAttribute, null);
          }
        }
        break;
    }
    return super.OnFunSDKResult(msg, ex);
  }

  public List<H264_DVR_FILE_DATA> getFileDataList() {
    return fileDataList;
  }

  public H264_DVR_FILE_DATA getContain(String time) {
    if (StringUtils.isStringNULL(time) || fileDataList == null || fileDataList.isEmpty()) {
      return null;
    }

    Calendar searchCalendar = TimeUtils.getNormalFormatCalender(time);
    long searchTime = searchCalendar.getTimeInMillis();

    for (H264_DVR_FILE_DATA info : fileDataList) {
      if (info != null) {
        long sTime = info.getLongStartTime();
        long eTime = info.getLongEndTime();

        if (searchTime >= sTime && searchTime <= eTime) {
          return info;
        }
      }
    }

    return fileDataList.get(0);
  }
}
