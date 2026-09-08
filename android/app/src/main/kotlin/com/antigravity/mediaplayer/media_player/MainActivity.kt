package com.antigravity.mediaplayer.media_player

import android.app.Activity
import android.content.ContentUris
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.antigravity.mediaplayer/device_audio"
    private var pendingDeleteResult: MethodChannel.Result? = null
    private var pendingPathsToScan: List<String>? = null
    private val DELETE_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteAudio" -> {
                    val filePath = call.argument<String>("path")
                    val trackId = call.argument<String>("id")
                    deleteAudioFiles(listOf(Pair(filePath, trackId)), result)
                }
                "deleteAudios" -> {
                    val items = parseItems(call.argument<Any>("items"))
                    deleteAudioFiles(items, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun parseItems(callArgument: Any?): List<Pair<String?, String?>> {
        val list = callArgument as? List<*> ?: return emptyList()
        return list.mapNotNull { element ->
            val map = element as? Map<*, *>
            if (map != null) {
                val path = map["path"] as? String
                val id = map["id"] as? String
                Pair(path, id)
            } else {
                null
            }
        }
    }

    private fun deleteAudioFiles(items: List<Pair<String?, String?>>, result: MethodChannel.Result) {
        if (items.isEmpty()) {
            result.success(true)
            return
        }

        val cr = contentResolver
        val urisToDelete = mutableListOf<Uri>()
        val pathsToScan = mutableListOf<String>()
        var atLeastOneDeleted = false

        // 1. Direct filesystem delete if available & collect URIs
        for ((filePath, trackId) in items) {
            if (!filePath.isNullOrEmpty() && !filePath.startsWith("content://")) {
                pathsToScan.add(filePath)
                try {
                    val file = File(filePath)
                    if (file.exists() && file.delete()) {
                        atLeastOneDeleted = true
                    }
                } catch (e: Exception) {
                    // Direct file delete may fail due to scoped storage; proceed to MediaStore
                }
            }

            val id = trackId?.toLongOrNull()
            val uri: Uri? = when {
                id != null -> ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
                !filePath.isNullOrEmpty() && filePath.startsWith("content://") -> Uri.parse(filePath)
                else -> null
            }
            if (uri != null) {
                urisToDelete.add(uri)
            }
        }

        // 2. Android 11+ (API 30+): MediaStore.createDeleteRequest handles ALL URIs in 1 single system dialog
        if (urisToDelete.isNotEmpty()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                try {
                    val deleteRequest = MediaStore.createDeleteRequest(cr, urisToDelete)
                    pendingDeleteResult = result
                    pendingPathsToScan = pathsToScan
                    startIntentSenderForResult(
                        deleteRequest.intentSender,
                        DELETE_PERMISSION_REQUEST_CODE,
                        null, 0, 0, 0
                    )
                    return
                } catch (e: Exception) {
                    // Fallback to individual cr.delete
                }
            }

            // Android < 11 or fallback: delete via ContentResolver
            for (uri in urisToDelete) {
                try {
                    val rows = cr.delete(uri, null, null)
                    if (rows > 0) atLeastOneDeleted = true
                } catch (se: SecurityException) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val recoverable = se as? android.app.RecoverableSecurityException
                        if (recoverable != null && pendingDeleteResult == null) {
                            pendingDeleteResult = result
                            pendingPathsToScan = pathsToScan
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
        }

        // 3. Fallback: Delete from MediaStore by file path
        for (path in pathsToScan) {
            try {
                val rows = cr.delete(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    "${MediaStore.Audio.Media.DATA} = ?",
                    arrayOf(path)
                )
                if (rows > 0) atLeastOneDeleted = true
            } catch (e: Exception) {
                // Ignore
            }
        }

        // 4. Force MediaScannerConnection to rescan/evict from MediaStore
        if (pathsToScan.isNotEmpty()) {
            try {
                MediaScannerConnection.scanFile(context, pathsToScan.toTypedArray(), null, null)
            } catch (e: Exception) {
                // Ignore
            }
        }

        result.success(atLeastOneDeleted)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == DELETE_PERMISSION_REQUEST_CODE) {
            val wasDeleted = (resultCode == Activity.RESULT_OK)
            val paths = pendingPathsToScan
            if (paths != null && paths.isNotEmpty()) {
                try {
                    MediaScannerConnection.scanFile(context, paths.toTypedArray(), null, null)
                } catch (e: Exception) {
                    // Ignore
                }
            }
            pendingPathsToScan = null
            pendingDeleteResult?.success(wasDeleted)
            pendingDeleteResult = null
        }
    }
}
