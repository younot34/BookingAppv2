package com.example.testing

import com.example.elcapi.jnielc
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.elcapi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "ledSeek" -> {
                        val arg1 = call.argument<Int>("i") ?: 0
                        val arg2 = call.argument<Int>("i2") ?: 0
                        val res = jnielc.ledseek(arg1, arg2)
                        result.success(res)
                    }
                    "seekStart" -> {
                        val res = jnielc.seekstart()
                        result.success(res)
                    }
                    "seekStop" -> {
                        val res = jnielc.seekstop()
                        result.success(res)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("NATIVE_ERROR", e.message, null)
            }
        }
    }
}
