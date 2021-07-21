package me.anharu.video_editor

import android.Manifest
import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import com.daasuu.mp4compose.composer.Mp4Composer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.math.log


/** VideoEditorPlugin */
public class VideoEditorPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, ActivityAware {
    var activity: Activity? = null
    private var methodChannel: MethodChannel? = null
    private val myPermissionCode = 34264

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(flutterPluginBinding.binaryMessenger)
    }

    fun onAttachedToEngine(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "video_editor")
        methodChannel?.setMethodCallHandler(this)
    }


    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = VideoEditorPlugin()
            instance.onAttachedToEngine(registrar.messenger())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
       Log.d("demo",call.method);
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "writeVideofile" -> {

                val getActivity = activity ?: return
                checkPermission(getActivity)

                val srcFilePath: String = call.argument("srcFilePath") ?: run {
                    result.error("src_file_path_not_found", "the src file path is not found.", null)
                    return
                }
                val destFilePath: String = call.argument("destFilePath") ?: run {
                    result.error("dest_file_path_not_found", "the dest file path is not found.", null)
                    return
                }
                val processing: HashMap<String, HashMap<String, Any>> = call.argument("processing")
                        ?: run {
                            result.error("processing_data_not_found", "the processing is not found.", null)
                            return
                        }

                val startTime: Long = call.argument<Int>("startTime")?.toLong() ?: 0
                val endTime: Long = call.argument<Int>("endTime")?.toLong() ?: -1
                val generator = VideoGeneratorService(Mp4Composer(srcFilePath, destFilePath))
                generator.writeVideofile(processing, result, getActivity, startTime = startTime, endTime = endTime)
            }
            "trim_video" -> {
                val getActivity = activity ?: return
                val srcFilePath: String = call.argument("srcFilePath") ?: run {
                    result.error("src_file_path_not_found", "the src file path is not found.", null)
                    return
                }
                val destFilePath: String = call.argument("destFilePath") ?: run {
                    result.error("dest_file_path_not_found", "the dest file path is not found.", null)
                    return
                }
                val startTime: Long = call.argument<Int>("startTime")?.toLong() ?: 0
                val endTime: Long = call.argument<Int>("endTime")?.toLong() ?: -1
                VideoTrimmer(srcFilePath, destFilePath, result, getActivity).trimVideo(startTime, endTime)
            }
            "speed_change" -> {
                val getActivity = activity ?: return
                val srcFilePath: String = call.argument("srcFilePath") ?: run {
                    result.error("src_file_path_not_found", "the src file path is not found.", null)
                    return
                }
                val destFilePath: String = call.argument("destFilePath") ?: run {
                    result.error("dest_file_path_not_found", "the dest file path is not found.", null)
                    return
                }
                val speed: Float = call.argument<Double>("speed")?.toFloat() ?: 1F
               print("===>$speed");
                SpeedChanger(srcFilePath, destFilePath, result, getActivity).speed(speed)
            }
            else -> {
                print("===>sxxxxxxxx");
                result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        methodChannel!!.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?,
                                            grantResults: IntArray?): Boolean {
        when (requestCode) {
            myPermissionCode -> {
                // Only return true if handling the requestCode
                return true
            }
        }
        return false
    }

    // Invoked either from the permission result callback or permission check
    private fun completeInitialization() {

    }

    private fun checkPermission(activity: Activity) {
        ActivityCompat.requestPermissions(activity,
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE), myPermissionCode)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
