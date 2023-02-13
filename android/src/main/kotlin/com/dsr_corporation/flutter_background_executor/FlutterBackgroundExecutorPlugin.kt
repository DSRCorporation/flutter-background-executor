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



package com.dsr_corporation.flutter_background_executor

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import androidx.work.Constraints
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.dsr_corporation.flutter_background_executor.constants.DefaultValues
import com.dsr_corporation.flutter_background_executor.constants.Definitions
import com.dsr_corporation.flutter_background_executor.dtos.*
import com.dsr_corporation.flutter_background_executor.helpers.PreferencesHelper
import com.dsr_corporation.flutter_background_executor.runners.FlutterEngineRunner
import com.dsr_corporation.flutter_background_executor.utils.MessageUtils
import com.dsr_corporation.flutter_background_executor.utils.RunningTaskUtils
import com.dsr_corporation.flutter_background_executor.workers.FlutterBackgroundExecutorWorker
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.TimeUnit

/** FlutterBackgroundExecutorPlugin */
class FlutterBackgroundExecutorPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private lateinit var preferencesHelper: PreferencesHelper

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(context: Context, messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, Definitions.methodChannel)
        this.context = context
        preferencesHelper = PreferencesHelper(context)
        channel?.setMethodCallHandler(this)
        MessageUtils.createEventChannel(messenger)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Definitions.createRefreshTaskMethod -> createRefreshTask(call, result)
            Definitions.runImmediatelyBackgroundTaskMethod -> runImmediatelyBackgroundTask(call, result)
            Definitions.sendMessageMethod -> MessageUtils.sendMessage(call, result)
            Definitions.stopExecutingTasksMethod -> RunningTaskUtils.stopAllExecutingTasks(call, result)
            Definitions.stopExecutingTaskMethod -> RunningTaskUtils.stopExecutingTasks(call, result)
            Definitions.hasRunningTasksMethod -> RunningTaskUtils.hasRunningTasks(call, result)
            Definitions.isTaskRunningMethod -> RunningTaskUtils.isRunning(call, result)
            Definitions.cancelTaskMethod -> cancelTask(call, result)
            Definitions.cancelAllTasksMethod -> cancelAllTasks(call, result)
            else -> result.notImplemented()
        }
    }

    private fun createRefreshTask(call: MethodCall, result: MethodChannel.Result) {
        context?.let { context ->
            val request = parseCreateRefreshRequest(call)
            val details = request.details
            val oldDetails = restoreDetails()
            val id = if (details != oldDetails)
                createTask(request, context)
            else
                getCreatedTaskIdentifier(context)
            saveRefreshInfo(request)
            val response = CreateRefreshTaskResponse(true, id)
            result.success(response.toMap())
        } ?: result.success(CreateRefreshTaskResponse(false).toMap())
    }

    private fun getCreatedTaskIdentifier(context: Context): String {
        val workManager = WorkManager.getInstance(context)
        val tasks = workManager.getWorkInfosByTag(FlutterBackgroundExecutorWorker::class.java.name).get()
        return tasks.first().id.toString()
    }

    private fun createTask(request: CreateRefreshTaskRequest, context: Context): String {
        val details = request.details
        val workManager = WorkManager.getInstance(context)
        workManager.cancelAllWorkByTag(FlutterBackgroundExecutorWorker::class.java.name)
        val constraintsBuilder = Constraints.Builder()
            .setRequiredNetworkType(
                (details.requiredNetworkType ?: DefaultValues.requiredNetworkType).workerValue()
            )
            .setRequiresCharging(details.requiresCharging ?: DefaultValues.requiresCharging)
            .setRequiresBatteryNotLow(details.requiresBatteryNotLow ?: DefaultValues.requiresBatteryNotLow)
            .setRequiresStorageNotLow(details.requiresStorageNotLow ?: DefaultValues.requiresStorageNotLow)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            constraintsBuilder.setRequiresDeviceIdle(details.requiresDeviceIdle ?: DefaultValues.requiresDeviceIdle)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            details.minUpdateDelay?.let { delay ->
                constraintsBuilder.setTriggerContentUpdateDelay(
                    delay,
                    TimeUnit.MILLISECONDS
                )
            }
            details.maxUpdateDelay?.let { delay ->
                constraintsBuilder.setTriggerContentMaxDelay(
                    delay,
                    TimeUnit.MILLISECONDS
                )
            }
        }
        val constraints = constraintsBuilder.build()
        val requestBuilder = PeriodicWorkRequestBuilder<FlutterBackgroundExecutorWorker>(
            details.repeatInterval!!, TimeUnit.MILLISECONDS,
            (details.flexInterval ?: details.repeatInterval), TimeUnit.MILLISECONDS,
        ).setConstraints(constraints)
        details.initialDelay?.let { delay ->
            requestBuilder.setInitialDelay(delay, TimeUnit.MILLISECONDS)
        }
        val taskRequest = requestBuilder.build()
        workManager.enqueue(taskRequest)
        return taskRequest.id.toString()
    }

    private fun runImmediatelyBackgroundTask(call: MethodCall, result: MethodChannel.Result) {
        context?.let { context ->
            val request = parseImmediatelyTaskRequest(call)
            val runner = FlutterEngineRunner(
                context = context,
                callback = request.callback,
                taskIdentifier = request.taskIdentifier,
                cancellable = request.cancellable,
                withMessages = request.withMessages,
            )
            runner.run()
            result.success(true)
        } ?: result.success(false)
    }

    private fun cancelTask(call: MethodCall, result: MethodChannel.Result) {
        context?.let { context ->
            val workManager = WorkManager.getInstance(context)
            val request = parseCancelTaskRequest(call)
            workManager.cancelUniqueWork(request.taskIdentifier)
            clearDetails()
            result.success(true)
        }
    }

    private fun cancelAllTasks(call: MethodCall, result: MethodChannel.Result) {
        context?.let { context ->
            val workManager = WorkManager.getInstance(context)
            workManager.cancelAllWork()
            clearDetails()
            result.success(true)
        }
    }

    private fun parseCreateRefreshRequest(call: MethodCall): CreateRefreshTaskRequest {
        val detailsArgument = call.argument<Map<String, Any>>(Definitions.detailsParam)!!

        val details = AndroidRefreshTaskDetails(
            requiredNetworkType = createAndroidNetworkType(detailsArgument[Definitions.requiredNetworkTypeParam] as? Int),
            requiresCharging = detailsArgument[Definitions.requiresChargingParam] as? Boolean,
            requiresDeviceIdle = detailsArgument[Definitions.requiresDeviceIdleParam] as? Boolean,
            requiresBatteryNotLow = detailsArgument[Definitions.requiresBatteryNotLowParam] as? Boolean,
            requiresStorageNotLow = detailsArgument[Definitions.requiresStorageNotLowParam] as? Boolean,
            minUpdateDelay = (detailsArgument[Definitions.minUpdateDelayParam] as? Int)?.toLong(),
            maxUpdateDelay = (detailsArgument[Definitions.maxUpdateDelayParam] as? Int)?.toLong(),
            initialDelay = (detailsArgument[Definitions.initialDelayParam] as? Int)?.toLong(),
            repeatInterval = (detailsArgument[Definitions.repeatIntervalParam] as? Int)?.toLong(),
            flexInterval = (detailsArgument[Definitions.flexIntervalParam] as? Int)?.toLong(),
        )
        return CreateRefreshTaskRequest(
            callback = call.argument(Definitions.callbackParam)!!,
            details = details,
        )
    }

    private fun parseImmediatelyTaskRequest(call: MethodCall): ImmediatelyTaskRequest {
        return ImmediatelyTaskRequest(
            callback = call.argument(Definitions.callbackParam)!!,
            taskIdentifier = call.argument(Definitions.taskIdentifierParam)!!,
            cancellable = call.argument(Definitions.cancellableParam)!!,
            withMessages = call.argument(Definitions.withMessagesParam)!!,
        )
    }

    private fun restoreDetails(): AndroidRefreshTaskDetails = AndroidRefreshTaskDetails(
        requiredNetworkType = preferencesHelper.requiredNetworkType,
        requiresCharging = preferencesHelper.requiresCharging,
        requiresDeviceIdle = preferencesHelper.requiresDeviceIdle,
        requiresBatteryNotLow = preferencesHelper.requiresBatteryNotLow,
        requiresStorageNotLow = preferencesHelper.requiresStorageNotLow,
        minUpdateDelay = preferencesHelper.minUpdateDelay,
        maxUpdateDelay = preferencesHelper.maxUpdateDelay,
        initialDelay = preferencesHelper.initialDelay,
        repeatInterval = preferencesHelper.repeatInterval,
        flexInterval = preferencesHelper.flexInterval,
    )

    private fun saveRefreshInfo(request: CreateRefreshTaskRequest) {
        preferencesHelper.callback = request.callback
        saveDetails(request.details)
    }

    private fun saveDetails(details: AndroidRefreshTaskDetails) {
        preferencesHelper.requiredNetworkType = details.requiredNetworkType
        preferencesHelper.requiresCharging = details.requiresCharging
        preferencesHelper.requiresDeviceIdle = details.requiresDeviceIdle
        preferencesHelper.requiresBatteryNotLow = details.requiresBatteryNotLow
        preferencesHelper.requiresStorageNotLow = details.requiresStorageNotLow
        preferencesHelper.minUpdateDelay = details.minUpdateDelay
        preferencesHelper.maxUpdateDelay = details.maxUpdateDelay
        preferencesHelper.initialDelay = details.initialDelay
        preferencesHelper.repeatInterval = details.repeatInterval
        preferencesHelper.flexInterval = details.flexInterval
    }

    private fun clearDetails() {
        preferencesHelper.requiredNetworkType = null
        preferencesHelper.requiresCharging = null
        preferencesHelper.requiresDeviceIdle = null
        preferencesHelper.requiresBatteryNotLow = null
        preferencesHelper.requiresStorageNotLow = null
        preferencesHelper.minUpdateDelay = null
        preferencesHelper.maxUpdateDelay = null
        preferencesHelper.initialDelay = null
        preferencesHelper.repeatInterval = null
        preferencesHelper.flexInterval = null
    }

    private fun parseCancelTaskRequest(call: MethodCall): CancelRefreshTaskRequest {
        return CancelRefreshTaskRequest(
            taskIdentifier = call.argument(Definitions.taskIdentifierParam)!!,
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        onDetachedFromEngine()
    }

    private fun onDetachedFromEngine() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
