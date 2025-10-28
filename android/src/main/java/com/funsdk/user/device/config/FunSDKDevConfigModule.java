package com.funsdk.user.device.config;

import android.os.Message;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.ArrayList;
import java.util.List;
import com.funsdk.utils.DataConverter;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.lib.sdk.struct.SDBDeviceInfo;

/**
 * Android-аналог iOS-модуля FunSDKDevConfigModule.
 * Обёртки над FunSDK для получения/сохранения конфигов и DevCmdGeneral.
 */
public class FunSDKDevConfigModule extends ReactContextBaseJavaModule implements IFunSDKResult {
  private final ReactApplicationContext reactContext;
  private int mUserId = 0;
  private boolean isRegistered = false;
  private int mSeq = 1;
  private final Map<Integer, Pending> pending = new HashMap<>();
  private final Map<Integer, Runnable> timeoutRunnables = new HashMap<>();
  private final Handler mainHandler = new Handler(Looper.getMainLooper());
  private Promise pendingCmdGeneral = null;
  private Runnable pendingCmdGeneralTimeout = null;
  private static final String TAG = "DEV_CONFIG_ANDROID";

  private static class Pending {
    final Promise promise;
    final String devId;
    final String name;
    final int channel;
    final int timeoutMs;
    final String op; // "GET", "SET", "CMD"

    Pending(Promise promise, String devId, String name, int channel, int timeoutMs, String op) {
      this.promise = promise;
      this.devId = devId;
      this.name = name;
      this.channel = channel;
      this.timeoutMs = timeoutMs;
      this.op = op;
    }
  }

  private String extractNameFromJson(String json) {
    try {
      if (json == null || json.isEmpty()) return null;
      JSONObject obj = new JSONObject(json);
      if (obj.has("Name")) {
        String nm = obj.getString("Name");
        if (nm == null) return null;
        // Приведём "Detect.MotionDetect.[0]" → "Detect.MotionDetect"
        int idx = nm.indexOf(".[");
        if (idx > 0) {
          nm = nm.substring(0, idx);
        }
        // На некоторых прошивках формат может быть вида "Name":"Detect.MotionDetect" без индекса
        return nm;
      }
    } catch (JSONException ignored) {
    }
    return null;
  }

  private String sanitizeJson(String raw) {
    if (raw == null) return "";
    String s = raw;
    int zero = s.indexOf('\u0000');
    if (zero >= 0) {
      s = s.substring(0, zero);
    }
    int start = s.indexOf('{');
    int end = s.lastIndexOf('}');
    if (start >= 0 && end >= start) {
      s = s.substring(start, end + 1);
    }
    return s.trim();
  }

