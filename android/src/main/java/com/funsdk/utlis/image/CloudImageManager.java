package com.funsdk.utils.image;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.alibaba.fastjson.JSON;
import com.basic.G;
import com.google.gson.Gson;
// import com.lib.EUIMSG;
import com.funsdk.utils.enums.EUIMSG;
import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.Mps.MpsClient;
import com.lib.Mps.XPMS_SEARCH_ALARMPIC_REQ;
import com.lib.MsgContent;
import com.lib.SDKCONST;
import com.lib.cloud.CloudDirectory;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.bean.alarm.AlarmInfo;
import com.lib.sdk.bean.cloudmedia.CloudMediaFileInfoBean;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
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
 * @class 云端图片管理:下载缩略图、原图和录像的缩略图
 * @time 2019-08-26 18:27
 */
public class CloudImageManager extends BaseImageManager {
    public CloudImageManager(String videoThumbPath) {
        super(videoThumbPath);
    }

    /**
     * 下载图片
     *
     * @param alarmInfo         报警消息
     * @param nType             媒体类型 SDKCONST.MediaType.PIC
     * @param nSeq              回传的Id
     * @param imgWidth          图片宽度
     * @param imgHeight         图片高度
     * @param isDownloadFromDev 是否从设备端下载
     * @return
     */
    public Bitmap downloadImage(AlarmInfo alarmInfo, int nType,
            int nSeq, int imgWidth, int imgHeight, OnImageManagerListener listener, boolean isDownloadFromDev) {
        if (alarmInfo == null || !alarmInfo.isHavePic()
                || alarmInfo.getId() == null) {
            if (listener != null) {
                listener.onDownloadResult(false, null, null, nType, nSeq);
            }
            return null;
        }

        if (StringUtils.isStringNULL(mSaveImageDir)) {
            if (listener != null) {
                listener.onDownloadResult(false, null, null, nType, nSeq);
            }
            return null;
        }

        String path;
        if (imgWidth > 0) {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + alarmInfo.getId() + "thumb.jpg";
        } else {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + alarmInfo.getId() + ".jpg";
        }

        if (FileUtils.isFileExist(path)) {
            if (mBitmapMaps == null) {
                mBitmapMaps = new HashMap<>();
            }

            if (imgWidth > 0) {
                mBitmapMaps.put(path, XUtils.createImageThumbnail(path));
            } else {
                mBitmapMaps.put(path, BitmapFactory.decodeFile(path));
            }
        }

        Bitmap bitmap = getPicBitmap(path);
        if (bitmap != null) {
            if (listener != null) {
                listener.onDownloadResult(true, path, bitmap, nType, nSeq);
            }
            return bitmap;
        }

        DownItemData down = new DownItemData();
        down.mDownloadJsonData = alarmInfo.getOriginJson();
        down.mHeight = imgHeight;
        down.mWidth = imgWidth;
        down.mPath = path;
        down.mSeq = nSeq;
        down.mType = nType;
        down.mListener = listener;

        // 如果是原图的话，不需要塞到队列中去下载
        if (imgWidth == 0 || imgHeight == 0) {
            downloadImage(down);
        } else {
            if (mDownloadQueue == null) {
                mDownloadQueue = new LinkedBlockingDeque<>();
            }

            // 如果当前队列中的个数大于最大缓存数据的话，需要把对头的数据移除
            if (mDownloadQueue.size() >= maxQueueSize) {
                mDownloadQueue.remove();
            }

            if (!mDownloadQueue.contains(down)) {
                mDownloadQueue.add(down);
            }

            if (!mIsDownloading && isDownloadFromDev) {
                downloadImageThumb();
            }
        }

        return null;
    }

    /**
     * 下载设备端图片
     *
     * @param alarmInfo 报警消息
     * @param nType     媒体类型 SDKCONST.MediaType.PIC
     * @param nSeq      回传的Id
     * @param imgWidth  图片宽度
     * @param imgHeight 图片高度
     * @return
     */
    public Bitmap downloadImage(AlarmInfo alarmInfo, int nType,
            int nSeq, int imgWidth, int imgHeight) {
        return downloadImage(alarmInfo, nType, nSeq, imgWidth, imgHeight, mListener, true);
    }

    /**
     * 下载原图或者缩略图
     *
     * @param alarmInfo 报警消息
     * @param nType     媒体类型 SDKCONST.MediaType.PIC
     * @param imgWidth  图片宽度
     * @param imgHeight 图片高度
     * @param listener
     */
    public Bitmap downloadImage(AlarmInfo alarmInfo, int nType, int imgWidth, int imgHeight,
            OnImageManagerListener listener) {
        return downloadImage(alarmInfo, nType, 0, imgWidth, imgHeight, listener, true);
    }

