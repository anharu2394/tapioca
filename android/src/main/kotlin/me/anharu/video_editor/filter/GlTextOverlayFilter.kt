package me.anharu.video_editor.filter

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.TextOverlay



class GlTextOverlayFilter(textOverlay: TextOverlay) : GlOverlayFilter() {
    private val textOverlay: TextOverlay = textOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        val bitmap: Bitmap = textAsBitmap(textOverlay.text,textOverlay.size.toFloat(),textOverlay.color)
        canvas.drawBitmap(bitmap,textOverlay.x.toFloat(),textOverlay.y.toFloat(),null);
    }
    private fun textAsBitmap(text: String, textSize: Float, color: String): Bitmap {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        //TODO : Use specified font - via. Typeface
        //TODO : Support Text Bold, Italic & Bold Italic - via. Typeface
        paint.textSize = textSize
        paint.color = Color.parseColor(color)
        //TODO : Support Center & Right Aligns
        //TODO : Support text will be out of video boundaries check
        //TODO : Support fallback align if text will be out of video boundaries
        paint.textAlign = Paint.Align.LEFT
        val baseline = -paint.ascent() // ascent() is negative
        val width = (paint.measureText(text) + 0.5f).toInt() // round
        val height = (baseline + paint.descent() + 0.5f).toInt()
        val image = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(image)
        canvas.drawText(text, 0f, baseline, paint)
        return image
    }
}