  public FunSDKDevConfigModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
  }

  @Override
  public String getName() {
    return "FunSDKDevConfigModule";
  }

  private int nextSeq() {
    mSeq += 1;
    return mSeq;
  }

  private void ensureUser() {
    if (!isRegistered) {
      mUserId = FunSDK.GetId(mUserId, this);
      isRegistered = true;
    }
  }

  private boolean isGlobalConfigName(String name) {
    if (name == null) return false;
    String n = name.trim();
    if (n.isEmpty()) return false;
    // Набор известных глобальных узлов, для которых требуется channel = -1
    if (n.equals("SystemInfo")) return true;
    if (n.equals("SystemFunction")) return true;
    if (n.equals("EncodeCapability")) return true;
    if (n.equals("General.Location")) return true;
    if (n.contains("Simplify.Encode")) return true;
    // Часто системные узлы начинаются с "System"
    if (n.startsWith("System")) return true;
    return false;
  }

  private boolean isEncodingConfigName(String name) {
    if (name == null) return false;
    String n = name.trim();
    if (n.isEmpty()) return false;
    if (n.startsWith("AVEnc.")) return true;
    if (n.startsWith("Encode")) return true;
    if (n.equals("AVEnc.SmartH264V2")) return true;
    if (n.equals("AVEnc.EncodeStaticParam")) return true;
    return false;
  }

  private boolean isRecordConfigName(String name) {
    if (name == null) return false;
    String n = name.trim();
    if (n.isEmpty()) return false;
    if (n.equals("Record")) return true;
    if (n.equals("ExtRecord")) return true;
    if (n.equals("SupportExtRecord")) return true;
    if (n.startsWith("Record.")) return true;
    if (n.contains("Record")) return true;
    return false;
  }

  private boolean isDetectConfigName(String name) {
    if (name == null) return false;
    String n = name.trim();
    if (n.isEmpty()) return false;
    if (n.startsWith("Detect.")) return true;
    if (n.contains("MotionDetect")) return true;
    if (n.contains("HumanDetection")) return true;
    if (n.contains("DetectTrack")) return true;
    if (n.contains("LossDetect")) return true;
    if (n.contains("BlindDetect")) return true;
    return false;
  }

  // === Helpers ===
  private WritableArray jsonArrayToWritableArray(org.json.JSONArray jsonArray) throws org.json.JSONException {
    WritableArray out = Arguments.createArray();
    for (int i = 0; i < jsonArray.length(); i++) {
      Object elem = jsonArray.get(i);
      if (elem == null || elem == org.json.JSONObject.NULL) {
        out.pushNull();
      } else if (elem instanceof org.json.JSONObject) {
        out.pushMap(jsonObjectToWritableMap((org.json.JSONObject) elem));
      } else if (elem instanceof org.json.JSONArray) {
        out.pushArray(jsonArrayToWritableArray((org.json.JSONArray) elem));
      } else if (elem instanceof Boolean) {
        out.pushBoolean((Boolean) elem);
      } else if (elem instanceof Integer) {
        out.pushInt((Integer) elem);
      } else if (elem instanceof Long) {
        // RN WritableArray doesn't have pushLong; store as double
        out.pushDouble(((Long) elem).doubleValue());
      } else if (elem instanceof Double) {
        out.pushDouble((Double) elem);
      } else if (elem instanceof Float) {
        out.pushDouble(((Float) elem).doubleValue());
      } else {
        out.pushString(String.valueOf(elem));
      }
    }
    return out;
  }

  private WritableMap jsonObjectToWritableMap(org.json.JSONObject jsonObject) throws org.json.JSONException {
    WritableMap map = Arguments.createMap();
    java.util.Iterator<String> keys = jsonObject.keys();
    while (keys.hasNext()) {
      String key = keys.next();
      Object val = jsonObject.get(key);
      if (val == null || val == org.json.JSONObject.NULL) {
        map.putNull(key);
      } else if (val instanceof org.json.JSONObject) {
        map.putMap(key, jsonObjectToWritableMap((org.json.JSONObject) val));
      } else if (val instanceof org.json.JSONArray) {
        map.putArray(key, jsonArrayToWritableArray((org.json.JSONArray) val));
      } else if (val instanceof Boolean) {
        map.putBoolean(key, (Boolean) val);
      } else if (val instanceof Integer) {
        map.putInt(key, (Integer) val);
      } else if (val instanceof Long) {
        map.putDouble(key, ((Long) val).doubleValue());
      } else if (val instanceof Double) {
        map.putDouble(key, (Double) val);
      } else if (val instanceof Float) {
        map.putDouble(key, ((Float) val).doubleValue());
      } else {
        map.putString(key, String.valueOf(val));
      }
    }
    return map;
  }

  private String findConfigKey(org.json.JSONObject root, String expect) {
    if (expect == null) return null;
    try {
      if (root.has(expect)) return expect;
      String best = null;
      java.util.Iterator<String> keys = root.keys();
      String prefix = expect + ".[";
      while (keys.hasNext()) {
        String k = keys.next();
        if (k != null && k.startsWith(prefix)) {
          if (best == null || k.length() > best.length()) best = k;
        }
      }
      return best;
    } catch (Throwable ignored) {
      return null;
    }
  }

  private WritableMap buildNameArrayResult(String cleaned, String expectName, String devId) throws Throwable {
    WritableMap out = Arguments.createMap();
    String name = expectName != null ? expectName : extractNameFromJson(cleaned);
    if (name == null) name = "";
    out.putString("s", devId != null ? devId : "");
    out.putInt("i", 1);

    // value: { Name: name, name: [ { ... } ] }
    WritableMap value = null;
    try {
      value = DataConverter.parseToWritableMap(cleaned);
    } catch (Throwable ignored) {
    }
    if (value == null) value = Arguments.createMap();

    // гарантируем поле Name
    if (!value.hasKey("Name") || value.isNull("Name") || value.getString("Name") == null || value.getString("Name").isEmpty()) {
      value.putString("Name", name);
    }

    // если корень уже содержит массив по ключу name, ничего не делаем
    boolean hasArray = false;
    try {
      if (value.hasKey(name) && value.getType(name) == com.facebook.react.bridge.ReadableType.Array) {
        hasArray = true;
      }
    } catch (Throwable ignored) {}

    if (!hasArray) {
      // Попробуем найти точный ключ или вариант с индексом Name.[0]
      try {
        org.json.JSONObject root = new org.json.JSONObject(cleaned);
        String key = findConfigKey(root, name);
        if (key != null) {
          Object node = root.get(key);
          if (node instanceof org.json.JSONArray) {
            // Уже массив — сконвертируем и положим
            WritableArray arr = jsonArrayToWritableArray((org.json.JSONArray) node);
            value.putArray(name, arr);
          } else if (node instanceof org.json.JSONObject) {
            // Один объект — обернём в массив из одного элемента
            WritableMap m = jsonObjectToWritableMap((org.json.JSONObject) node);
            WritableArray arr = Arguments.createArray();
            arr.pushMap(m);
            value.putArray(name, arr);
          } else {
            WritableArray arr = Arguments.createArray();
            arr.pushString(String.valueOf(node));
            value.putArray(name, arr);
          }
        } else {
          // ключ не найден — если весь JSON объект, обернём его как единственный элемент
          try {
            org.json.JSONObject asObj = new org.json.JSONObject(cleaned);
            WritableMap m = jsonObjectToWritableMap(asObj);
            WritableArray arr = Arguments.createArray();
            arr.pushMap(m);
            value.putArray(name, arr);
          } catch (Throwable ignored2) {
            // иначе пустой массив
            value.putArray(name, Arguments.createArray());
          }
        }
      } catch (Throwable ignored3) {
        value.putArray(name, Arguments.createArray());
      }
    }

    out.putMap("value", value);
    return out;
  }

  private WritableMap normalizeConfigToNameArray(String cleaned, String expectName) throws Throwable {
    WritableMap value;
    try {
      value = DataConverter.parseToWritableMap(cleaned);
    } catch (Throwable t) {
      value = Arguments.createMap();
    }

    String name = expectName != null ? expectName : extractNameFromJson(cleaned);
    if (name == null) name = "";

    try {
      if (!value.hasKey("Name") || value.isNull("Name") || value.getString("Name") == null || value.getString("Name").isEmpty()) {
        value.putString("Name", name);
      }
    } catch (Throwable ignored) {}

    try {
      if (value.hasKey(name) && value.getType(name) == ReadableType.Array) {
        return value;
      }
    } catch (Throwable ignored) {}

    try {
      org.json.JSONObject root = new org.json.JSONObject(cleaned);

      // 1) прямой ключ name
      if (root.has(name)) {
        Object node = root.get(name);
        if (node instanceof org.json.JSONArray) {
          WritableArray arr = jsonArrayToWritableArray((org.json.JSONArray) node);
          value.putArray(name, arr);
          return value;
        } else if (node instanceof org.json.JSONObject) {
          WritableMap m = jsonObjectToWritableMap((org.json.JSONObject) node);
          WritableArray arr = Arguments.createArray();
          arr.pushMap(m);
          value.putArray(name, arr);
          return value;
        }
      }

      // 2) набор ключей name.[i]
      String prefix = name + ".[";
      java.util.Iterator<String> keys = root.keys();
      java.util.List<org.json.JSONObject> items = new java.util.ArrayList<>();
      while (keys.hasNext()) {
        String k = keys.next();
        if (k != null && k.startsWith(prefix)) {
          Object node = root.get(k);
          if (node instanceof org.json.JSONObject) {
            items.add((org.json.JSONObject) node);
          }
        }
      }
      if (!items.isEmpty()) {
        WritableArray arr = Arguments.createArray();
        for (org.json.JSONObject it : items) {
          arr.pushMap(jsonObjectToWritableMap(it));
        }
        value.putArray(name, arr);
        return value;
      }
    } catch (Throwable ignored3) {
    }

    return value;
  }

  // === Public RN API ===
  @ReactMethod
  public void getDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final int nOutBufLen = params.getInt("nOutBufLen");
    final int channel = params.getInt("channel");
    final int timeoutRaw = params.getInt("timeout");

    int effectiveChannel = channel;
    int timeout = timeoutRaw;

    final int seq = nextSeq();
    pending.put(seq, new Pending(promise, devId, name, effectiveChannel, timeout, "GET"));

    int outLenEff = nOutBufLen;
    if (outLenEff <= 0) {
      if ("Users".equals(name)) {
        outLenEff = 64 * 1024; // 64KB
      } else {
        outLenEff = 4096;
      }
    }

    Log.e(TAG, "getDevConfig: devId=" + devId + ", name=" + name + ", outLenRaw=" + nOutBufLen + ", outLenEff=" + outLenEff + ", chRaw=" + channel + ", effectiveCh=" + effectiveChannel + ", timeout=" + timeout + ", seq=" + seq);
    // int DevGetConfigByJson(int userId, String devId, String cmd, int outLen, int chn, int timeout, int seq)
    int ret = FunSDK.DevGetConfigByJson(mUserId, devId, name, outLenEff, effectiveChannel, timeout, seq);
    if (ret < 0) {
      Runnable r = timeoutRunnables.remove(seq);
      if (r != null) {
        mainHandler.removeCallbacks(r);
      }
      Pending removed = pending.remove(seq);
      Log.e(TAG, "DevGetConfigByJson immediate error: ret=" + ret + ", name=" + name + ", ch=" + channel + ", outLen=" + nOutBufLen + ", seq=" + seq);
      if (removed != null && removed.promise != null) {
        try {
          removed.promise.reject(String.valueOf(ret), "DEV_GET_CONFIG immediate error");
        } catch (Throwable t) {
          Log.e(TAG, "Immediate reject failed", t);
        }
      }
      return;
    }

    Runnable r = new Runnable() {
      @Override
      public void run() {
        Pending removed = pending.remove(seq);
        timeoutRunnables.remove(seq);
        if (removed != null) {
          Log.e(TAG, "TIMEOUT getDevConfig: devId=" + removed.devId + ", name=" + removed.name + ", ch=" + removed.channel + ", timeout=" + removed.timeoutMs + ", seq=" + seq);
          try {
            removed.promise.reject("Timeout", "Timeout: " + removed.name);
          } catch (Throwable t) {
            Log.e(TAG, "Reject timeout failed", t);
          }
        }
      }
    };
    timeoutRunnables.put(seq, r);
    mainHandler.postDelayed(r, timeout);
  }

  @ReactMethod
  public void setDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final String json = params.getString("param");
    final int channel = params.hasKey("channel") ? params.getInt("channel") : -1;
    final int timeoutRaw = params.hasKey("timeout") ? params.getInt("timeout") : 15000;

    int effectiveChannel = channel;
    int timeout = timeoutRaw;

    final int seq = nextSeq();
    pending.put(seq, new Pending(promise, devId, name, effectiveChannel, timeout, "SET"));

    final String jsonStr = json != null ? json : "";
    Log.e(TAG, "setDevConfig: devId=" + devId + ", name=" + name + ", jsonLen=" + jsonStr.length() + ", chRaw=" + channel + ", effectiveCh=" + effectiveChannel + ", timeout=" + timeout + ", seq=" + seq);
    // int DevSetConfigByJson(int userId, String devId, String cmd, String json, int chn, int timeout, int seq)
    int ret = FunSDK.DevSetConfigByJson(mUserId, devId, name, jsonStr, effectiveChannel, timeout, seq);
    if (ret < 0) {
      Runnable r = timeoutRunnables.remove(seq);
      if (r != null) {
        mainHandler.removeCallbacks(r);
      }
      Pending removed = pending.remove(seq);
      Log.e(TAG, "DevSetConfigByJson immediate error: ret=" + ret + ", name=" + name + ", ch=" + channel + ", seq=" + seq);
      if (removed != null && removed.promise != null) {
        try {
          removed.promise.reject(String.valueOf(ret), "DEV_SET_CONFIG immediate error");
        } catch (Throwable t) {
          Log.e(TAG, "Immediate reject failed", t);
        }
      }
      return;
    }

    // Коалесинг: отменим предыдущие SET на тот же (devId,name), оставим актуальный
    try {
      for (Iterator<Entry<Integer, Pending>> it = pending.entrySet().iterator(); it.hasNext();) {
        Entry<Integer, Pending> e = it.next();
        if (e.getKey() == seq) continue;
        Pending p = e.getValue();
        if (p != null && "SET".equals(p.op) && devId.equals(p.devId) && name.equals(p.name)) {
          Runnable r2 = timeoutRunnables.remove(e.getKey());
          if (r2 != null) mainHandler.removeCallbacks(r2);
          try { p.promise.reject("Cancelled", "Superseded by newer setDevConfig"); } catch (Throwable ignored) {}
          it.remove();
        }
      }
    } catch (Throwable ignored) {}

    Runnable r = new Runnable() {
      @Override
      public void run() {
        Pending removed = pending.remove(seq);
        timeoutRunnables.remove(seq);
        if (removed != null) {
          Log.e(TAG, "TIMEOUT setDevConfig: devId=" + removed.devId + ", name=" + removed.name + ", ch=" + removed.channel + ", timeout=" + removed.timeoutMs + ", seq=" + seq);
          try {
            removed.promise.reject("Timeout", "Timeout: " + removed.name);
          } catch (Throwable t) {
            Log.e(TAG, "Reject timeout failed", t);
          }
        }
      }
    };
    timeoutRunnables.put(seq, r);
    mainHandler.postDelayed(r, timeout);
  }

  /**
   * Универсальная команда к устройству (эквивалент iOS FUN_DevCmdGeneral)
   * params: { deviceId, cmdReq, cmd, isBinary, timeout, param, inParamLen, cmdRes }
   */
  @ReactMethod
  public void getDevCmdGeneral(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final int cmdReq = params.getInt("cmdReq");
    final String cmd = params.getString("cmd");
    final int isBinary = params.hasKey("isBinary") ? params.getInt("isBinary") : 0;
    final int timeout = params.hasKey("timeout") ? params.getInt("timeout") : 5000;
    final String param = params.hasKey("param") && !params.isNull("param") ? params.getString("param") : null;
    final int inParamLen = params.hasKey("inParamLen") ? params.getInt("inParamLen") : 0;
    final int cmdRes = params.hasKey("cmdRes") ? params.getInt("cmdRes") : -1;

    // В Android Java API DevCmdGeneral не принимает seq, поэтому храним одиночный promise
    pendingCmdGeneral = promise;
    if (pendingCmdGeneralTimeout != null) {
      mainHandler.removeCallbacks(pendingCmdGeneralTimeout);
      pendingCmdGeneralTimeout = null;
    }

    byte[] inBytes = param != null ? param.getBytes(Charset.forName("UTF-8")) : null;
    Log.e(TAG, "DevCmdGeneral: devId=" + devId + ", cmdReq=" + cmdReq + ", cmd=" + cmd + ", isBinary=" + isBinary + ", timeout=" + timeout + ", inLen=" + (inBytes != null ? inBytes.length : 0) + ", cmdRes=" + cmdRes);
    // int DevCmdGeneral(int userId, String devId, int cmdType, String cmd, int isBinary, int timeout, byte[] inData, int inLen, int cmdRes)
    FunSDK.DevCmdGeneral(mUserId, devId, cmdReq, cmd, isBinary, timeout, inBytes, inParamLen, cmdRes);

    pendingCmdGeneralTimeout = new Runnable() {
      @Override
      public void run() {
        if (pendingCmdGeneral != null) {
          Log.e(TAG, "TIMEOUT DevCmdGeneral: cmdReq=" + cmdReq + ", cmd=" + cmd + ", timeout=" + timeout);
          Promise p = pendingCmdGeneral;
          pendingCmdGeneral = null;
          try {
            p.reject("Timeout", "Timeout: DevCmdGeneral");
          } catch (Throwable t) {
            Log.e(TAG, "Reject timeout failed", t);
          }
        }
      }
    };
    mainHandler.postDelayed(pendingCmdGeneralTimeout, timeout);
  }

  // === IFunSDKResult ===

  @Override
  public int OnFunSDKResult(Message msg, MsgContent ex) {
    final int what = msg.what;
    final int arg1 = msg.arg1;
    final int seq = msg.arg2;

    Pending pendingReq = pending.get(seq);
    if (pendingReq != null) {
      Runnable r = timeoutRunnables.remove(seq);
      if (r != null) {
        mainHandler.removeCallbacks(r);
      }
    }

    Promise promise = pendingReq != null ? pendingReq.promise : null;
    Log.e(TAG, "OnFunSDKResult: what=" + what + ", arg1=" + arg1 + ", seq=" + seq + ", pDataLen=" + (ex != null && ex.pData != null ? ex.pData.length : -1));

    try {
      if (what == EUIMSG.DEV_GET_JSON || what == EUIMSG.DEV_GET_CONFIG) {
        if (arg1 >= 0) {
          String data = "";
          if (ex != null) {
            if (ex.pData != null && ex.pData.length > 0) {
              data = new String(ex.pData, Charset.forName("UTF-8")).trim();
            } else if (ex.str != null) {
              data = ex.str.trim();
            }
          }
          if (promise == null && data != null && !data.isEmpty()) {
            String cleanedForMatch = sanitizeJson(data);
            String returnedName = extractNameFromJson(cleanedForMatch);

            Integer matchedSeq = null;
            Pending matchedPending = null;
            Iterator<Entry<Integer, Pending>> it = pending.entrySet().iterator();
            while (it.hasNext()) {
              Entry<Integer, Pending> e = it.next();
              Pending p = e.getValue();
              if (p == null || !"GET".equals(p.op)) continue;

              boolean nameEquals = returnedName != null && returnedName.equals(p.name);
              boolean jsonHasKey = false;
              if (!nameEquals) {
                try {
                  String keyA = "\"" + p.name + "\"";
                  String keyB = "\"" + p.name + ".[";
                  jsonHasKey = (cleanedForMatch != null && (cleanedForMatch.contains(keyA) || cleanedForMatch.contains(keyB)));
                } catch (Throwable ignoredScan) {}
              }

              if (nameEquals || jsonHasKey) {
                matchedSeq = e.getKey();
                matchedPending = p;
                it.remove();
                break;
              }
            }
            if (matchedSeq != null && matchedPending != null) {
              Runnable r2 = timeoutRunnables.remove(matchedSeq);
              if (r2 != null) mainHandler.removeCallbacks(r2);
              promise = matchedPending.promise;
              pendingReq = matchedPending;
              Log.e(TAG, "Matched pending by fallback: name=" + (returnedName != null ? returnedName : matchedPending.name) + ", matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
            }
          }
          if (promise != null) {
            String cleaned;
            try {
              cleaned = sanitizeJson(data);
            } catch (Throwable t) {
              promise.reject("ParseError", t);
              pending.remove(seq);
              return 0;
            }

            try {
              Log.e(TAG, "DEV_GET_CONFIG raw (cleaned): len=" + (cleaned != null ? cleaned.length() : -1) +
                ", head=" + (cleaned != null ? cleaned.substring(0, Math.min(500, cleaned.length())) : "null"));
            } catch (Throwable ignored) {}

            try {
              JSONObject obj = new JSONObject(cleaned);
              String expectName = pendingReq != null ? pendingReq.name : extractNameFromJson(cleaned);
              boolean headerOnly = false;
              if (obj != null) {
                int len = obj.length();
                boolean expectMissing = false;
                if (expectName != null && !expectName.isEmpty()) {
                  boolean hasExact = obj.has(expectName);
                  boolean hasIndexed = false;
                  try { hasIndexed = cleaned.contains("\"" + expectName + ".["); } catch (Throwable ignored) {}
                  expectMissing = !(hasExact || hasIndexed);
                }
                boolean hasNameOnly = obj.has("Name") && expectMissing;
                headerOnly = hasNameOnly && len <= 3;
              }
              if (headerOnly) {
                Log.e(TAG, "Header-only JSON for name=" + expectName + ", re-requesting with larger outLen");
                try {
                  int retryOutLen = 512 * 1024;
                  FunSDK.DevGetConfigByJson(mUserId, pendingReq.devId, pendingReq.name, retryOutLen, pendingReq.channel, pendingReq.timeoutMs, seq);
                } catch (Throwable t) {
                  Log.e(TAG, "Re-request on header-only failed", t);
                }
                return 0;
              }
            } catch (Throwable ignored) {}

            if (cleaned == null || cleaned.isEmpty()) {
              promise.reject("ParseError", "Empty JSON in DEV_GET_CONFIG");
              pending.remove(seq);
            } else {
              try {
                org.json.JSONObject root = new org.json.JSONObject(cleaned);
                // Добавим networkMode для SystemInfo, как на iOS, если можем получить из DevDataCenter
                try {
                  String cfgName = pendingReq != null ? pendingReq.name : null;
                  if ("SystemInfo".equals(cfgName)) {
                    int networkMode = -1;
                    try {
                      XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(pendingReq.devId);
                      if (xmDevInfo != null) {
                        SDBDeviceInfo sdb = xmDevInfo.getSdbDevInfo();
                        if (sdb != null) networkMode = sdb.connectType;
                      }
                    } catch (Throwable ignoredNet) {}
                    try {
                      org.json.JSONObject sys = root.optJSONObject("SystemInfo");
                      if (sys != null) {
                        sys.put("networkMode", networkMode);
                      } else {
                        root.put("networkMode", networkMode);
                      }
                    } catch (Throwable ignoredPut) {}
                  }
                } catch (Throwable ignoredOuter) {}
                // Спец-агрегация для Record/ExtRecord/SupportExtRecord: собрать массив из Record.[i] при отсутствии прямого массива
                try {
                  String[] keysToAggregate = new String[]{"Record", "ExtRecord", "SupportExtRecord"};
                  for (String aggKey : keysToAggregate) {
                    if (!root.has(aggKey)) {
                      String prefix = aggKey + ".[";
                      java.util.Iterator<String> it = root.keys();
                      java.util.List<org.json.JSONObject> bucket = new java.util.ArrayList<>();
                      while (it.hasNext()) {
                        String k = it.next();
                        if (k != null && k.startsWith(prefix)) {
                          Object node = root.opt(k);
                          if (node instanceof org.json.JSONObject) {
                            bucket.add((org.json.JSONObject) node);
                          }
                        }
                      }
                      if (!bucket.isEmpty()) {
                        org.json.JSONArray arr = new org.json.JSONArray();
                        for (org.json.JSONObject o : bucket) arr.put(o);
                        root.put(aggKey, arr);
                      }
                    }
                  }
                } catch (Throwable ignoredAgg) {}

                WritableMap value = jsonObjectToWritableMap(root);
                promise.resolve(value);
                pending.remove(seq);
              } catch (Throwable inner) {
                Log.e(TAG, "Parse error, returning raw only", inner);
                WritableMap resp = Arguments.createMap();
                resp.putString("raw", cleaned);
                promise.resolve(resp);
                pending.remove(seq);
              }
            }
          }
          Log.e(TAG, "DEV_GET_CONFIG success: dataLen=" + (data != null ? data.length() : 0));
        } else {
          if (promise == null) {
            Integer matchedSeq = null;
            Pending matchedPending = null;
            String returnedName = null;
            try {
              if (ex != null && ex.str != null) returnedName = extractNameFromJson(ex.str);
            } catch (Throwable ignored) {}
            for (Entry<Integer, Pending> e : pending.entrySet()) {
              Pending p = e.getValue();
              if (p != null && "GET".equals(p.op)) {
                if (returnedName == null || returnedName.equals(p.name)) {
                  matchedSeq = e.getKey();
                  matchedPending = p;
                  break;
                }
              }
            }
            if (matchedSeq != null && matchedPending != null) {
              Runnable r2 = timeoutRunnables.remove(matchedSeq);
              if (r2 != null) mainHandler.removeCallbacks(r2);
              pending.remove(matchedSeq);
              promise = matchedPending.promise;
              Log.e(TAG, "Matched GET pending on error: name=" + matchedPending.name + ", matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
            }
          }
          if (promise != null) {
            promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
            pending.remove(seq);
          }
          Log.e(TAG, "DEV_GET_CONFIG failed: what=" + what + ", err=" + arg1);
        }
        return 0;
      }

      if (what == EUIMSG.DEV_SET_JSON || what == EUIMSG.DEV_SET_CONFIG) {
        if (arg1 >= 0) {
          String data = "";
          if (ex != null) {
            if (ex.pData != null && ex.pData.length > 0) {
              data = new String(ex.pData, Charset.forName("UTF-8")).trim();
            } else if (ex.str != null) {
              data = ex.str.trim();
            }
          }
          if (promise == null) {
            Integer matchedSeq = null;
            Pending matchedPending = null;
            for (Entry<Integer, Pending> e : pending.entrySet()) {
              Pending p = e.getValue();
              if (p != null && "SET".equals(p.op)) {
                matchedSeq = e.getKey();
                matchedPending = p;
                break;
              }
            }
            if (matchedSeq != null && matchedPending != null) {
              Runnable r2 = timeoutRunnables.remove(matchedSeq);
              if (r2 != null) mainHandler.removeCallbacks(r2);
              pending.remove(matchedSeq);
              promise = matchedPending.promise;
              // Подменим pendingReq для дальнейшей сборки ответа
              pendingReq = matchedPending;
              Log.e(TAG, "Matched SET pending fallback: name=" + pendingReq.name + ", matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
            }
          }
          WritableMap res = Arguments.createMap();
          try {
            String cleaned = sanitizeJson(data);
            WritableMap value = DataConverter.parseToWritableMap(cleaned);
            if (value != null) {
              boolean needName = true;
              try {
                if (value.hasKey("Name") && value.getString("Name") != null && !value.getString("Name").isEmpty()) {
                  needName = false;
                }
              } catch (Throwable ignored) {}
              if (needName && pendingReq != null && pendingReq.name != null) {
                value.putString("Name", pendingReq.name);
              }
            }
            res.putString("s", pendingReq != null ? pendingReq.devId : "");
            res.putInt("i", 1);
            res.putMap("value", value);
          } catch (Throwable t) {
            res.putString("s", pendingReq != null ? pendingReq.devId : "");
            res.putInt("i", 1);
            res.putNull("value");
          }
          if (promise != null) {
            promise.resolve(res);
            pending.remove(seq);
          }
          Log.e(TAG, "DEV_SET_CONFIG success");
        } else {
          if (promise == null) {
            Integer matchedSeq = null;
            Pending matchedPending = null;
            for (Entry<Integer, Pending> e : pending.entrySet()) {
              Pending p = e.getValue();
              if (p != null && "SET".equals(p.op)) {
                matchedSeq = e.getKey();
                matchedPending = p;
                break;
              }
            }
            if (matchedSeq != null && matchedPending != null) {
              Runnable r2 = timeoutRunnables.remove(matchedSeq);
              if (r2 != null) mainHandler.removeCallbacks(r2);
              pending.remove(matchedSeq);
              promise = matchedPending.promise;
              Log.e(TAG, "Matched SET pending on error: name=" + matchedPending.name + ", matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
            }
          }
          if (promise != null) {
            promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
            pending.remove(seq);
          }
          Log.e(TAG, "DEV_SET_CONFIG failed: what=" + what + ", err=" + arg1);
        }
        return 0;
      }

      if (what == EUIMSG.DEV_CMD_EN) {
        if (arg1 >= 0) {
          String data = ex != null && ex.pData != null ? new String(ex.pData, Charset.forName("UTF-8")).trim() : "";
          WritableMap map = Arguments.createMap();
          map.putString("data", data);
          if (pendingCmdGeneral != null) {
            if (pendingCmdGeneralTimeout != null) {
              mainHandler.removeCallbacks(pendingCmdGeneralTimeout);
              pendingCmdGeneralTimeout = null;
            }
            pendingCmdGeneral.resolve(map);
            pendingCmdGeneral = null;
          }
          Log.e(TAG, "DEV_CMD_EN success: dataLen=" + (data != null ? data.length() : 0));
        } else {
          if (pendingCmdGeneral != null) {
            if (pendingCmdGeneralTimeout != null) {
              mainHandler.removeCallbacks(pendingCmdGeneralTimeout);
              pendingCmdGeneralTimeout = null;
            }
            pendingCmdGeneral.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
            pendingCmdGeneral = null;
          }
          Log.e(TAG, "DEV_CMD_EN failed: what=" + what + ", err=" + arg1);
        }
        return 0;
      }

      Log.e(TAG, "Unhandled what: " + what + ", arg1=" + arg1 + ", seq=" + seq);
    } catch (Throwable t) {
      if (promise != null) {
        promise.reject("FunSDKDevConfigModule", t);
      } else if (pendingCmdGeneral != null) {
        if (pendingCmdGeneralTimeout != null) {
          mainHandler.removeCallbacks(pendingCmdGeneralTimeout);
          pendingCmdGeneralTimeout = null;
        }
        pendingCmdGeneral.reject("FunSDKDevConfigModule", t);
        pendingCmdGeneral = null;
      }
      Log.e(TAG, "OnFunSDKResult exception", t);
    }

    return 0;
  }
}

