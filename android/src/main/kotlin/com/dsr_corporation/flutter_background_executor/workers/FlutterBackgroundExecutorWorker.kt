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

package com.dsr_corporation.flutter_background_executor.workers

import android.annotation.SuppressLint
import android.content.Context
import androidx.concurrent.futures.ResolvableFuture
import androidx.work.ListenableWorker
import androidx.work.WorkerParameters
import com.dsr_corporation.flutter_background_executor.helpers.PreferencesHelper
import com.dsr_corporation.flutter_background_executor.runners.FlutterEngineRunner
import com.google.common.util.concurrent.ListenableFuture

@SuppressLint("RestrictedApi")
class FlutterBackgroundExecutorWorker(appContext: Context, workerParams: WorkerParameters) :
    ListenableWorker(appContext, workerParams) {

    private var startTime: Long = 0
    private val resolvableFuture = ResolvableFuture.create<Result>()
    private var preferencesHelper = PreferencesHelper(appContext)
    private var runner: FlutterEngineRunner? = null

    override fun startWork(): ListenableFuture<Result> {
        startTime = System.currentTimeMillis()
        val callback = preferencesHelper.callback ?: return resolvableFuture.apply { set(Result.retry()) }
        runner = FlutterEngineRunner(applicationContext, callback)
        runner?.setOnEndCallback { stopEngine(if (it) Result.success() else Result.retry()) }
        runner?.run()
        return resolvableFuture
    }

    override fun onStopped() {
        stopEngine(null)
    }

    private fun stopEngine(result: Result?) {
        if (result != null) {
            resolvableFuture.set(result)
        }
        runner = null
    }

}