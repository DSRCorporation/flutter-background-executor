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

const _minUpdateDelay = Duration(minutes: 15);
const _maxUpdateDelay = Duration(hours: 1);
const _initialDelay = Duration(minutes: 3);
const _repeatInterval = Duration(minutes: 15);
const _flexInterval = Duration(minutes: 15);

class AndroidRefreshTaskDetails {
  final AndroidNetworkType requiredNetworkType;
  final bool requiresCharging;
  final bool requiresDeviceIdle;
  final bool requiresBatteryNotLow;
  final bool requiresStorageNotLow;
  final Duration minUpdateDelay;
  final Duration maxUpdateDelay;
  final Duration initialDelay;
  final Duration repeatInterval;
  final Duration flexInterval;

  AndroidRefreshTaskDetails({
    this.requiredNetworkType = AndroidNetworkType.notRequired,
    this.requiresCharging = false,
    this.requiresDeviceIdle = false,
    this.requiresBatteryNotLow = false,
    this.requiresStorageNotLow = false,
    this.minUpdateDelay = _minUpdateDelay,
    this.maxUpdateDelay = _maxUpdateDelay,
    this.initialDelay = _initialDelay,
    this.repeatInterval = _repeatInterval,
    this.flexInterval = _flexInterval,
  });
}

enum AndroidNetworkType {
  /// A network is not required for this work.
  notRequired,

  /// Any working network connection is required for this work.
  connected,

  /// An unmetered network connection is required for this work.
  unmetered,

  /// A non-roaming network connection is required for this work.
  notRoaming,

  /// A metered network connection is required for this work.
  metered,
}
