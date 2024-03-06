package biz.cunning.cunning_document_scanner.fallback.ui

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageButton
import biz.cunning.cunning_document_scanner.R

/**
 * This class creates a circular done button by modifying an image button. This is used for the
 * add new document button and retake photo button.
 *
 * @param context image button context
 * @param attrs image button attributes
 * @constructor creates circle button
 */
class CircleButton(
    context: Context,
    attrs: AttributeSet
): AppCompatImageButton(context, attrs) {
    /**
     * @property ring the button's outer ring
     */
    private val ring = Paint(Paint.ANTI_ALIAS_FLAG)

    init {
        // set outer ring style
        ring.color = Color.WHITE
        ring.style = Paint.Style.STROKE
        ring.strokeWidth = resources.getDimension(R.dimen.small_button_ring_thickness)
    }

    /**
     * This gets called repeatedly. We use it to draw the button
     *
     * @param canvas the image button canvas
     */
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // draw outer ring
        canvas.drawCircle(
            (width / 2).toFloat(),
            (height / 2).toFloat(),
            (width.toFloat() - ring.strokeWidth) / 2,
            ring
        )
    }
}