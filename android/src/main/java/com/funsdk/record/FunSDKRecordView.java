package com.funsdk.record;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.content.Intent;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.Promise;

import com.lib.SDKCONST;

import com.manager.device.DeviceManager;
import com.manager.device.media.TalkManager;
import com.manager.device.media.monitor.MonitorManager;
import com.manager.ScreenOrientationManager;

import com.manager.device.media.playback.RecordManager;
import com.manager.device.media.playback.DevRecordManager;

import com.lib.FunSDK;
import java.util.Calendar;
import java.util.List;
import java.util.Arrays;
import java.util.ArrayList;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import static com.manager.device.media.MediaManager.PLAY_DEV_PLAYBACK;
import com.manager.device.media.attribute.RecordPlayerAttribute;
import com.utils.TimeUtils;
import com.funsdk.utils.Constants;

import java.util.HashMap;

public class FunSDKRecordView extends LinearLayout {
  private String devId;
  private final ThemedReactContext themedReactContext;
  private Activity activity = null;
  private HashMap<Integer, MonitorManager> monitorManagers;
  protected DeviceManager manager = this.getManager();
  private RecordManager recordManager;
  private List<H264_DVR_FILE_DATA> recordList;
  private RecordPlayerAttribute recordPlayerAttribute;
  private DevRecordManager devRecordManager;

  public FunSDKRecordView(ThemedReactContext context) {
    super(context);
    recordList = new ArrayList<>();
    this.themedReactContext = context;
    this.activity = ((ReactContext) getContext()).getCurrentActivity();
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
    
    if (recordManager != null) {
    } else {
     recordManager = manager.createRecordPlayer(this, getDevId(), PLAY_DEV_PLAYBACK);
     recordPlayerAttribute = new RecordPlayerAttribute(getDevId());
    devRecordManager = new DevRecordManager(this, recordPlayerAttribute);
    recordList = devRecordManager.getFileDataList();
     
     //print(recordList);
     //startPlayRecord(0);
     //((DevRecordManager) recordManager).getFileDataList();
     /*if (recordManager instanceof DevRecordManager) {
      System.out.println("recordManager instanceof DevRecordManager");
     //((DevRecordManager) recordManager).getFileDataList();
     
    System.out.println(recordList.size());
     }*/
    }
  }

  public void print(List recordList) {
    System.out.println("recordList");
  }

    public void startPlayRecord(int position) {
        H264_DVR_FILE_DATA recordInfo = recordList.get(position);
        System.out.println(recordInfo);
        Calendar playCalendar = TimeUtils.getNormalFormatCalender(recordInfo.getStartTimeOfYear());
        Calendar endCalendar;
        endCalendar = Calendar.getInstance();
        endCalendar.setTime(playCalendar.getTime());
        endCalendar.set(Calendar.HOUR_OF_DAY, 23);
        endCalendar.set(Calendar.MINUTE, 59);
        endCalendar.set(Calendar.SECOND, 59);
        recordManager.startPlay(playCalendar, endCalendar);

    }

  public void getListRecords() {
    

      System.out.println(recordList);


    //recordList.addAll(((DevRecordManager) recordManager).getFileDataList());
    //recordList.addAll(DevRecordManager(this, getDevId()).getFileDataList());
    //System.out.println(recordList);
  }

}      
    //recordList.addAll(((DevRecordManager) recordManager).getFileDataList());
       //System.out.println(Arrays.toString(((DevRecordManager) recordManager).getFileDataList()));
      //(((DevRecordManager) recordManager).getFileDataList()).forEach(System.out::println);;
      //System.out.println(recordList.toString());
       //recordManager.setVideoFullScreen(false); 
      //((DevRecordManager) recordManager).startPlay();