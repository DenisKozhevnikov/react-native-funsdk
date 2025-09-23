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

import com.lib.FunSDK;
import com.lib.IFunSDKResult;
import com.lib.MsgContent;
import com.lib.EUIMSG;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Map.Entry;
import org.json.JSONObject;
import org.json.JSONException;
import com.funsdk.utils.DataConverter;

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
        return obj.getString("Name");
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

  // === Public RN API ===

  /**
   * Получение JSON-конфига с устройства (эквивалент iOS FUN_DevGetConfig_Json)
   * params: { deviceId, name, nOutBufLen, channel, timeout }
   */
  @ReactMethod
  public void getDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final int nOutBufLen = params.hasKey("nOutBufLen") ? params.getInt("nOutBufLen") : 0;
    final int channel = params.hasKey("channel") ? params.getInt("channel") : -1;
    final int timeoutRaw = params.hasKey("timeout") ? params.getInt("timeout") : 15000;

    int effectiveChannel = channel;
    if (isGlobalConfigName(name)) {
      effectiveChannel = -1;
    }
    int timeout = timeoutRaw;
    if (isGlobalConfigName(name) && timeoutRaw < 12000) {
      timeout = 15000;
    }

    final int seq = nextSeq();
    pending.put(seq, new Pending(promise, devId, name, effectiveChannel, timeout, "GET"));

    Log.e(TAG, "getDevConfig: devId=" + devId + ", name=" + name + ", outLen=" + nOutBufLen + ", chRaw=" + channel + ", effectiveCh=" + effectiveChannel + ", timeout=" + timeout + ", seq=" + seq);
    // int DevGetConfigByJson(int userId, String devId, String cmd, int outLen, int chn, int timeout, int seq)
    int ret = FunSDK.DevGetConfigByJson(mUserId, devId, name, nOutBufLen, effectiveChannel, timeout, seq);
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

  /**
   * Сохранение JSON-конфига на устройство (эквивалент iOS FUN_DevSetConfig_Json)
   * params: { deviceId, name, param (json), channel, timeout }
   */
  @ReactMethod
  public void setDevConfig(ReadableMap params, Promise promise) {
    ensureUser();
    final String devId = params.getString("deviceId");
    final String name = params.getString("name");
    final String json = params.getString("param");
    final int channel = params.hasKey("channel") ? params.getInt("channel") : -1;
    final int timeout = params.hasKey("timeout") ? params.getInt("timeout") : 15000;

    final int seq = nextSeq();
    pending.put(seq, new Pending(promise, devId, name, channel, timeout, "SET"));

    final String jsonStr = json != null ? json : "";
    Log.e(TAG, "setDevConfig: devId=" + devId + ", name=" + name + ", jsonLen=" + jsonStr.length() + ", ch=" + channel + ", timeout=" + timeout + ", seq=" + seq);
    // int DevSetConfigByJson(int userId, String devId, String cmd, String json, int chn, int timeout, int seq)
    int ret = FunSDK.DevSetConfigByJson(mUserId, devId, name, jsonStr, channel, timeout, seq);
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
    final int seq = msg.arg2; // FunSDK обычно возвращает seq в arg2

    Pending pendingReq = pending.remove(seq);
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
          // Fallback-сопоставление по имени конфигурации, если seq не совпал
          if (promise == null && data != null && !data.isEmpty()) {
            String returnedName = extractNameFromJson(sanitizeJson(data));
            if (returnedName != null) {
              Integer matchedSeq = null;
              Pending matchedPending = null;
              Iterator<Entry<Integer, Pending>> it = pending.entrySet().iterator();
              while (it.hasNext()) {
                Entry<Integer, Pending> e = it.next();
                Pending p = e.getValue();
                if (p != null && returnedName.equals(p.name)) {
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
                Log.e(TAG, "Matched pending by name fallback: name=" + returnedName + ", matchedSeq=" + matchedSeq + ", actualSeq=" + seq);
              }
            }
          }
          if (promise != null) {
            try {
              String cleaned = sanitizeJson(data);
              if (cleaned == null || cleaned.isEmpty()) {
                promise.reject("ParseError", "Empty JSON in DEV_GET_CONFIG");
              } else {
                try {
                  WritableMap parsed = DataConverter.parseToWritableMap(cleaned);
                  promise.resolve(parsed);
                } catch (Throwable inner) {
                  // резерв: вынем простые поля Name/SerialNo
                  WritableMap fallback = Arguments.createMap();
                  try {
                    int nameIdx = cleaned.indexOf("\"Name\"");
                    if (nameIdx >= 0) {
                      int colon = cleaned.indexOf(':', nameIdx);
                      int q1 = cleaned.indexOf('"', colon + 1);
                      int q2 = cleaned.indexOf('"', q1 + 1);
                      if (q1 > 0 && q2 > q1) fallback.putString("Name", cleaned.substring(q1 + 1, q2));
                    }
                  } catch (Throwable ignored) {}
                  try {
                    int snIdx = cleaned.indexOf("\"SerialNo\"");
                    if (snIdx >= 0) {
                      int colon = cleaned.indexOf(':', snIdx);
                      int q1 = cleaned.indexOf('"', colon + 1);
                      int q2 = cleaned.indexOf('"', q1 + 1);
                      if (q1 > 0 && q2 > q1) fallback.putString("SerialNo", cleaned.substring(q1 + 1, q2));
                    }
                  } catch (Throwable ignored) {}
                  promise.resolve(fallback);
                }
              }
            } catch (Throwable t) {
              promise.reject("ParseError", t);
            }
          }
          Log.e(TAG, "DEV_GET_CONFIG success: dataLen=" + (data != null ? data.length() : 0));
        } else {
          // Ошибка: пробуем сопоставить pending, даже если seq не совпал
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
          if (promise != null) promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
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
          // Fallback: если seq не совпал (например, -1), найдём подходящий pending SET
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
            // Добьём Name, если SDK вернул пусто
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
          if (promise != null) promise.resolve(res);
          Log.e(TAG, "DEV_SET_CONFIG success");
        } else {
          // Ошибка: сопоставим pending SET даже при некорректном seq
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
          if (promise != null) promise.reject("FunSDK", String.valueOf(what) + " " + String.valueOf(arg1));
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

      // Неизвестный what — оставим след в логе для диагностики
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

