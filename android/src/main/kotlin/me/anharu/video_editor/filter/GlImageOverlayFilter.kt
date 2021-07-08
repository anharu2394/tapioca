package me.anharu.video_editor.filter

import android.graphics.BitmapFactory
import android.graphics.Canvas
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.ImageOverlay

class GlImageOverlayFilter(imageOverlay: ImageOverlay) : GlOverlayFilter() {
    private val imageOverlay: ImageOverlay = imageOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        canvas.drawBitmap(BitmapFactory.decodeByteArray(imageOverlay.bitmap, 0, imageOverlay.bitmap.size), imageOverlay.x.toFloat(), imageOverlay.y.toFloat(), null);
    }
}