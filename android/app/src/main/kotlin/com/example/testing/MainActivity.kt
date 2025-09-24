package com.example.testing

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.testing.Jnielc

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.testing/elcapi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "ledOff" -> {
                    val res = Jnielc.ledoff()
                    result.success(res)
                }
                "ledSeek" -> {
                    val res = Jnielc.ledseek()
                    result.success(res)
                }
                "seekStart" -> {
                    val res = Jnielc.seekstart()
                    result.success(res)
                }
                "seekStop" -> {
                    val res = Jnielc.seekstop()
                    result.success(res)
                }
                else -> result.notImplemented()
            }
        }
  