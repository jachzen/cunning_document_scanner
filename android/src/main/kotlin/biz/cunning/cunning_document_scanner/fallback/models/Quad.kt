package biz.cunning.cunning_document_scanner.fallback.models

import android.graphics.PointF
import android.graphics.RectF
import biz.cunning.cunning_document_scanner.fallback.enums.QuadCorner
import biz.cunning.cunning_document_scanner.fallback.extensions.distance
import biz.cunning.cunning_document_scanner.fallback.extensions.move
import biz.cunning.cunning_document_scanner.fallback.extensions.multiply
import biz.cunning.cunning_document_scanner.fallback.extensions.toPointF

/**
 * This class is used to represent the cropper. It contains 4 corners.
 *
 * @param topLeftCorner the top left corner
 * @param topRightCorner the top right corner
 * @param bottomRightCorner the bottom right corner
 * @param bottomLeftCorner the bottom left corner
 * @constructor creates a quad from Android points
 */
class Quad(
    val topLeftCorner: PointF,
    val topRightCorner: PointF,
    val bottomRightCorner: PointF,
    val bottomLeftCorner: PointF
) {
    /**
     * @constructor creates a quad from OpenCV points
     */
    constructor(
        topLeftCorner: Point,
        topRightCorner: Point,
        bottomRightCorner: Point,
        bottomLeftCorner: Point
    ) : this(
        topLeftCorner.toPointF(),
        topRightCorner.toPointF(),
        bottomRightCorner.toPointF(),
        bottomLeftCorner.toPointF()
    )

    /**
     * @property corners lets us get the point coordinates for any corner
     */
    var corners: MutableMap<QuadCorner, PointF> = mutableMapOf(
        QuadCorner.TOP_LEFT to topLeftCorner,
        QuadCorner.TOP_RIGHT to topRightCorner,
        QuadCorner.BOTTOM_RIGHT to bottomRightCorner,
        QuadCorner.BOTTOM_LEFT to bottomLeftCorner
    )

    /**
     * @property edges 4 lines that connect the 4 corners
     */
    val edges: Array<Line> get() = arrayOf(
        Line(topLeftCorner, topRightCorner),
        Line(topRightCorner, bottomRightCorner),
        Line(bottomRightCorner, bottomLeftCorner),
        Line(bottomLeftCorner, topLeftCorner)
    )

    /**
     * This finds the corner that's closest to a point. When a user touches to drag
     * the cropper, that point is used to determine which corner to move.
     *
     * @param point we want to find the corner closest to this point
     * @return the closest corner
     */
    fun getCornerClosestToPoint(point: PointF): QuadCorner {
        return corners.minByOrNull { corner -> corner.value.distance(point) }?.key!!
    }

    /**
     * This moves a corner by (dx, dy)
     *
     * @param corner the corner that needs to be moved
     * @param dx the corner moves dx horizontally
     * @param dy the corner moves dy vertically
     */
    fun moveCorner(corner: QuadCorner, dx: Float, dy: Float) {
        corners[corner]?.offset(dx, dy)
    }

    /**
     * This maps original image coordinates to preview image coordinates. The original image
     * is probably larger than the preview image.
     *
     * @param imagePreviewBounds offset the point by the top left of imagePreviewBounds
     * @param ratio multiply the point by ratio
     * @return the 4 corners after mapping coordinates
     */
    fun mapOriginalToPreviewImageCoordinates(imagePreviewBounds: RectF, ratio: Float): Quad {
        return Quad(
            topLeftCorner.multiply(ratio).move(
                imagePreviewBounds.left,
                imagePreviewBounds.top
            ),
            topRightCorner.multiply(ratio).move(
                imagePreviewBounds.left,
                imagePreviewBounds.top
            ),
            bottomRightCorner.multiply(ratio).move(
                imagePreviewBounds.left,
                imagePreviewBounds.top
            ),
            bottomLeftCorner.multiply(ratio).move(
                imagePreviewBounds.left,
                imagePreviewBounds.top
            )
        )
    }

    /**
     * This maps preview image coordinates to original image coordinates. The original image
     * is probably larger than the preview image.
     *
     * @param imagePreviewBounds reverse offset the point by the top left of imagePreviewBounds
     * @param ratio divide the point by ratio
     * @return the 4 corners after mapping coordinates
     */
    fun mapPreviewToOriginalImageCoordinates(imagePreviewBounds: RectF, ratio: Float): Quad {
        return Quad(
            topLeftCorner.move(
                -imagePreviewBounds.left,
                -imagePreviewBounds.top
            ).multiply(1 / ratio),
            topRightCorner.move(
                -imagePreviewBounds.left,
                -imagePreviewBounds.top
            ).multiply(1 / ratio),
            bottomRightCorner.move(
                -imagePreviewBounds.left,
                -imagePreviewBounds.top
            ).multiply(1 / ratio),
            bottomLeftCorner.move(
                -imagePreviewBounds.left,
                -imagePreviewBounds.top
            ).multiply(1 / ratio)
        )
    }
}