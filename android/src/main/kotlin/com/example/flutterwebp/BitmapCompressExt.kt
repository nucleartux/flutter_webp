package com.example.flutterwebp

import android.graphics.Bitmap
import android.graphics.Matrix
import java.io.ByteArrayOutputStream
import java.io.OutputStream

fun Bitmap.compress(width: Int, height: Int, quality: Int, rotate: Int = 0): ByteArray {
    val outputStream = ByteArrayOutputStream()
    compress(width, height, quality, rotate, outputStream)
    return outputStream.toByteArray()
}


fun Bitmap.compress(width: Int, height: Int, quality: Int, rotate: Int = 0, outputStream: OutputStream) {
    Bitmap.createScaledBitmap(this, width, height, true)
            .rotate(rotate)
            .compress(Bitmap.CompressFormat.WEBP, quality, outputStream)
}

private fun log(any: Any?) {
    if (FlutterWebpPlugin.showLog) {
        println(any ?: "null")
    }
}

fun Bitmap.rotate(rotate: Int): Bitmap {
    return if (rotate % 360 != 0) {
        val matrix = Matrix()
        matrix.setRotate(rotate.toFloat())
   
        Bitmap.createBitmap(this, 0, 0, width, height, matrix, false)
    } else {
        this
    }
}