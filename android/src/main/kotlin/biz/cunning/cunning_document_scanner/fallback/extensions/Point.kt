package biz.cunning.cunning_document_scanner.fallback.extensions

import android.graphics.PointF
import biz.cunning.cunning_document_scanner.fallback.models.Point
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * converts an OpenCV point to Android point
 *
 * @return Android point
 */
fun Point.toPointF(): PointF {
    return PointF(x.toFloat(), y.toFloat())
}


/**
 * offset the OpenCV point by (dx, dy)
 *
 * @param dx horizontal offset
 * @param dy vertical offset
 * @return the OpenCV point after moving it (dx, dy)
 */
fun Point.move(dx: Double, dy: Double): Point {
    return Point(x + dx, y + dy)
}

/**
 * multiply an Android point by magnitude
 *
 * @return Android point after multiplying by magnitude
 */
fun PointF.multiply(magnitude: Float): PointF {
    return PointF(magnitude * x, magnitude * y)
}

/**
 * offset the Android point by (dx, dy)
 *
 * @param dx horizontal offset
 * @param dy vertical offset
 * @return the Android point after moving it (dx, dy)
 */
fun PointF.move(dx: Float, dy: Float): PointF {
    return PointF(x + dx, y + dy)
}

/**
 * calculates the distance between 2 Android points
 *
 * @param point the 2nd Android point
 * @return the distance between this point and the 2nd point
 */
fun PointF.distance(point: PointF): Float {
    return sqrt((point.x - x).pow(2) + (point.y - y).pow(2))
}