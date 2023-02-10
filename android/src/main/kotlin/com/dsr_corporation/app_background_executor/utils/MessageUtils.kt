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

package com.dsr_corporation.app_background_executor.utils

import com.dsr_corporation.app_background_executor.constants.Definitions
import com.dsr_corporation.app_background_executor.dtos.ForwardedMessage
import com.dsr_corporation.app_background_executor.dtos.ReceivedMessage
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object MessageUtils {
    private val eventChannels = hashMapOf<String, EventChannel.EventSink>()

    internal fun createEventChannel(messenger: BinaryMessenger, identifier: String = Definitions.mainTaskName) {
        if (eventChannels.containsKey(identifier)) {
            return
        }
        val channelName = "$identifier${Definitions.backgroundEventChannelSuffix}"
        EventChannel(messenger, channelName).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                events?.run {
                    eventChannels[identifier] = this
                }
            }

            override fun onCancel(arguments: Any?) {
                eventChannels.remove(identifier)
            }
        })
    }

    internal fun sendMessage(
        call: MethodCall,
        result: MethodChannel.Result,
        from: String = Definitions.mainTaskName,
    ) {
        val request = parseReceivedMessage(call)
        if (request.commonMessage) {
            for (pair in eventChannels) {
                if (pair.key != from) {
                    pair.value.success(ForwardedMessage(from = from, message = request.message).toMap())
                }
            }
            result.success(true)
        } else {
            eventChannels[request.to]?.run {
                this.success(ForwardedMessage(from = from, message = request.message).toMap())
                result.success(true)
            } ?: run {
                result.success(false)
            }
        }
    }

    private fun parseReceivedMessage(call: MethodCall): ReceivedMessage {
        return ReceivedMessage(
            to = call.argument(Definitions.toParam),
            commonMessage = call.argument(Definitions.commonMessageParam)!!,
            message = call.argument(Definitions.messageParam)!!,
        )
    }
}