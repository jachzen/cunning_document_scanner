package biz.cunning.cunning_document_scanner.fallback.ui

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageButton
import androidx.core.content.ContextCompat
import biz.cunning.cunning_document_scanner.R
import biz.cunning.cunning_document_scanner.fallback.extensions.drawCheck

/**
 * This class creates a circular done button by modifying an image button. The user presses
 * this button once they finish cropping an image
 *
 * @param context image button context
 * @param attrs image button attributes
 * @constructor creates done button
 */
class DoneButton(
    context: Context,
    attrs: AttributeSet
): AppCompatImageButton(context, attrs) {
    /**
     * @property ring the button's outer ring
     */
    private val ring = Paint(Paint.ANTI_ALIAS_FLAG)

    /**
     * @property circle the button's inner circle
     */
    private val circle = Paint(Paint.ANTI_ALIAS_FLAG)

    init {
        // set outer ring style
        ring.color = Color.WHITE
        ring.style = Paint.Style.STROKE
        ring.strokeWidth = resources.getDimension(R.dimen.large_button_ring_thickness)

        // set inner circle style
        circle.color = ContextCompat.getColor(context, R.color.done_button_inner_circle_color)
        circle.style = Paint.Style.FILL
    }

    /**
     * This gets called repeatedly. We use it to draw the done button.
     *
     * @param canvas the image button canvas
     */
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // calculate button center point, outer ring radius, and inner circle radius
        val centerX = width.toFloat() / 2
        val centerY = height.toFloat() / 2
        val outerRadius = (width.toFloat() - ring.strokeWidth) / 2
        val innerRadius = outerRadius - resources.getDimension(
            R.dimen.large_button_outer_ring_offset
        )

        // draw outer ring
        canvas.drawCircle(centerX, centerY, outerRadius, ring)

        // draw inner circle
        canvas.drawCircle(centerX, centerY, innerRadius, circle)

        // draw check icon since it gets covered by inner circle
        canvas.drawCheck(centerX, centerY, drawable)
    }
}