package com.tuya.smart.rnsdk.utils;

import com.facebook.react.bridge.ReadableMap;

public class ReactParamsCheck {
    /**
     *  Validation of input parameters
     */
    public static boolean checkParams(String[] keys, ReadableMap params) {
        for (String key : keys) {
            if (!params.hasKey(key)) {
                throw new IllegalArgumentException("need " + key);
            }
        }
        return true;
    }
}