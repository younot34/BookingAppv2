package com.example.testing
import com.example.elcapi.Jnielc

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.testing/elcapi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "ledOff" -> {
                        Jnielc.ledoff()
                        result.success(null)
                    }
                    "ledSeek" -> {
                        Jnielc.ledseek()
                        result.success(null)
                    }
                    "seekStart" -> {
                        Jnielc.seekstart()
                        result.success(null)
                    }
                    "seekStop" -> {
                        Jnielc.seekstop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("NATIVE_ERROR", e.message, null)
            }
        }
    }
}