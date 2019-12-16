package com.example.flutterwebp

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterWebpPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "flutter_webp")
            channel.setMethodCallHandler(FlutterWebpPlugin())
        }

        var showLog = false
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "showLog" -> result.success(handleLog(call))
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "compressWithList" -> CompressListHandler(call, result).handle()
            "compressWithFile" -> CompressFileHandler(call, result).handle()
            "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile()
            else -> result.notImplemented()
        }
    }

    private fun handleLog(call: MethodCall): Int {
        val arg = call.arguments<Boolean>()
        showLog = (arg == true)
        return 1
    }
}
