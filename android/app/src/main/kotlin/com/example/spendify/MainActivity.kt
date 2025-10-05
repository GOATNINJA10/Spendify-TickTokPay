package com.example.spendify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Add custom channel to handle text input
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "text_input_channel").setMethodCallHandler { call, result ->
            when (call.method) {
                "showSoftKeyboard" -> {
                    try {
                        activity?.window?.decorView?.requestFocus()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
