/*
 *    Copyright (c) 2012-2023 DSR Corporation, Denver CO, USA
 *
 *    Unless explicitly stated otherwise all files in this repository are licensed under the Apache License, Version 2.0
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    You may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.dsr_corporation.flutter_background_executor.runners

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.dsr_corporation.flutter_background_executor.constants.Definitions
import com.dsr_corporation.flutter_background_executor.utils.MessageUtils
import com.dsr_corporation.flutter_background_executor.utils.RunningTaskUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation

class FlutterEngineRunner(
    private val context: Context,
    private val callback: Long,
    private val taskIdentifier: String = Definitions.refreshTaskName,
    private val cancellable: Boolean = true,
    private val withMessages: Boolean = false,
) : MethodChannel.MethodCallHandler {
    private var engine: FlutterEngine? = null
    private var backgroundChannel: MethodChannel? = null
    private var onEndCallback: ((Boolean) -> Unit)? = null

    companion object {
        private val flutterLoader = FlutterLoader()
    }

    fun setOnEndCallback(callback: (Boolean) -> Unit) {
        onEndCallback = callback
    }

    fun run() {
        if (RunningTaskUtils.register(taskIdentifier)) {
            engine = FlutterEngine(context)

            if (!flutterLoader.initialized()) {
                flutterLoader.startInitialization(context)
            }
            flutterLoader.ensureInitializationCompleteAsync(
                /* applicationContext = */ context,
                /* args = */ null,
                /* callbackHandler = */ Handler(Looper.getMainLooper()),
                /* callback = */ ::executeEngine
            )
            if (cancellable) {
                RunningTaskUtils.addStopCallback(taskIdentifier) {
                    stop(true)
                }
            }
        }
    }

    private fun executeEngine() {
        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callback)
        val dartBundlePath = flutterLoader.findAppBundlePath()
        engine?.let { engine ->
            val methodChannelName = taskIdentifier.let { "$it${Definitions.backgroundMethodChannelSuffix}" }
            backgroundChannel = MethodChannel(engine.dartExecutor, methodChannelName)
            backgroundChannel?.setMethodCallHandler(this@FlutterEngineRunner)

            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    dartBundlePath,
                    callbackInfo.callbackLibraryPath,
                    callbackInfo.callbackName,
                ),
                listOf(withMessages.toString(), taskIdentifier)
            )
            if (withMessages) {
                MessageUtils.createEventChannel(
                    engine.dartExecutor.binaryMessenger,
                    taskIdentifier,
                )
            }
        }
    }

    private fun stop(isSuccess: Boolean) {
        RunningTaskUtils.removeStopCallback(taskIdentifier)
        RunningTaskUtils.unregister(taskIdentifier)
        Handler(Looper.getMainLooper()).post {
            engine?.destroy()
            engine = null
        }
        onEndCallback?.let { it(isSuccess) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            Definitions.backgroundTaskEndMethod -> {
                val isSuccess = call.argument<Boolean>(Definitions.isSuccessParam) ?: false
                stop(isSuccess)
                result.success(true)
            }
            Definitions.sendMessageMethod -> {
                MessageUtils.sendMessage(
                    call = call,
                    result = result,
                    from = taskIdentifier,
                )
            }
        }
    }
}