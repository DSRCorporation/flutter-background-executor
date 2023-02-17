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

abstract class Definitions {
  static const methodChannel = 'flutter_background_executor';
  static const backgroundMethodChannelSuffix =
      '_background_task_method_channel';
  static const backgroundEventChannelSuffix = '_background_task_event_channel';

  static const createRefreshTaskMethod = 'createRefreshTaskMethod';
  static const runImmediatelyBackgroundTaskMethod =
      'runImmediatelyBackgroundTaskMethod';
  static const stopExecutingTasksMethod = 'stopExecutingTasksMethod';
  static const stopExecutingTaskMethod = 'stopExecutingTaskMethod';
  static const hasRunningTasksMethod = 'hasRunningTasksMethod';
  static const isTaskRunningMethod = 'isTaskRunningMethod';
  static const backgroundTaskEndMethod = 'backgroundTaskEndMethod';
  static const sendMessageMethod = 'sendMessageMethod';
  static const cancelTaskMethod = 'cancelTaskMethod';
  static const cancelAllTasksMethod = 'cancelAllTasksMethod';

  static const isSuccessParam = 'isSuccessParam';
  static const taskIdentifierParam = 'taskIdentifierParam';
  static const callbackParam = 'callbackParam';
  static const cancellableParam = 'cancellableParam';
  static const withMessagesParam = 'withMessagesParam';
  static const androidDetailsParam = 'androidDetailsParam';
  static const iosDetailsParam = 'iosDetailsParam';
  static const taskDelayParam = 'taskDelayParam';
  static const requiredNetworkTypeParam = 'requiredNetworkTypeParam';
  static const requiresChargingParam = 'requiresChargingParam';
  static const requiresDeviceIdleParam = 'requiresDeviceIdleParam';
  static const requiresBatteryNotLowParam = 'requiresBatteryNotLowParam';
  static const requiresStorageNotLowParam = 'requiresStorageNotLowParam';
  static const minUpdateDelayParam = 'minUpdateDelayParam';
  static const maxUpdateDelayParam = 'maxUpdateDelayParam';
  static const initialDelayParam = 'initialDelayParam';
  static const repeatIntervalParam = 'repeatIntervalParam';
  static const flexIntervalParam = 'flexIntervalParam';
  static const toParam = 'toParam';
  static const commonMessageParam = 'commonMessageParam';
  static const fromParam = 'fromParam';
  static const messageParam = 'messageParam';
}
