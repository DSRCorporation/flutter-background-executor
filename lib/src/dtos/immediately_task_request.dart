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

class ImmediatelyTaskRequest {
  final CallbackHandle callback;
  final String taskIdentifier;
  final bool cancellable;
  final bool withMessages;

  ImmediatelyTaskRequest({
    required this.callback,
    required this.taskIdentifier,
    required this.cancellable,
    required this.withMessages,
  });

  ImmediatelyTaskRequest.from({
    required Function callback,
    required this.taskIdentifier,
    required this.cancellable,
    required this.withMessages,
  }) : callback = PluginUtilities.getCallbackHandle(callback)!;

  Map<String, dynamic> toMap() => {
        Definitions.callbackParam: callback.toRawHandle(),
        Definitions.taskIdentifierParam: taskIdentifier,
        Definitions.cancellableParam: cancellable,
        Definitions.withMessagesParam: withMessages,
      };
}
