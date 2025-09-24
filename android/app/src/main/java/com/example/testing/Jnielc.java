package com.example.testing;

public class Jnielc {
    static {
        System.loadLibrary("jnielc");
    }

    public static native void ledoff();
    public static native void ledseek();
    public static native void seekstart();
    public static native void seekstop();
}
