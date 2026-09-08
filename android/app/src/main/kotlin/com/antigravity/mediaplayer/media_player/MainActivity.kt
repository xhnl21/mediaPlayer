package com.antigravity.mediaplayer.media_player

import android.app.Activity
import android.content.ContentUris
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.antigravity.mediaplayer/device_audio"
    private var pendingDeleteResult: MethodChannel.Result? = null
    private val DELETE_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteAudio" -> {
                    val filePath = call.argument<String>("path")
                    val trackId = call.argument<String>("id")
                    deleteAudioFile(filePath, trackId, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun deleteAudioFile(filePath: String?, trackId: String?, result: MethodChannel.Result) {
        var deleted = false
        val cr = contentResolver

        // 1. Direct filesystem delete if it's a real file path
        if (!filePath.isNullOrEmpty() && !filePath.startsWith("content://")) {
            try {
                val file = File(filePath)
                if (file.exists()) {
                    deleted = file.delete()
                }
            } catch (e: Exception) {
                // Direct file delete may fail due to scoped storage; proceed to MediaStore
            }
        }

        // 2. Resolve Content Uri by trackId or content:// path
        val id = trackId?.toLongOrNull()
        val uri: Uri? = when {
            id != null -> ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
            !filePath.isNullOrEmpty() && filePath.startsWith("content://") -> Uri.parse(filePath)
            else -> null
        }

        if (uri != null) {
            try {
                val rows = cr.delete(uri, null, null)
                if (rows > 0) deleted = true
            } catch (se: SecurityException) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    try {
                        val deleteRequest = MediaStore.createDeleteRequest(cr, listOf(uri))
                        pendingDeleteResult = result
                        startIntentSenderForResult(
                            deleteRequest.intentSender,
                            DELETE_PERMISSION_REQUEST_CODE,
                            null, 0, 0, 0
                        )
                        return
                    } catch (e: Exception) {
                        // Fallback
                    }
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val recoverable = se as? android.app.RecoverableSecurityException
                    if (recoverable != null) {
                        pendingDeleteResult = result
                        startIntentSenderForResult(
                            recoverable.userAction.actionIntent.intentSender,
                            DELETE_PERMISSION_REQUEST_CODE,
                            null, 0, 0, 0
                        )
                        return
                    }
                }
            } catch (e: Exception) {
                // MediaStore delete error
            }
        }

        // 3. Fallback: Delete from MediaStore by file path
        if (!filePath.isNullOrEmpty() && !filePath.startsWith("content://")) {
            try {
                val rows = cr.delete(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    "${MediaStore.Audio.Media.DATA} = ?",
                    arrayOf(filePath)
                )
                if (rows > 0) deleted = true
            } catch (e: Exception) {
                // Ignore
            }

            // 4. Force MediaScannerConnection to rescan/evict from MediaStore
            try {
                MediaScannerConnection.scanFile(context, arrayOf(filePath), null, null)
            } catch (e: Exception) {
                // Ignore
            }
        }

        result.success(deleted)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == DELETE_PERMISSION_REQUEST_CODE) {
            val wasDeleted = (resultCode == Activity.RESULT_OK)
            pendingDeleteResult?.success(wasDeleted)
            pendingDeleteResult = null
        }
    }
}
