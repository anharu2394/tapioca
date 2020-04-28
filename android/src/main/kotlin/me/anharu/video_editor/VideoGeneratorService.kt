package me.anharu.video_editor

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.daasuu.mp4compose.composer.Mp4Composer
import com.daasuu.mp4compose.filter.*
import me.anharu.video_editor.filter.GlImageOverlayFilter
import me.anharu.video_editor.ImageOverlay
import io.flutter.plugin.common.MethodChannel.Result
import android.graphics.Paint.Align
import android.graphics.Paint.ANTI_ALIAS_FLAG
import me.anharu.video_editor.filter.GlColorBlendFilter
import me.anharu.video_editor.filter.GlTextOverlayFilter


interface VideoGeneratorServiceInterface {
    fun writeVideofile(processing: HashMap<String,HashMap<String,Any>>, result: Result, activity: Activity);
}

class VideoGeneratorService(
        private val composer: Mp4Composer
) : VideoGeneratorServiceInterface {
    override fun writeVideofile(processing: HashMap<String,HashMap<String,Any>>, result: Result, activity: Activity ) {
        val filters: MutableList<GlFilter> = mutableListOf()
        try {
            processing.forEach { (k, v) ->
                when (k) {
                    "Filter" -> {
                        val passFilter = Filter(v)
                        val filter = GlColorBlendFilter(passFilter)
                        filters.add(filter)
                    }
                    "TextOverlay" -> {
                        val textOverlay = TextOverlay(v)
                        filters.add(GlTextOverlayFilter(textOverlay))
                    }
                    "ImageOverlay" -> {
                        val imageOverlay = ImageOverlay(v)
                        filters.add(GlImageOverlayFilter(imageOverlay))
                    }
                }
            }
        } catch (e: Exception){
            println(e)
            activity.runOnUiThread(Runnable {
                result.error("processing_data_invalid", "Processing data is invalid.", null)
            })
        }
        composer.filter(GlFilterGroup( filters))
                .listener(object : Mp4Composer.Listener {
                    override fun onProgress(progress: Double) {
                        println("onProgress = " + progress)
                    }

                    override fun onCompleted() {
                        activity.runOnUiThread(Runnable {
                            result.success(null)
                        })
                    }

                    override  fun onCanceled() {
                        activity.runOnUiThread(Runnable {
                            result.error("video_processing_canceled", "Video processing is canceled.", null)
                        })
                    }

                    override fun onFailed(exception: Exception) {
                        println(exception);
                        activity.runOnUiThread(Runnable {
                            result.error("video_processing_failed", "video processing is failed.", null)
                        })
                    }
                }).start()
    }
}

