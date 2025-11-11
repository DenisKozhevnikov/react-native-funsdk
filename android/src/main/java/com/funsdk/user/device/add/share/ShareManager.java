package com.funsdk.user.device.add.share;

import static com.constant.SDKLogConstant.APP_JVSS;

import android.content.Context;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.lib.FunSDK;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.bean.share.OtherShareDevUserBean;
import com.manager.XMFunSDKManager;
import com.manager.account.serverinteraction.ShareManagerServerInteraction;
import com.manager.base.BaseUrlManager;
import com.manager.base.http.ResponseCallback;
import com.manager.db.DevDataCenter;
import com.utils.LogUtils;
import com.utils.SignatureUtil;
import com.utils.TimeMillisUtil;
import com.utils.TimeUtils;

import java.net.URLDecoder;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ShareManager extends BaseUrlManager {
  private int movedCard;
  private String uuid;
  private String appKey;
  private String appSecret;
  private String version = "v1";
  private ShareManagerServerInteraction serverInteraction;
  // private Map<Integer, OnShareManagerListener> shareManagerListenerMap;
  private static ShareManager shareManager;
  
  // Fields moved from BaseUrlManager in SDK 5.0.7
  private boolean isInit = false;
  private retrofit2.Retrofit mRetrofit;

  public static final String POWERS_DEV_INFO_KEY = "devInfo";
  private static final int TIME_OUT = 30;

  private ShareManager(@NonNull Context context) {
    if (DevDataCenter.getInstance().isLoginByAccount()) {
      uuid = XMFunSDKManager.getInstance().getAppUuid();
      appKey = XMFunSDKManager.getInstance().getAppKey();
      appSecret = XMFunSDKManager.getInstance().getAppSecret();
      movedCard = XMFunSDKManager.getInstance().getAppMovecard();
    }
  }

  public static synchronized ShareManager getInstance(@NonNull Context context) {
    if (shareManager == null) {
      shareManager = new ShareManager(context);
    }

    return shareManager;
  }

  private boolean initRetrofit() {
    try {
      if (mRetrofit == null) {
        okhttp3.OkHttpClient okHttpClient = new okhttp3.OkHttpClient.Builder()
          .connectTimeout(TIME_OUT, java.util.concurrent.TimeUnit.SECONDS)
          .readTimeout(TIME_OUT, java.util.concurrent.TimeUnit.SECONDS)
          .writeTimeout(TIME_OUT, java.util.concurrent.TimeUnit.SECONDS)
          .build();
        
        // getBaseUrl removed from BaseUrlManager in SDK 5.0.7
        // Use default server URL
        String baseUrl = "https://api.jftech.com/";
        if (!baseUrl.endsWith("/")) {
          baseUrl += "/";
        }
        
        mRetrofit = new retrofit2.Retrofit.Builder()
          .baseUrl(baseUrl)
          .client(okHttpClient)
          .build();
      }
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  @Override
  public boolean init() {
    if (isInit) {
      return true;
    }

    isInit = initRetrofit();
    if (isInit) {
      serverInteraction = mRetrofit.create(ShareManagerServerInteraction.class);
      // shareManagerListenerMap = new HashMap<>();
    }
    return isInit;
  }

  @Override
  public void unInit() {
    isInit = false;
    mRetrofit = null;
    serverInteraction = null;
    // shareManagerListenerMap = null;
  }

  public void userQuery(String searchUserName, Promise promise) {
    if (!init()) {
      return;
    }

    String loginToken = DevDataCenter.getInstance().getAccessToken();

    String timeMillis = TimeMillisUtil.getTimMillis();
    Call<ResponseBody> call;
    try {

      String secret = SignatureUtil.getEncryptStr(uuid,
          appKey,
          appSecret, timeMillis, movedCard);

      call = serverInteraction.userQuery(
          version,
          timeMillis,
          secret,
          searchUserName);

      call.enqueue(new Callback<ResponseBody>() {
        @Override
        public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
          if (response != null) {
            ResponseBody responseBody = response.body();
            if (responseBody != null) {
              try {
                String jsonResult = URLDecoder.decode(responseBody.string(), "UTF-8");

                promise.resolve(jsonResult);
              } catch (Exception e) {
                promise.reject("error");
              }
            }
          }

          promise.reject("error");
        }

        @Override
        public void onFailure(Call<ResponseBody> call, Throwable throwable) {
          promise.reject("error");
        }
      });
    } catch (Exception e) {
      e.printStackTrace();
      promise.reject("error");
    }
  }
}
