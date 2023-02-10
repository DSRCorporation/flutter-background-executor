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

import 'dart:ui';

import 'package:app_background_executor/src/constants/definitions.dart';
import 'package:app_background_executor/src/constants/errors.dart';
import 'package:app_background_executor/src/constants/tasks.dart';
import 'package:app_background_executor/src/dtos/cancel_task_request.dart';
import 'package:app_background_executor/src/dtos/create_refresh_task_request.dart';
import 'package:app_background_executor/src/dtos/create_refresh_task_response.dart';
import 'package:app_background_executor/src/dtos/immediately_task_request.dart';
import 'package:app_background_executor/src/extension/stream_ext.dart';
import 'package:app_background_executor/src/models/create_immediately_task_result.dart';
import 'package:app_background_executor/src/models/engine_connector.dart';
import 'package:app_background_executor/src/models/error_background_executor.dart';
import 'package:app_background_executor/src/models/received_message.dart';
import 'package:app_background_executor/src/models/refresh_task_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBackgroundExecutor {
  final methodChannel = const MethodChannel(Definitions.methodChannel);

  Future<String?> createRefreshTask({
    required Function callback,
    RefreshTaskSettings? settings,
  }) async {
    final refreshSettings = settings ?? RefreshTaskSettings();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(Tasks.refreshTask, PluginUtilities.getCallbackHandle(callback)!.toRawHandle());

    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      Definitions.createRefreshTaskMethod,
      CreateRefreshTaskRequest.from(
        callback: runTask,
        refreshSettings: refreshSettings,
      ).toMap(),
    );

    if (result == null) {
      throw ErrorBackgroundExecutor(ErrorDescriptions.unsuccessfulCreate);
    }
    final response = CreateRefreshTaskResponse.fromMap(result);
    if (response.isSuccess) return response.taskIdentifier!;
    throw ErrorBackgroundExecutor(ErrorDescriptions.unsuccessfulCreate);
  }

// todo need return connector with identifier
  Future<CreateImmediatelyBackgroundTaskResult> runImmediatelyBackgroundTask({
    required Function callback,
    String taskIdentifier = Tasks.defaultBackground,
    String currentTaskIdentifier = Tasks.mainApplication, // need to change if create from background task
    bool cancellable = true,
    bool withMessages = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(taskIdentifier, PluginUtilities.getCallbackHandle(callback)!.toRawHandle());

    final result = await methodChannel.invokeMethod<bool>(
      Definitions.runImmediatelyBackgroundTaskMethod,
      ImmediatelyTaskRequest.from(
        callback: runTask,
        taskIdentifier: taskIdentifier,
        cancellable: cancellable,
        withMessages: withMessages,
      ).toMap(),
    );

    if (result == null || !result) {
      throw ErrorBackgroundExecutor(ErrorDescriptions.unsuccessfulCreate);
    }
    if (!withMessages) return CreateImmediatelyBackgroundTaskResult(taskIdentifier);
    final eventChannel = EventChannel('$currentTaskIdentifier${Definitions.backgroundEventChannelSuffix}');
    return CreateImmediatelyBackgroundTaskResult(
      taskIdentifier,
      _createEngineConnector(
        currentTaskIdentifier: currentTaskIdentifier,
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );
  }

  Future<bool> cancelTask({required String identifier}) async {
    final request = CancelTaskRequest(taskIdentifier: identifier);
    return await methodChannel.invokeMethod(Definitions.cancelTaskMethod, request.toMap());
  }

  Future<bool> cancelAllTasks() async {
    return await methodChannel.invokeMethod(Definitions.cancelAllTasksMethod);
  }

  Future<bool> stopAllExecutingTasks() async {
    return await methodChannel.invokeMethod(Definitions.stopExecutingTasksMethod);
  }

  Future<bool> stopExecutingTask([String identifier = Tasks.defaultBackground]) async {
    return await methodChannel.invokeMethod(Definitions.stopExecutingTaskMethod, identifier);
  }

  Future<bool> stopRefreshTask() async {
    return await methodChannel.invokeMethod(Definitions.stopExecutingTaskMethod, Tasks.refreshTask);
  }

  Future<bool> hasRunningTasks() async {
    return await methodChannel.invokeMethod(Definitions.hasRunningTasksMethod);
  }

  Future<bool> isTaskRunning([String identifier = Tasks.defaultBackground]) async {
    return await methodChannel.invokeMethod(Definitions.isTaskRunningMethod, identifier);
  }

  Future<bool> isRefreshTaskRunning() async {
    return await methodChannel.invokeMethod(Definitions.isTaskRunningMethod, Tasks.refreshTask);
  }

  EngineConnector createConnector({String currentTaskIdentifier = Tasks.mainApplication}) {
    final eventChannel = EventChannel('$currentTaskIdentifier${Definitions.backgroundEventChannelSuffix}');
    final methodChannel = currentTaskIdentifier == Tasks.mainApplication
        ? this.methodChannel
        : MethodChannel('$currentTaskIdentifier${Definitions.backgroundMethodChannelSuffix}');
    return _createEngineConnector(
      currentTaskIdentifier: currentTaskIdentifier,
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );
  }
}

@pragma('vm:entry-point')
Future<void> runTask(List<String>? arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String methodChannelName;
  final String? eventChannelName;
  final String taskIdentifier;
  if (arguments != null && arguments.isNotEmpty) {
    if (arguments.length > 1) {
      taskIdentifier = arguments[1];
      methodChannelName = "$taskIdentifier${Definitions.backgroundMethodChannelSuffix}";
    } else {
      taskIdentifier = Tasks.refreshTask;
      methodChannelName = taskIdentifier;
    }
    if (arguments[0] == "true") {
      eventChannelName = "$taskIdentifier${Definitions.backgroundEventChannelSuffix}";
    } else {
      eventChannelName = null;
    }
  } else {
    taskIdentifier = Tasks.refreshTask;
    methodChannelName = taskIdentifier;
    eventChannelName = null;
  }
  final methodChannel = MethodChannel(methodChannelName);
  try {
    final call = prefs.getInt(taskIdentifier)!;
    final callback = CallbackHandle.fromRawHandle(call);
    final func = PluginUtilities.getCallbackFromHandle(callback)!;
    if (eventChannelName != null && func is Function(EngineConnector)) {
      final eventChannel = EventChannel(eventChannelName);
      final connector = _createEngineConnector(
        currentTaskIdentifier: taskIdentifier,
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );
      await func(connector);
    } else {
      if (func is Function(EngineConnector?)) {
        await func(null);
      } else {
        await func();
      }
    }

    await methodChannel.invokeMethod(Definitions.backgroundTaskEndMethod, {Definitions.isSuccessParam: true});
  } catch (e) {
    await methodChannel.invokeMethod(Definitions.backgroundTaskEndMethod, {Definitions.isSuccessParam: false});
  }
}

EngineConnector _createEngineConnector({
  required String currentTaskIdentifier,
  required MethodChannel methodChannel,
  required EventChannel eventChannel,
}) {
  return EngineConnector(
    currentTaskIdentifier: currentTaskIdentifier,
    messageStream: eventChannel.receiveBroadcastStream().mapWhereType<Map, ReceivedMessage>(ReceivedMessage.from),
    messageSender: ({
      String? to,
      bool commonMessage = false,
      required String message,
    }) async {
      final result = await methodChannel.invokeMethod<bool>(
        Definitions.sendMessageMethod,
        {
          Definitions.toParam: to,
          Definitions.commonMessageParam: commonMessage,
          Definitions.messageParam: message,
        },
      );
      return result ?? false;
    },
  );
}
