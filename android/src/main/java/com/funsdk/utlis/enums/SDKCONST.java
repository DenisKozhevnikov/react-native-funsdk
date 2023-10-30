package com.funsdk.utils.enums;

public class SDKCONST {

  public interface EMSType {
    int none = 0;
    int h264 = 1;
    int jpg = 2;
    int mp4 = 3;
    int idximg = 4;
  }

  public interface EMSSubType {
    int ALL = 67108863;
    int ALERT = 0;
    int DYNAMIC = 12;
    int HAND = 7;
    int SPT_KEY = 10;
    int KEY = 10;
    int URGENT = 21;
    int ORIGINAL = 17;
    int INVASION = 8;
    int STRANDED = 18;
    int FACE = 5;
    int CARNO = 13;
    int CHANGE = 6;
  }

  public interface StreamType {
    int Main = 0;
    int Extra = 1;
    int ALL = 2;
  }

  public interface FileType {
    int SDK_RECORD_ALL = 0;
    int SDK_RECORD_ALARM = 1;
    int SDK_RECORD_DETECT = 2;
    int SDK_RECORD_REGULAR = 3;
    int SDK_RECORD_MANUAL = 4;
    int SDK_PIC_ALL = 10;
    int SDK_PIC_ALARM = 11;
    int SDK_PIC_DETECT = 12;
    int SDK_PIC_REGULAR = 13;
    int SDK_PIC_MANUAL = 14;
    int SDK_TYPE_NUM = 15;
  }
}