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

import Foundation

enum Definitions {
    static let methodChannel = "flutter_background_executor"
    static let backgroundMethodChannelSuffix = "_background_task_method_channel"
    static let backgroundEventChannelSuffix = "_background_task_event_channel"
    
    static let backgroundEngineName = "background_executor_background_engine"
    
    static let createRefreshTaskMethod = "createRefreshTaskMethod"
    static let runImmediatelyBackgroundTaskMethod = "runImmediatelyBackgroundTaskMethod"
    static let sendMessageMethod = "sendMessageMethod"
    static let stopExecutingTasksMethod = "stopExecutingTasksMethod"
    static let stopExecutingTaskMethod = "stopExecutingTaskMethod"
    static let hasRunningTasksMethod = "hasRunningTasksMethod"
    static let isTaskRunningMethod = "isTaskRunningMethod"
    static let backgroundTaskEndMethod = "backgroundTaskEndMethod"
    static let cancelTaskMethod = "cancelTaskMethod"
    static let cancelAllTasksMethod = "cancelAllTasksMethod"
    
    static let mainTaskName = "main_application"
    static let refreshTaskName = "refresh_task"
}
