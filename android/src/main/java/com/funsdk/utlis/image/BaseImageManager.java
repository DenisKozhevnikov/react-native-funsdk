package com.funsdk.utils.image;

import android.graphics.Bitmap;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.sdk.bean.alarm.AlarmInfo;
import com.utils.FileUtils;
import com.utils.XUtils;

import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import java.util.Queue;

// from 4.0 lib version
public abstract class BaseImageManager implements IFunSDKResult {
    protected String mDevId;
    protected String mSaveImageDir;
    protected int mUserId;
    protected boolean mIsDownloading;
    protected int maxQueueSize = 10;// 最大缓存大小
    protected Queue<CloudImageManager.DownItemData> mDownloadQueue;
    protected HashMap<Integer, CloudImageManager.DownItemData> mDownloadResultMap;
    protected HashMap<String, Bitmap> mBitmapMaps;
    protected OnImageManagerListener mListener;

    public class DownItemData implements Serializable {
        public static final int ORIGINAL_IMG = 0;// 原图
        public static final int THUMB_IMG = 1;// 缩略图
        int mType;
        int mSeq;
        int mWidth = 0; // 图片大小，为0则原图大小
        int mHeight = 0;
        int mTimes;// 图片时间
        String mPath;
        String mDownloadJsonData;// 报警消息原始json数据或者存储录像文件原始json数据
        OnImageManagerListener mListener;
    }

    public BaseImageManager() {
        mUserId = FunSDK.GetId(mUserId, this);
    }

    /**
     * 云图片管理
     *
     * @param saveImageDir 图片保存路径
     */
    public BaseImageManager(String saveImageDir) {
        mSaveImageDir = saveImageDir;
        mUserId = FunSDK.GetId(mUserId, this);
    }

    /**
     * 设置缩略图下载队列缓存大小
     *
     * @param maxQueueSize
     */
    public void setMaxQueueSize(int maxQueueSize) {
        this.maxQueueSize = maxQueueSize;
    }

    /**
     * 设置设备序列号
     *
     * @param devId 设备序列号
     */
    public void setDevId(String devId) {
        mDevId = devId;
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

    public Bitmap getPicBitmap(String imagePath) {
        if (mBitmapMaps != null) {
            if (mBitmapMaps.containsKey(imagePath)) {
                return mBitmapMaps.get(imagePath);
            } else if (FileUtils.isFileExist(imagePath)) {
                Bitmap bitmap = XUtils.createImageThumbnail(imagePath);
                mBitmapMaps.put(imagePath, bitmap);
                return bitmap;
            }
        }

        return null;
    }

    public void setOnImageManagerListener(OnImageManagerListener listener) {
        mListener = listener;
    }

    public interface OnImageManagerListener {
        /**
         * 下载回调结果
         *
         * @param isSuccess 是否成功
         * @param imagePath 图片路径
         * @param bitmap
         * @param mediaType 媒体类型
         * @param seq
         */
        void onDownloadResult(boolean isSuccess, String imagePath, Bitmap bitmap, int mediaType, int seq);

        /**
         * 删除图片回调结果
         *
         * @param isSuccess
         * @param seq
         */
        void onDeleteResult(boolean isSuccess, int seq);
    }
}
