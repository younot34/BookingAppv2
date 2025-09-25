package com.example.elcapi;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Author elc_zhangfei
 * Time 2018/1/24
 */
public class SystemProperteisProxy {

    public static String getString(String key) {
        return getProxy(key, String.class);
    }

    public static String getString(String key, String def) {
        return getDefaultProxy(key, "get", String.class, def);
    }

    public static int getInt(String key, int def) {
        return getDefaultProxy(key, "getInt", Integer.class, def);
    }

    public static long getLong(String key, long def) {
        return getDefaultProxy(key, "getLong", Long.class, def);
    }

    public static boolean getBoolean(String key, boolean def) {
        return getDefaultProxy(key, "getBoolean", Boolean.class, def);
    }

    public static void set(String key, String val) {
        setProxy(key, val);
    }

    /**
     * Set the value for the given key.
     *
     * @throws IllegalArgumentException if the key exceeds 32 characters
     * @throws IllegalArgumentException if the value exceeds 92 characters
     */
    private static void setProxy(String key, String val) {
        try {
            Class<?> c = Class.forName("android.os.SystemProperties");
            Method set = c.getMethod("set", String.class, String.class);
            set.invoke(c, key, val);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }

    }


    /**
     * Get the value for the given key.
     *
     * @return an empty string if the key isn't found
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    private static <T> T getProxy(String key, Class<T> paramsClass) {
        T result = null;
        try {
            Class<?> c = Class.forName("android.os.SystemProperties");
            Method get = c.getMethod("get", paramsClass);
            result = (T) get.invoke(c, key);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Get the value for the given key.
     *
     * @return an empty string if the key isn't found
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    private static <T> T getDefaultProxy(String key, String methodName, Class<T> paramsClass, T defaultValue) {
        T result = defaultValue;
        try {
            Class<?> c = Class.forName("android.os.SystemProperties");
            Method get = c.getMethod(methodName, String.class, paramsClass);
            result = (T) get.invoke(c, key, defaultValue);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
        return result;
    }

}