    /**
     * 下载视频缩略图
     *
     * @param cloudMediaFileInfoBean
     * @param imgWidth               缩略图宽
     * @param imgHeight              缩略图高
     * @param listener
     */
    public Bitmap downloadVideoThumb(CloudMediaFileInfoBean cloudMediaFileInfoBean, int seq, int imgWidth,
            int imgHeight, OnImageManagerListener listener, boolean isDownloadFromDev) {
        if (cloudMediaFileInfoBean == null || !StringUtils.contrast(cloudMediaFileInfoBean.getPicFlag(), "1")) {
            if (listener != null) {
                listener.onDownloadResult(false, null, null, SDKCONST.MediaType.VIDEO, seq);
            }
            return null;
        }

        try {
            String path;
            if (imgWidth > 0) {
                path = mSaveImageDir + File.separator + mDevId + "_"
                        + cloudMediaFileInfoBean.getStartTimes() + cloudMediaFileInfoBean.getEndTimes() + "thumb.jpg";
            } else {
                path = mSaveImageDir + File.separator + mDevId + "_"
                        + cloudMediaFileInfoBean.getStartTimes() + cloudMediaFileInfoBean.getEndTimes() + ".jpg";
            }

            if (FileUtils.isFileExist(path)) {
                if (mBitmapMaps == null) {
                    mBitmapMaps = new HashMap<>();
                }

                Bitmap bitmap;
                if (imgWidth > 0) {
                    bitmap = XUtils.dealBitmapAdaptationSize(path, imgWidth, imgHeight);
                } else {
                    bitmap = BitmapFactory.decodeFile(path);
                }
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

            DownItemData down = new DownItemData();
            down.mDownloadJsonData = JSON.toJSONString(cloudMediaFileInfoBean);
            down.mHeight = Math.max(imgHeight, 0);
            down.mWidth = Math.max(imgWidth, 0);
            down.mPath = path;
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
                downloadImageThumb();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * 下载设备端图片
     *
     * @param cloudMediaFileInfoBean 云视频信息
     * @param nSeq                   回传的Id
     * @param imgWidth               图片宽度
     * @param imgHeight              图片高度
     * @return
     */
    public Bitmap downloadVideoThumb(CloudMediaFileInfoBean cloudMediaFileInfoBean, int nSeq, int imgWidth,
            int imgHeight) {
        return downloadVideoThumb(cloudMediaFileInfoBean, nSeq, imgWidth, imgHeight, mListener, true);
    }

    /**
     * 下载原图或者缩略图
     *
     * @param cloudMediaFileInfoBean 云视频信息
     * @param imgWidth               图片宽度
     * @param imgHeight              图片高度
     * @param listener
     */
    public Bitmap downloadVideoThumb(CloudMediaFileInfoBean cloudMediaFileInfoBean, int imgWidth, int imgHeight,
            OnImageManagerListener listener) {
        return downloadVideoThumb(cloudMediaFileInfoBean, 0, imgWidth, imgHeight, listener, true);
    }

    /**
     * 原图片下载类型
     */
    private void downloadImage(DownItemData down) {
        if (mDownloadResultMap == null) {
            mDownloadResultMap = new HashMap<>();
        }

        mDownloadResultMap.put(down.mSeq, down);
        // 新的报警图片下载
        // MpsClient.DownloadCloudAlarmImage отсутсвует в 2.4
        // MpsClient.DownloadCloudAlarmImage(mUserId, mDevId, down.mPath,
        // down.mDownloadJsonData, 0, down.mWidth,
        // down.mHeight, down.mSeq);
        // MpsClient.DownloadAlarmImage(
        // mUserId
        // , mDevId
        // , down.mPath
        // , down.mDownloadJsonData
        // , down.mWidth
        // , down.mHeight
        // , down.mSeq);
        mIsDownloading = true;
    }

    /**
     * 缩略图下载
     */
    private void downloadImageThumb() {
        if (mDownloadQueue == null || mDownloadQueue.isEmpty()) {
            mIsDownloading = false;
            return;
        }

        if (mDownloadResultMap == null) {
            mDownloadResultMap = new HashMap<>();
        }

        DownItemData down = mDownloadQueue.poll();
        mDownloadResultMap.put(down.mSeq, down);

        if (down.mType == SDKCONST.MediaType.PIC) {
            // 新的报警图片下载
            // MpsClient.DownloadCloudAlarmImage отсутсвует в 2.4
            // MpsClient.DownloadCloudAlarmImage(mUserId, mDevId, down.mPath,
            // down.mDownloadJsonData, 0, down.mWidth,
            // down.mHeight, down.mSeq);
        } else if (down.mType == SDKCONST.MediaType.VIDEO) {
            // 视频的缩略图的 DownloadThumbnail
            // 这个接口去下载，如果没有缩略图，需要PMS同事协助排查，不要用DownloadCloudAlarmImage这个接口去下载消息对应的图片
            CloudDirectory.DownloadThumbnail(
                    mUserId,
                    mDevId,
                    down.mDownloadJsonData,
                    down.mPath,
                    down.mWidth,
                    down.mHeight,
                    down.mSeq);
        }

        mIsDownloading = true;
    }

    public Bitmap getPicBitmap(AlarmInfo alarmInfo, boolean isThumb) {
        if (alarmInfo == null) {
            return null;
        }

        String path;
        if (isThumb) {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + alarmInfo.getId() + "thumb.jpg";
        } else {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + alarmInfo.getId() + ".jpg";
        }

        if (mBitmapMaps != null && mBitmapMaps.containsKey(path)) {
            return mBitmapMaps.get(path);
        }

        return null;
    }

    public Bitmap getPicBitmap(CloudMediaFileInfoBean cloudMediaFileInfoBean, boolean isThumb) {
        if (cloudMediaFileInfoBean == null) {
            return null;
        }

        String path;
        if (isThumb) {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + cloudMediaFileInfoBean.getStartTimes() + cloudMediaFileInfoBean.getEndTimes() + "thumb.jpg";
        } else {
            path = mSaveImageDir + File.separator + mDevId + "_"
                    + cloudMediaFileInfoBean.getStartTimes() + cloudMediaFileInfoBean.getEndTimes() + ".jpg";
        }

        return getPicBitmap(path);
    }

    @Override
    public int OnFunSDKResult(Message message, MsgContent msgContent) {
        switch (message.what) {
            case EUIMSG.MC_SearchAlarmPic:
            case EUIMSG.MC_DownloadMediaThumbnail:
            case EUIMSG.MC_DOWNLOAD_CLOUD_ALARM_IMAGE:
                dealWithDownloadResult(message.arg1 >= 0, msgContent.str, msgContent.seq);
                mIsDownloading = false;
                downloadImageThumb();
                break;
            default:
                break;
        }
        return 0;
    }

    private void dealWithDownloadResult(boolean isSuccess, String imgPath, int seq) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (isSuccess) {
                    if (mBitmapMaps == null) {
                        mBitmapMaps = new HashMap<>();
                    }

                    DownItemData downItemData = mDownloadResultMap.get(seq);

                    Bitmap bitmap;
                    if (downItemData != null && downItemData.mWidth > 0) {
                        bitmap = XUtils.dealBitmapAdaptationSize(imgPath, downItemData.mWidth, downItemData.mHeight);
                        mBitmapMaps.put(imgPath, bitmap);
                    } else {
                        bitmap = BitmapFactory.decodeFile(imgPath);
                        mBitmapMaps.put(imgPath, bitmap);
                    }

                    if (downItemData != null && downItemData.mListener != null) {
                        downItemData.mListener.onDownloadResult(true, imgPath, bitmap, downItemData.mType, seq);
                    } else {
                        if (mListener != null) {
                            if (downItemData != null) {
                                mListener.onDownloadResult(true, imgPath, bitmap,
                                        downItemData.mType, seq);
                            } else {
                                mListener.onDownloadResult(true, imgPath, bitmap,
                                        SDKCONST.MediaType.PIC, seq);
                            }
                        }
                    }

                    mDownloadResultMap.remove(seq);
                } else {
                    DownItemData downItemData = mDownloadResultMap.get(seq);
                    if (downItemData != null && downItemData.mListener != null) {
                        downItemData.mListener.onDownloadResult(false, null,
                                null, SDKCONST.MediaType.PIC, seq);
                    } else if (mListener != null) {
                        if (downItemData != null) {
                            mListener.onDownloadResult(false, imgPath, null,
                                    downItemData.mType, seq);
                        } else {
                            mListener.onDownloadResult(false, null,
                                    null, SDKCONST.MediaType.PIC, seq);
                        }
                    }
                }
            }
        });
    }
}
