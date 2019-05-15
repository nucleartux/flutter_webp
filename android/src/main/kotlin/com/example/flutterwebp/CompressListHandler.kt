package com.example.flutterwebp

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class CompressListHandler(var call: MethodCall, var result: MethodChannel.Result) {

    companion object {
        @JvmStatic
        private val executor = Executors.newFixedThreadPool(5)
    }

    fun handle() {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val arr = args[0] as ByteArray
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            try {
                result.success(compress(arr, minWidth, minHeight, quality, rotate))
            } catch (e: Exception) {
                if(FlutterWebpPlugin.showLog) e.printStackTrace()
                result.success(null)
            }
        }
    }

    private fun compress(arr: ByteArray, width: Int, height: Int, quality: Int, rotate: Int = 0): ByteArray {
        val bitmap = BitmapFactory.decodeByteArray(arr, 0, arr.count())
        val outputStream = ByteArrayOutputStream()

        Bitmap.createScaledBitmap(bitmap, width, height, true)
                .rotate(rotate)
                .compress(Bitmap.CompressFormat.JPEG, quality, outputStream)

        return outputStream.toByteArray()
    }

}

private fun log(any: Any?) {
    if (FlutterWebpPlugin.showLog) {
        println(any ?: "null")
    }
}