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

package com.dsr_corporation.app_background_executor.constants

object PreferenceKeys {
    const val name = "com.dsr_corporation.app_background_executor.preferences"
    const val callbackKey = "callback_key"
    const val requiredNetworkType = "required_network_type"
    const val requiresCharging = "requires_charging"
    const val requiresDeviceIdle = "requires_device_idle"
    const val requiresBatteryNotLow = "requires_battery_not_low"
    const val requiresStorageNotLow = "requires_storage_not_low"
    const val minUpdateDelay = "min_update_delay"
    const val maxUpdateDelay = "max_update_delay"
    const val initialDelay = "initial_delay"
    const val repeatInterval = "repeat_interval"
    const val flexInterval = "flex_interval"
}