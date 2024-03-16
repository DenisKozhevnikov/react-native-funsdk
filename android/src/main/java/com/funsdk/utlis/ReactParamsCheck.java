package com.funsdk.utils;

import com.facebook.react.bridge.ReadableMap;

public class ReactParamsCheck {
    /**
     * Validation of input parameters
     */
    public static boolean checkParams(String[] keys, ReadableMap params) {
        for (String key : keys) {
            if (!params.hasKey(key)) {
                throw new IllegalArgumentException("need " + key);
            }
        }
        return true;
    }

    /**
     * Validation of input parameters
     */
    public static boolean checkParamsV2(String[] keys, ReadableMap params) {
        for (String key : keys) {
            if (!params.hasKey(key)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Проверяет один параметр в ReadableMap
     */
    public static boolean checkOneParam(String key, ReadableMap params) {
        return params.hasKey(key);
    }
}