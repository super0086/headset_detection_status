package com.mervyn.headset_detection_status;

import java.util.HashMap;
import java.util.Map;

public class StateResult {
    public int wired;
    public int bluetooth;

    public StateResult(int wired, int bluetooth) {
        this.wired = wired;
        this.bluetooth = bluetooth;
    }

    public Map toHashMap() {
        Map result = new HashMap();
        result.put("wired", wired);
        result.put("bluetooth", bluetooth);
        return result;
    }
}
