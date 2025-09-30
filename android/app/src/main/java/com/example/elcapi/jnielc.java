package com.example.elcapi;

/* loaded from: classes.dex */
public class jnielc {
    public static final native int ledseek(int i, int i2);

    public static final native int ledseek3(int i, int i2);

    public static final native int seekstart();

    public static final native int seekstart3();

    public static final native int seekstop();

    public static final native int seekstop3();

    static {
        System.loadLibrary("jnielc");
    }
}