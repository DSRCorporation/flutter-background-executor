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

import 'package:flutter_background_executor/src/constants/definitions.dart';
import 'package:flutter_background_executor/src/models/android_refresh_task_details.dart';
import 'package:flutter_background_executor/src/models/ios_refresh_task_details.dart';

extension AndroidRefreshDetailsMap on AndroidRefreshTaskDetails {
  Map<String, dynamic> toMap() => {
        Definitions.requiredNetworkTypeParam: requiredNetworkType.value,
        Definitions.requiresChargingParam: requiresCharging,
        Definitions.requiresDeviceIdleParam: requiresDeviceIdle,
        Definitions.requiresBatteryNotLowParam: requiresBatteryNotLow,
        Definitions.requiresStorageNotLowParam: requiresStorageNotLow,
        Definitions.minUpdateDelayParam: minUpdateDelay.inMilliseconds,
        Definitions.maxUpdateDelayParam: maxUpdateDelay.inMilliseconds,
        Definitions.initialDelayParam: initialDelay.inMilliseconds,
        Definitions.repeatIntervalParam: repeatInterval.inMilliseconds,
        Definitions.flexIntervalParam: flexInterval.inMilliseconds,
      };
}

extension IosRefreshDetailsMap on IosRefreshTaskDetails {
  Map<String, dynamic> toMap() => {
        Definitions.taskIdentifierParam: taskIdentifier,
        Definitions.taskDelayParam: taskDelay,
      };
}

extension AndroidNetworkTypeValue on AndroidNetworkType {
  int get value {
    switch (this) {
      case AndroidNetworkType.notRequired:
        return 1;
      case AndroidNetworkType.connected:
        return 2;
      case AndroidNetworkType.unmetered:
        return 3;
      case AndroidNetworkType.notRoaming:
        return 4;
      case AndroidNetworkType.metered:
        return 5;
    }
  }
}
