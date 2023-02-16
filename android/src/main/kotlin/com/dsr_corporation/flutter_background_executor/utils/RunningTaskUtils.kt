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

package com.dsr_corporation.flutter_background_executor.utils

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


typealias StopCallback = () -> Unit
typealias StopCallbackKey = String
typealias RunningTaskKey = String

object RunningTaskUtils {
    private val callbacks = hashMapOf<StopCallbackKey, StopCallback>()
    private val runningTasks = mutableSetOf<RunningTaskKey>()

    internal fun addStopCallback(key: String, callback: StopCallback) {
        callbacks[key] = callback
    }

    internal fun removeStopCallback(key: StopCallbackKey) {
        callbacks.remove(key)
    }

    internal fun stopAllExecutingTasks(call: MethodCall, result: MethodChannel.Result) {
        if (callbacks.isEmpty()) {
            result.success(false)
            return
        }
        for (callback in callbacks) {
            callback.value()
        }
        result.success(true)
    }

    internal fun stopExecutingTasks(call: MethodCall, result: MethodChannel.Result) {
        (call.arguments as? String)?.let { key ->
            callbacks[key]?.let { task ->
                task()
                result.success(true)
            }
        } ?: run {
            result.success(false)
        }
    }

    internal fun register(key: RunningTaskKey): Boolean = runningTasks.add(key)

    internal fun unregister(key: RunningTaskKey) {
        runningTasks.remove(key)
    }

    internal fun hasRunningTasks(call: MethodCall, result: MethodChannel.Result) {
        result.success(runningTasks.isNotEmpty())
    }

    internal fun isRunning(call: MethodCall, result: MethodChannel.Result) {
        (call.arguments as? String)?.let { key ->
            result.success(runningTasks.contains(key))
        } ?: run {
            result.success(false)
        }
    }
}