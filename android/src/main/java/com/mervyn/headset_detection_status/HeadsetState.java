package com.mervyn.headset_detection_status;

public enum HeadsetState {

    DISCONNECTED(0, "disconnect", "断开连接"),

    CONNECTED(1,"connect", "已连接"),

    DISCONNECTING(2, "disconnecting", "断开中"),

    CONNECTING(3,"connecting", "连接中"),

    UNKNOWN(-1,"unknown", "未知");

    private int state;
    private String method;
    private String desc;

    HeadsetState(int state, String method, String desc) {
        this.state = state;
        this.method = method;
        this.desc = desc;
    }

    public int getState() {
        return state;
    }

    public String getMethod() {
        return method;
    }

    public String getDesc() {
        return desc;
    }
}
