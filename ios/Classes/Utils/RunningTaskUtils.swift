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

import Foundation

typealias StopCallback = () -> ()
typealias StopCallbackKey = String
typealias RunningTaskKey = String

enum RunningTaskUtils {
    
    private static var stopTaskCallbacks: [StopCallbackKey : StopCallback] = [:]
    private static var runningTasks: Set<RunningTaskKey> = []
    
    static func stopAllExecuting(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if stopTaskCallbacks.isEmpty {
            result(false)
            return
        }
        for callback in stopTaskCallbacks {
            callback.value()
        }
        result(true)
    }
    
    static func stopExecuting(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let identifier = call.arguments as? String {
            if let task = stopTaskCallbacks[identifier] {
                task()
                result(true)
                return
            }
        }
        result(false)
    }
    
    static func register(task key: RunningTaskKey) {
        runningTasks.insert(key)
    }
    
    static func unregister(task key: RunningTaskKey) {
        runningTasks.remove(key)
    }
    
    static func hasRunningTasks(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(!runningTasks.isEmpty)
    }
    
    static func isRunning(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let identifier = call.arguments as? String {
            result(runningTasks.contains(identifier))
            return
        }
        result(false)
        
    }
    
    static func add(for key: StopCallbackKey, stopCallback callback: @escaping StopCallback) {
        stopTaskCallbacks[key] = callback
    }
    
    static func removeStopCallback(byKey key: StopCallbackKey) {
        stopTaskCallbacks[key] = nil
    }
    
}
