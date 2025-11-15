package com.funsdkexample;

import android.app.Application;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.facebook.soloader.SoLoader;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost =
      new DefaultReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
          return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
          @SuppressWarnings("UnnecessaryLocalVariable")
          List<ReactPackage> packages = new PackageList(this).getPackages();
          // Packages that cannot be autolinked yet can be added manually here, for example:
          // packages.add(new MyReactNativePackage());
          return packages;
        }

        @Override
        protected String getJSMainModuleName() {
          return "index";
        }

        @Override
        protected boolean isNewArchEnabled() {
          return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        }

        @Override
        protected Boolean isHermesEnabled() {
          return BuildConfig.IS_HERMES_ENABLED;
        }
      };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);
    if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
      // If you opted-in for the New Architecture, we load the native entry point for this app.
      DefaultNewArchitectureEntryPoint.load();
    }
    ReactNativeFlipper.initializeFlipper(this, getReactNativeHost().getReactInstanceManager());

    // Early init FunSDK using reflection to avoid compile-time deps in the app module
    try {
      Class<?> mgrClz = Class.forName("com.manager.XMFunSDKManager");
      java.lang.reflect.Method getInstance = mgrClz.getMethod("getInstance", int.class, String.class, String.class, int.class);
      Object xm = getInstance.invoke(null, 0, "", "p2p-s1.red-dst.ru", 8000);

      // Check isLoadLibrarySuccess()
      java.lang.reflect.Method isLoaded = mgrClz.getMethod("isLoadLibrarySuccess");
      Object ok = isLoaded.invoke(xm);
      if (ok instanceof Boolean && ((Boolean) ok)) {
        ApplicationInfo appInfo = getPackageManager().getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA);
        String appUuid = appInfo.metaData != null ? appInfo.metaData.getString("APP_UUID") : null;
        String appKey = appInfo.metaData != null ? appInfo.metaData.getString("APP_KEY") : null;
        String appSecret = appInfo.metaData != null ? appInfo.metaData.getString("APP_SECRET") : null;
        int appMovedCard = appInfo.metaData != null ? appInfo.metaData.getInt("APP_MOVECARD", 2) : 2;

        java.lang.reflect.Method init = mgrClz.getMethod(
            "initXMCloudPlatform",
            android.content.Context.class,
            String.class, String.class, String.class,
            int.class, boolean.class);
        init.invoke(xm, this, appUuid, appKey, appSecret, appMovedCard, true);

        java.lang.reflect.Method initLog = mgrClz.getMethod("initLog");
        initLog.invoke(xm);

        Class<?> funClz = Class.forName("com.lib.FunSDK");
        java.lang.reflect.Method sysSet = funClz.getMethod("SysSetServerIPPort", String.class, String.class, int.class);
        sysSet.invoke(null, "STATUS_P2P_SERVER", "p2p-s1.red-dst.ru", 8000);

        // Set paths and flags via EFUN_ATTR
        Class<?> attrClz = Class.forName("com.lib.EFUN_ATTR");
        int UPDATE_FILE_PATH = attrClz.getField("UPDATE_FILE_PATH").getInt(null);
        int CONFIG_PATH = attrClz.getField("CONFIG_PATH").getInt(null);
        int AUTO_DL_UPGRADE = attrClz.getField("AUTO_DL_UPGRADE").getInt(null);
        int LOGIN_SUP_RSA_ENC = attrClz.getField("LOGIN_SUP_RSA_ENC").getInt(null);
        int SUP_RPS_VIDEO_DEFAULT = attrClz.getField("SUP_RPS_VIDEO_DEFAULT").getInt(null);

        java.lang.reflect.Method setStr = funClz.getMethod("SetFunStrAttr", int.class, String.class);
        java.lang.reflect.Method setInt = funClz.getMethod("SetFunIntAttr", int.class, int.class);

        String updateFilePath = getFilesDir().getPath() + "/UpgradeFiles";
        String configPath = getFilesDir().getPath() + "/ConfigPath";
        try { new java.io.File(updateFilePath).mkdirs(); new java.io.File(configPath).mkdirs(); } catch (Throwable ignore) {}
        setStr.invoke(null, UPDATE_FILE_PATH, updateFilePath);
        setStr.invoke(null, CONFIG_PATH, configPath);
        setInt.invoke(null, AUTO_DL_UPGRADE, 0);
        setInt.invoke(null, LOGIN_SUP_RSA_ENC, 1);
        try {
          Class<?> swClz = Class.forName("com.lib.SDKCONST$Switch");
          int Open = swClz.getField("Open").getInt(null);
          setInt.invoke(null, SUP_RPS_VIDEO_DEFAULT, Open);
        } catch (Throwable ignore) {}
      }
    } catch (Throwable ignore) {}
  }
}
