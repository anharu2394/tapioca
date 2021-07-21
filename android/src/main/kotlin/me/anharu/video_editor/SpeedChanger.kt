package me.anharu.video_editor


import android.app.Activity
import com.daasuu.mp4compose.composer.Mp4Composer
import io.flutter.plugin.common.MethodChannel.Result

class SpeedChanger(inputVideo: String, outputVideo: String, val result: Result, val activity: Activity) {
    var composer: Mp4Composer = Mp4Composer(inputVideo, outputVideo)

    fun speed(speed:Float) {
        composer.timeScale(10F)
            .listener(object : Mp4Composer.Listener {
                override fun onProgress(progress: Double) {

                }

                override fun onCurrentWrittenVideoTime(timeUs: Long) {
                    TODO("Not yet implemented")
                }

                override fun onCompleted() {
                    activity.runOnUiThread(Runnable {
                        result.success(null)
                    })
                }

                override fun onCanceled() {
                    activity.runOnUiThread(Runnable {
                        result.error("user_cancelled", "Cancelled by user", null)
                    })
                }

                override fun onFailed(exception: Exception?) {
                    exception?.printStackTrace()
                    activity.runOnUiThread(Runnable {
                        result.error("video_trim_failed", exception?.localizedMessage, exception?.stackTrace)
                    })
                }

            }).start();
    }
}