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

package com.dsr_corporation.flutter_background_executor.constants

object Definitions {
    const val methodChannel = "flutter_background_executor"
    const val backgroundMethodChannelSuffix = "_background_task_method_channel"
    const val backgroundEventChannelSuffix = "_background_task_event_channel"

    const val createRefreshTaskMethod = "createRefreshTaskMethod"
    const val runImmediatelyBackgroundTaskMethod = "runImmediatelyBackgroundTaskMethod"
    const val sendMessageMethod = "sendMessageMethod"
    const val backgroundTaskEndMethod = "backgroundTaskEndMethod"
    const val stopExecutingTasksMethod = "stopExecutingTasksMethod"
    const val stopExecutingTaskMethod = "stopExecutingTaskMethod"
    const val hasRunningTasksMethod = "hasRunningTasksMethod"
    const val isTaskRunningMethod = "isTaskRunningMethod"
    const val cancelTaskMethod = "cancelTaskMethod"
    const val cancelAllTasksMethod = "cancelAllTasksMethod"

    const val isSuccessParam = "isSuccessParam"
    const val taskIdentifierParam = "taskIdentifierParam"
    const val cancellableParam = "cancellableParam"
    const val withMessagesParam = "withMessagesParam"
    const val callbackParam = "callbackParam"
    const val detailsParam = "androidDetailsParam"
    const val requiredNetworkTypeParam = "requiredNetworkTypeParam"
    const val requiresChargingParam = "requiresChargingParam"
    const val requiresDeviceIdleParam = "requiresDeviceIdleParam"
    const val requiresBatteryNotLowParam = "requiresBatteryNotLowParam"
    const val requiresStorageNotLowParam = "requiresStorageNotLowParam"
    const val minUpdateDelayParam = "minUpdateDelayParam"
    const val maxUpdateDelayParam = "maxUpdateDelayParam"
    const val initialDelayParam = "initialDelayParam"
    const val repeatIntervalParam = "repeatIntervalParam"
    const val flexIntervalParam = "flexIntervalParam"
    const val toParam = "toParam"
    const val commonMessageParam = "commonMessageParam"
    const val fromParam = "fromParam"
    const val messageParam = "messageParam"

    const val mainTaskName = "main_application"
    const val refreshTaskName = "refresh_task"
}