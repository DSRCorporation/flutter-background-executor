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

package com.dsr_corporation.app_background_executor.helpers

import android.content.Context
import com.dsr_corporation.app_background_executor.constants.PreferenceKeys
import com.dsr_corporation.app_background_executor.dtos.AndroidNetworkType

class PreferencesHelper(context: Context) {
    private val sharedPreferences =
        context.getSharedPreferences(PreferenceKeys.name, Context.MODE_PRIVATE)

    var requiredNetworkType: AndroidNetworkType?
        set(value) = setAndroidNetworkType(PreferenceKeys.requiredNetworkType, value)
        get() = getAndroidNetworkType(PreferenceKeys.requiredNetworkType)

    var requiresCharging: Boolean?
        set(value) = setBoolean(PreferenceKeys.requiresCharging, value)
        get() = getBoolean(PreferenceKeys.requiresCharging)

    var requiresDeviceIdle: Boolean?
        set(value) = setBoolean(PreferenceKeys.requiresDeviceIdle, value)
        get() = getBoolean(PreferenceKeys.requiresDeviceIdle)

    var requiresBatteryNotLow: Boolean?
        set(value) = setBoolean(PreferenceKeys.requiresBatteryNotLow, value)
        get() = getBoolean(PreferenceKeys.requiresBatteryNotLow)

    var requiresStorageNotLow: Boolean?
        set(value) = setBoolean(PreferenceKeys.requiresStorageNotLow, value)
        get() = getBoolean(PreferenceKeys.requiresStorageNotLow)

    var minUpdateDelay: Long?
        set(value) = setLong(PreferenceKeys.minUpdateDelay, value)
        get() = getLong(PreferenceKeys.minUpdateDelay)

    var maxUpdateDelay: Long?
        set(value) = setLong(PreferenceKeys.maxUpdateDelay, value)
        get() = getLong(PreferenceKeys.maxUpdateDelay)

    var initialDelay: Long?
        set(value) = setLong(PreferenceKeys.initialDelay, value)
        get() = getLong(PreferenceKeys.initialDelay)

    var repeatInterval: Long?
        set(value) = setLong(PreferenceKeys.repeatInterval, value)
        get() = getLong(PreferenceKeys.repeatInterval)

    var flexInterval: Long?
        set(value) = setLong(PreferenceKeys.flexInterval, value)
        get() = getLong(PreferenceKeys.flexInterval)

    var callback: Long?
        set(value) = setLong(PreferenceKeys.callbackKey, value)
        get() = getLong(PreferenceKeys.callbackKey)

    private fun getLong(key: String) =
        takeIf { sharedPreferences.contains(key) }?.let { sharedPreferences.getLong(key, 0L) }

    private fun setLong(key: String, value: Long?) = value?.let {
        sharedPreferences.edit().putLong(key, value).apply()
    } ?: run {
        sharedPreferences.edit().remove(key).apply()
    }

    private fun getBoolean(key: String) =
        takeIf { sharedPreferences.contains(key) }?.let { sharedPreferences.getBoolean(key, false) }

    private fun setBoolean(key: String, value: Boolean?) = value?.let {
        sharedPreferences.edit().putBoolean(key, value).apply()
    } ?: run {
        sharedPreferences.edit().remove(key).apply()
    }

    private fun getAndroidNetworkType(key: String) =
        takeIf { sharedPreferences.contains(key) }
            ?.let { sharedPreferences.getInt(key, 0) }
            ?.let { AndroidNetworkType.values()[it] }

    private fun setAndroidNetworkType(key: String, value: AndroidNetworkType?) =
        value?.let {
            sharedPreferences.edit().putInt(key, value.ordinal).apply()
        } ?: run {
            sharedPreferences.edit().remove(key).apply()
        }
}