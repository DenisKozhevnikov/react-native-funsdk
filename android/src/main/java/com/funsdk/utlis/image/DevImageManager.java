package com.funsdk.utils.image;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Message;

import com.alibaba.fastjson.JSON;
import com.lib.EUIMSG;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.Mps.MpsClient;
import com.lib.MsgContent;
import com.lib.SDKCONST;
import com.lib.cloud.CloudDirectory;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.bean.alarm.AlarmInfo;
import com.lib.sdk.bean.cloudmedia.CloudMediaFileInfoBean;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.utils.FileUtils;
import com.utils.XUtils;

import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.LinkedBlockingDeque;

// from 4.0 lib version
/**
 * @author hws
 * @class 设备端图片管理:下载缩略图、原图和录像的缩略图
 * @time 2019-08-26 18:27
 */
public class DevImageManager extends BaseImageManager implements IFunSDKResult {
    public DevImageManager(String saveImageDir) {
        super(saveImageDir);
    }

    /**
     * 下载视频缩略图
     *
     * @param h264DvrFileData
     * @param imgWidth        缩略图宽
     * @param imgHeight       缩略图高
     * @param listener
     */
    public Bitmap downloadVideoThumb(H264_DVR_FILE_DATA h264DvrFileData, int seq, int imgWidth, int imgHeight,
            OnImageManagerListener listener, boolean isDownloadFromDev) {
        if (h264DvrFileData == null) {
            if (listener != null) {
                listener.onDownloadResult(false, null, null, SDKCONST.MediaType.VIDEO, seq);
            }
            return null;
        }

        try {
            String path = mSaveImageDir + File.separator + mDevId + "_"
                    + h264DvrFileData.getLongStartTime() + h264DvrFileData.getLongEndTime() + "thumb.jpg";

            if (FileUtils.isFileExist(path)) {
                if (mBitmapMaps == null) {
                    mBitmapMaps = new HashMap<>();
                }

                Bitmap bitmap = BitmapFactory.decodeFile(path);
                mBitmapMaps.put(path, bitmap);
                if (listener != null) {
                    listener.onDownloadResult(true, path, bitmap, SDKCONST.MediaType.VIDEO, seq);
                }
                return bitmap;
            }

            Bitmap bitmap = getPicBitmap(path);
            if (bitmap != null) {
                if (listener != null) {
                    listener.onDownloadResult(true, path, bitmap, SDKCONST.MediaType.VIDEO, seq);
                }
                return bitmap;
            }

            int times = FunSDK.ToTimeType(new int[] { h264DvrFileData.st_3_beginTime.st_0_year,
                    h264DvrFileData.st_3_beginTime.st_1_month, h264DvrFileData.st_3_beginTime.st_2_day,
                    h264DvrFileData.st_3_beginTime.st_4_hour, h264DvrFileData.st_3_beginTime.st_5_minute,
                    h264DvrFileData.st_3_beginTime.st_6_second });

            DownItemData down = new DownItemData();
            down.mHeight = Math.max(imgHeight, 0);
            down.mWidth = Math.max(imgWidth, 0);
            down.mPath = path;
            down.mTimes = times;
            down.mType = SDKCONST.MediaType.VIDEO;
            down.mSeq = seq;
            down.mListener = listener;

            if (mDownloadQueue == null) {
                mDownloadQueue = new LinkedBlockingDeque<>();
            }

            if (!mDownloadQueue.contains(down)) {
                mDownloadQueue.add(down);
            }

            if (!mIsDownloading && isDownloadFromDev) {
                downloadImage();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * 下载设备端图片
     *
     * @param h264DvrFileData 录像信息
     * @param nSeq            回传的Id
     * @param imgWidth        图片宽度
     * @param imgHeight       图片高度
     * @return
     */
    public Bitmap downloadVideoThumb(H264_DVR_FILE_DATA h264DvrFileData, int nSeq, int imgWidth, int imgHeight) {
        return downloadVideoThumb(h264DvrFileData, nSeq, imgWidth, imgHeight, mListener, true);
    }

    /**
     * 下载原图或者缩略图
     *
     * @param h264DvrFileData 录像信息
     * @param imgWidth        图片宽度
     * @param imgHeight       图片高度
     * @param listener
     */
    public Bitmap downloadVideoThumb(H264_DVR_FILE_DATA h264DvrFileData, int imgWidth, int imgHeight,
            OnImageManagerListener listener) {
        return downloadVideoThumb(h264DvrFileData, 0, imgWidth, imgHeight, listener, true);
    }

    /**
     * 图片下载类型
     */
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

        FunSDK.DownloadRecordBImage(mUserId, mDevId,
                0, down.mTimes, down.mPath, 0, down.mSeq);
    }

    /**
     * 取消下载
     */
    public void cancel() {
        if (mDownloadQueue != null) {
            mDownloadQueue.clear();
        }
    }

    /**
     * 释放资源
     */
    public void release() {
        if (mBitmapMaps != null) {
            for (Map.Entry<String, Bitmap> entry : mBitmapMaps.entrySet()) {
                if (entry != null) {
                    Bitmap bitmap = entry.getValue();
                    if (bitmap != null) {
                        bitmap.recycle();
                    }
                }
            }

            mBitmapMaps.clear();
        }

        cancel();
    }

    public Bitmap getPicBitmap(H264_DVR_FILE_DATA h264DvrFileData, boolean isThumb) {
        if (h264DvrFileData == null) {
            return null;
        }

        String path;
        if (isThumb) {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + h264DvrFileData.getLongStartTime() + h264DvrFileData.getLongEndTime() + "thumb.jpg";
        } else {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + h264DvrFileData.getLongStartTime() + h264DvrFileData.getLongEndTime() + ".jpg";
        }

        return getPicBitmap(path);
    }

    @Override
    public int OnFunSDKResult(Message message, MsgContent msgContent) {
        switch (message.what) {
            case EUIMSG.DOWN_RECODE_BPIC_START://// 录像缩略图下载开始
                break;
            case EUIMSG.DOWN_RECODE_BPIC_FILE:// 录像缩略图下载--文件下载结果返回
                if (message.arg1 < 0) {
                    DownItemData downItemData = mDownloadResultMap.get(msgContent.seq);
                    if (downItemData != null && downItemData.mListener != null) {
                        downItemData.mListener.onDownloadResult(false, null,
                                null, downItemData.mType, msgContent.seq);
                    } else if (mListener != null) {
                        if (downItemData != null) {
                            mListener.onDownloadResult(false, msgContent.str, null,
                                    downItemData.mType, msgContent.seq);
                        } else {
                            mListener.onDownloadResult(false, null,
                                    null, 0, msgContent.seq);
                        }
                    }
                } else {
                    if (mBitmapMaps == null) {
                        mBitmapMaps = new HashMap<>();
                    }

                    DownItemData downItemData = mDownloadResultMap.get(msgContent.seq);

                    Bitmap bitmap;
                    if (downItemData != null && downItemData.mWidth > 0) {
                        bitmap = XUtils.createImageThumbnail(msgContent.str);
                        mBitmapMaps.put(msgContent.str, bitmap);
                    } else {
                        bitmap = BitmapFactory.decodeFile(msgContent.str);
                        mBitmapMaps.put(msgContent.str, bitmap);
                    }

                    if (downItemData != null && downItemData.mListener != null) {
                        downItemData.mListener.onDownloadResult(true, msgContent.str, bitmap, downItemData.mType,
                                msgContent.seq);
                    } else {
                        if (mListener != null) {
                            if (downItemData != null) {
                                mListener.onDownloadResult(true, msgContent.str, bitmap,
                                        downItemData.mType, msgContent.seq);
                            } else {
                                mListener.onDownloadResult(true, msgContent.str, bitmap,
                                        0, msgContent.seq);
                            }
                        }
                    }

                    mDownloadResultMap.remove(msgContent.seq);
                }

                mIsDownloading = false;
                downloadImage();
                break;
            case EUIMSG.DOWN_RECODE_BPIC_COMPLETE:// 录像缩略图下载-下载完成（结束）
                break;
            default:
                break;
        }
        return 0;
    }
}
