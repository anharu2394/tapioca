package me.anharu.video_editor

import android.Manifest
import android.app.Application
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Environment
import android.util.EventLog
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.daasuu.mp4compose.composer.Mp4Composer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import me.anharu.video_editor.VideoGeneratorService
import java.io.File
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import android.util.Log


/** VideoEditorPlugin */
public class VideoEditorPlugin : FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    
    var activity: Activity? = null
    private var methodChannel: MethodChannel? = null

    lateinit var eventChannel: EventChannel
    private val myPermissionCode = 34264
    private val streamHandler = ResultStreamHandler()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(flutterPluginBinding.binaryMessenger)
    }

    fun onAttachedToEngine(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "video_editor")
        methodChannel?.setMethodCallHandler(this)
        EventChannel(messenger, "video_editor_progress").setStreamHandler(streamHandler)
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
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "writeVideofile") {
            var getActivity = activity ?: return
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
            val generator = VideoGeneratorService(Mp4Composer(srcFilePath, destFilePath))
            generator.writeVideofile(processing, result, getActivity,streamHandler)
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("writeVideofile","call onAttachedToActivity")
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



class ResultStreamHandler(): EventChannel.StreamHandler {
    var _eventSink: EventChannel.EventSink? = null
  
    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        Log.d("ResultStreamHandler","onListen =>" + p1)
      this._eventSink = p1
    }
  
    override fun onCancel(p0: Any?) {
      this._eventSink = null
    }

    fun sucess(p0:String){
        Log.d("ResultStreamHandler","onListen2 =>" + this._eventSink)
        this._eventSink?.success(p0)
    }
  
  }


