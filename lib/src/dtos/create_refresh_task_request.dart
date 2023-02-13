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

import 'package:flutter_background_executor/src/constants/definitions.dart';
import 'package:flutter_background_executor/src/extension/models_to_map.dart';
import 'package:flutter_background_executor/src/models/android_refresh_task_details.dart';
import 'package:flutter_background_executor/src/models/refresh_task_settings.dart';
import 'package:flutter_background_executor/src/models/ios_refresh_task_details.dart';

class CreateRefreshTaskRequest {
  final CallbackHandle callback;
  final AndroidRefreshTaskDetails? androidDetails;
  final IosRefreshTaskDetails? iosDetails;

  CreateRefreshTaskRequest({
    required this.callback,
    this.androidDetails,
    this.iosDetails,
  });

  CreateRefreshTaskRequest.from({
    required Function callback,
    required RefreshTaskSettings refreshSettings,
  })  : callback = PluginUtilities.getCallbackHandle(callback)!,
        androidDetails = refreshSettings.androidDetails,
        iosDetails = refreshSettings.iosDetails;

  Map<String, dynamic> toMap() => {
        Definitions.callbackParam: callback.toRawHandle(),
        if (androidDetails != null) Definitions.androidDetailsParam: androidDetails?.toMap(),
        if (iosDetails != null) Definitions.iosDetailsParam: iosDetails?.toMap(),
      };
}
