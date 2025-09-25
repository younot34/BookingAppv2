package com.example.elcapi;


import android.app.ActivityManager;
import android.content.Context;
import android.util.Log;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Usage:
 *  Sampler.getInstance().init(getApplicationContext(), 100L);
 *  Sampler.getInstance().start();
 */
public class Sampler implements Runnable {

    private volatile static Sampler instance = null;
    private ScheduledExecutorService scheduler;
    private ActivityManager activityManager;
    private long freq;
	Context ncontext;
	private boolean mpflag=false;
	private static final int seek_red=0xa1;
	private static final int seek_green=0xa2;
	private static final int seek_blue=0xa3;
	private static final int seek_green_blue=0xa4;
	private static final int seek_red_blue=0xa5;
	private static final int seek_red_green=0xa6;
	private static final int seek_all=0xa7;

	private static final int seek_red_left=0xb1;
	private static final int seek_green_left=0xb2;
	private static final int seek_blue_left=0xb3;
	private static final int seek_green_blue_left=0xb4;
	private static final int seek_red_blue_left=0xb5;
	private static final int seek_red_green_left=0xb6;
	private static final int seek_all_left=0xb7;

	private static final int led_off=20;
	private static final int led_on=1;
	private static final int led_red=2;
	private static final int led_blue=3;
	private static final int led_green=4;
	private static final int led_bluegreen=5;
	private static final int led_redgreen=6;
	private static final int led_redblue=7;
	private static final int led_redgreemblue=8;
	private static final int led_red_left=9;
	private static final int led_blue_left=10;
	private static final int led_green_left=11;
	private static final int led_bluegreen_left=12;
	private static final int led_redgreen_left=13;
	private static final int led_redblue_left=14;
	private static final int led_redgreemblue_left=15;
	private int ledCtlFlag=led_red;
	private static boolean ledrunflag=false;

    private Sampler() {
        scheduler = Executors.newSingleThreadScheduledExecutor();
    }

    public static Sampler getInstance() {
        if (instance == null) {
            synchronized (Sampler.class) {
                if (instance == null) {
                    instance = new Sampler();
                }
            }
        }
        return instance;
    }

    // freq为采样周期
    public void init(Context context, long freq) {
		ncontext=context;
        activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        this.freq = freq;
    }

    public void start() {
		ledrunflag=true;
        scheduler.scheduleWithFixedDelay(this, 0L, freq, TimeUnit.MILLISECONDS);
    }
	
	public void stop(){
		Log.i("xiao","xiao--ledrunflag is false");
		ledrunflag=false;
	}
	public boolean getledflag(){
		return ledrunflag;
	}

    @Override
    public void run() {
		if(ledrunflag==true) {
			if (ledCtlFlag == led_red) {
				ledCtlFlag = led_blue;
				jnielc.seekstart();
				jnielc.ledseek(seek_red, 10);
				jnielc.ledseek(seek_green_left, 10);
				jnielc.seekstop();
			} else if (ledCtlFlag == led_blue) {
				ledCtlFlag = led_green;
				jnielc.seekstart();
				jnielc.ledseek(seek_blue, 10);
				jnielc.ledseek(seek_red_left, 10);
				jnielc.seekstop();
			} else if (ledCtlFlag == led_green) {
				ledCtlFlag = led_bluegreen;
				jnielc.seekstart();
				jnielc.ledseek(seek_green, 10);
				jnielc.ledseek(seek_green_blue_left, 10);
				jnielc.seekstop();
			}else if (ledCtlFlag == led_bluegreen) {
				ledCtlFlag = led_redgreen;
				jnielc.seekstart();
				jnielc.ledseek(seek_green_blue, 10);
				jnielc.ledseek(seek_blue_left, 10);
				jnielc.seekstop();
			}
			else if (ledCtlFlag == led_redgreen) {
				ledCtlFlag = led_redblue;
				jnielc.seekstart();
				jnielc.ledseek(seek_red_blue, 10);
				jnielc.ledseek(seek_red_green_left, 10);
				jnielc.seekstop();
			}
			else if (ledCtlFlag == led_redblue) {
				ledCtlFlag = led_redgreemblue;
				jnielc.seekstart();
				jnielc.ledseek(seek_red_green, 10);
				jnielc.ledseek(seek_all_left, 10);
				jnielc.seekstop();
			}
			else if (ledCtlFlag == led_redgreemblue) {
				ledCtlFlag = led_red;
				jnielc.seekstart();
				jnielc.ledseek(seek_all, 10);
				jnielc.ledseek(seek_red_green_left, 10);
				jnielc.seekstop();
			}
		}
			Log.i("xiao","xiao--led Runnable-1");
    }
}
