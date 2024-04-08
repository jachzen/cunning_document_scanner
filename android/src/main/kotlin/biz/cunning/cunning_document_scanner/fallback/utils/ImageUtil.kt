package biz.cunning.cunning_document_scanner.fallback.utils

import android.content.ContentResolver
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.media.ExifInterface
import android.net.Uri
import biz.cunning.cunning_document_scanner.fallback.models.Quad
import kotlin.math.pow
import kotlin.math.sqrt


class ImageUtil {

    fun getImageFromFilePath(filePath: String): Bitmap? {
        val rotation = getRotationDegrees(filePath)
        val bitmap = BitmapFactory.decodeFile(filePath) ?: return null

        return if (rotation != 0) {
            val matrix = Matrix().apply { postRotate(rotation.toFloat()) }
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } else {
            bitmap
        }
    }

    private fun getRotationDegrees(filePath: String): Int {
        val exif = ExifInterface(filePath)
        return when (exif.getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL
        )) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90
            ExifInterface.ORIENTATION_ROTATE_180 -> 180
            ExifInterface.ORIENTATION_ROTATE_270 -> 270
            else -> 0
        }
    }


    fun crop(photoFilePath: String, corners: Quad): Bitmap? {
        val bitmap = getImageFromFilePath(photoFilePath) ?: return null

        // Convert Quad corners to a float array manually
        val src = floatArrayOf(
            corners.topLeftCorner.x, corners.topLeftCorner.y,
            corners.topRightCorner.x, corners.topRightCorner.y,
            corners.bottomRightCorner.x, corners.bottomRightCorner.y,
            corners.bottomLeftCorner.x, corners.bottomLeftCorner.y
        )

        val avgWidth = getAvgWidth(corners)
        val avgHeight = getAvgHeight(corners)

        // Maintain the aspect ratio based on the longer dimension
        val aspectRatio = avgWidth / avgHeight

        val dstWidth: Float
        val dstHeight: Float

        if (aspectRatio >= 1) { // Width is greater than height, landscape orientation
            dstWidth = avgWidth
            dstHeight = dstWidth / aspectRatio
        } else { // Height is greater than width, portrait orientation
            dstHeight = avgHeight
            dstWidth = dstHeight * aspectRatio
        }

        // Use dstWidth and dstHeight to define your dst points accordingly
        val dst = floatArrayOf(
            0f, 0f,                     // Top-left
            dstWidth, 0f,               // Top-right
            dstWidth, dstHeight,        // Bottom-right
            0f, dstHeight               // Bottom-left
        )

        return correctPerspective(bitmap, src, dst, dstWidth, dstHeight)
    }

    fun correctPerspective(b: Bitmap, srcPoints: FloatArray?, dstPoints: FloatArray?, w: Float, h: Float): Bitmap {
        val result = Bitmap.createBitmap(w.toInt(), h.toInt(), Bitmap.Config.ARGB_8888)
        val p = Paint(Paint.ANTI_ALIAS_FLAG)
        val c = Canvas(result)
        val m = Matrix()
        m.setPolyToPoly(srcPoints, 0, dstPoints, 0, 4)
        c.drawBitmap(b, m, p)
        return result
    }

    private fun getAvgWidth(corners: Quad): Float {
        val widthTop = sqrt(
            (corners.topRightCorner.x - corners.topLeftCorner.x).toDouble().pow(2.0) + (corners.topRightCorner.y - corners.topLeftCorner.y).toDouble()
                .pow(2.0)
        ).toFloat()
        val widthBottom = sqrt(
            (corners.bottomLeftCorner.x - corners.bottomRightCorner.x).toDouble().pow(2.0) + (corners.bottomLeftCorner.y - corners.bottomRightCorner.y).toDouble()
                .pow(2.0)
        ).toFloat()
        return (widthTop + widthBottom) / 2
    }

    private fun getAvgHeight(corners: Quad): Float {
        val heightLeft = sqrt(
            (corners.bottomLeftCorner.x - corners.topLeftCorner.x).toDouble().pow(2.0) + (corners.bottomLeftCorner.y - corners.topLeftCorner.y).toDouble()
                .pow(2.0)
        ).toFloat()
        val heightRight = sqrt(
            (corners.topRightCorner.x - corners.bottomRightCorner.x).toDouble().pow(2.0) + (corners.topRightCorner.y - corners.bottomRightCorner.y).toDouble()
                .pow(2.0)
        ).toFloat()
        return (heightLeft + heightRight) / 2
    }
}