package com.example.elcapi;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.os.Handler;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver
{
	static final String ACTION = "android.intent.action.BOOT_COMPLETED";
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
	private int fd;
	private String mmPath="/storage/emulated/0";
	Context mcontext;

	private static final String pwm1 = "ledbrightness_zx";
	private static final String pwm2 = "ledbrightness_ml";

	private static final String led_right = "ledcolor_kp";
	private static final String led_left = "ledcolor_rd";
@Override
	public void onReceive(Context context, Intent intent) {
	if (intent.getAction().equals(ACTION)) {
		mcontext=context;
		Log.i("xiao", "android.intent.action.BOOT_COMPLETED");

		Log.i("xiao","get_led_color(led_right)="+get_led_color(led_right));
		Log.i("xiao","get_led_color(led_left)="+get_led_color(led_left));

		Log.i("xiao","get_led_brightness(pwm1)="+get_led_brightness(pwm1));
		Log.i("xiao","get_led_brightness(pwm2)="+get_led_brightness(pwm2));
		if(get_led_color(led_right)==0&&get_led_color(led_left)==0){
			set_led_color(led_on,led_right);
			set_led_color(led_on,led_left);
		}
			jnielc.seekstart();
			switch(get_led_color(led_right)) {
				case led_off:
					break;
				case led_on:
					Sampler.getInstance().init(context, 5000L);
					Sampler.getInstance().start();
					break;
				case led_red:
					jnielc.ledseek(seek_red, get_led_brightness(pwm1));
					break;
				case led_blue:
					jnielc.ledseek(seek_blue, get_led_brightness(pwm1));
					break;
				case led_green:
					jnielc.ledseek(seek_green, get_led_brightness(pwm1));
					break;
				case led_bluegreen:
					jnielc.ledseek(seek_green_blue, get_led_brightness(pwm1));
					break;
				case led_redgreen:
					jnielc.ledseek(seek_red_green, get_led_brightness(pwm1));
					break;
				case led_redblue:
					jnielc.ledseek(seek_red_blue, get_led_brightness(pwm1));
					break;
				case led_redgreemblue:
					jnielc.ledseek(seek_all, get_led_brightness(pwm1));
					break;
				default:
					break;
			}
			switch(get_led_color(led_left)) {
				case led_off:
					break;
				case led_on:
					Sampler.getInstance().init(context, 5000L);
					Sampler.getInstance().start();
					break;
				case led_red_left:
					jnielc.ledseek(seek_red_left,get_led_brightness(pwm2));
					break;
				case led_blue_left:
					jnielc.ledseek(seek_blue_left,get_led_brightness(pwm2));
					break;
				case led_green_left:
					jnielc.ledseek(seek_green_left,get_led_brightness(pwm2));
					break;
				case led_bluegreen_left:
					jnielc.ledseek(seek_green_blue_left,get_led_brightness(pwm2));
					break;
				case led_redgreen_left:
					jnielc.ledseek(seek_red_green_left, get_led_brightness(pwm2));
					break;
				case led_redblue_left:
					jnielc.ledseek(seek_red_blue_left, get_led_brightness(pwm2));
					break;
				case led_redgreemblue_left:
					jnielc.ledseek(seek_all_left, get_led_brightness(pwm2));
					break;
				default:
					break;
			}
			jnielc.seekstop();
		}
	}

	private void set_led_color(int freq,String name){
		SharedPreferences save_par = mcontext.getSharedPreferences("addata", 0);
		SharedPreferences.Editor save_editor = save_par.edit();
		save_editor.putString(name, String.valueOf(freq));
		save_editor.commit();
	}

	private int get_led_color(String name){
		int value = 0;
		try {
			SharedPreferences save_par = mcontext.getSharedPreferences("addata", 0);
			value = Integer.parseInt(save_par.getString(name, "0"));
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
		}
		return value;
	}
	private int get_led_brightness (String name){
		int value = 0;
		try {
			SharedPreferences save_par = mcontext.getSharedPreferences("addata", 0);
			value = Integer.parseInt(save_par.getString(name, "0"));
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
		}
		return value;
	}
} 
