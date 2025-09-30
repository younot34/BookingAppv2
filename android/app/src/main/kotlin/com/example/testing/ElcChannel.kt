package com.example.testing

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.elcapi.jnielc

class ElcChannel(private val flutterEngine: FlutterEngine) {
    private val CHANNEL = "elc_channel"

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "ledSeek" -> {
                    val color = call.argument<Int>("color") ?: 1
                    val value = call.argument<Int>("value") ?: 1
                    val res = jnielc.ledseek(color, value)
                    result.success(res)
                }
                "ledSeek3" -> {
                    val color = call.argument<Int>("color") ?: 1
                    val value = call.argument<Int>("value") ?: 1
                    val res = jnielc.ledseek3(color, value)
                    result.success(res)
                }
                "seekStart" -> {
                    result.success(jnielc.seekstart())
                }
                "seekStop" -> {
                    result.success(jnielc.seekstop())
                }
                else -> result.notImplemented()
            }
        }
    }
}
