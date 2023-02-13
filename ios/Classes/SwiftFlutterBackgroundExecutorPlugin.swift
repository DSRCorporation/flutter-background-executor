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

import Flutter
import UIKit
import BackgroundTasks

public class SwiftFlutterBackgroundExecutorPlugin: NSObject, FlutterPlugin {
    @UserDefault(.refreshTaskKey)
    public static var refreshTask: String = .refreshTaskDefault
    @UserDefault(.createdRefreshTaskKey)
    private var createdRefreshTask: String?
    @UserDefault(.taskDelayKey)
    private var taskDelay: Double = 10.0
    @UserDefault(.callbackKey)
    private var callback: Int64?
    private var needCreateTaskRequest: Bool {
        get {
            SwiftFlutterBackgroundExecutorPlugin.flutterPluginRegistrantCallback == nil
        }
    }
    private static var instance: SwiftFlutterBackgroundExecutorPlugin?
    
    private static var flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Definitions.methodChannel, binaryMessenger: registrar.messenger())
        instance = SwiftFlutterBackgroundExecutorPlugin()
        registrar.addMethodCallDelegate(instance!, channel: channel)
        MessageUtils.createEventChannel(with: registrar.messenger())
    }
    
    public static func setPluginRegistrantCallback(_ callback: @escaping FlutterPluginRegistrantCallback) {
        instance?.createTaskIfNeeded()
        flutterPluginRegistrantCallback = callback
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case Definitions.createRefreshTaskMethod:
            createRefreshTask(call, result: result)
            break
        case Definitions.runImmediatelyBackgroundTaskMethod:
            runImmediatelyBackgroundTask(call, result: result)
            break
        case Definitions.sendMessageMethod:
            MessageUtils.sendMessage(call, result: result)
            break
        case Definitions.cancelTaskMethod:
            cancelTask(call, result: result)
            break
        case Definitions.cancelAllTasksMethod:
            cancelAllTasks(call, result: result)
            break
        case Definitions.stopExecutingTasksMethod:
            RunningTaskUtils.stopAllExecuting(call, result: result)
            break
        case Definitions.stopExecutingTaskMethod:
            RunningTaskUtils.stopExecuting(call, result: result)
            break
        case Definitions.hasRunningTasksMethod:
            RunningTaskUtils.hasRunningTasks(call, result: result)
            break
        case Definitions.isTaskRunningMethod:
            RunningTaskUtils.isRunning(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    private func createRefreshTask(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let request = parseCreateRefreshTaskRequest(from: call.arguments as! [String: Any])
        callback = request.callback
        if createdRefreshTask != request.details.taskIdentifier {
            SwiftFlutterBackgroundExecutorPlugin.refreshTask = request.details.taskIdentifier
            taskDelay = request.details.taskDelay
        }
        let response = CreateRefreshTaskResponse(isSuccess: true, taskIdentifier: SwiftFlutterBackgroundExecutorPlugin.refreshTask)
        let encoder = JSONEncoder()
        let json = try! JSONSerialization.jsonObject(with: encoder.encode(response)) as? [String : Any]
        result(json)
    }
    
    private func runImmediatelyBackgroundTask(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let request = parseImmediatelyTaskRequest(from: call.arguments as! [String: Any])
            FlutterEngineRunner(
                flutterPluginRegistrantCallback: SwiftFlutterBackgroundExecutorPlugin.flutterPluginRegistrantCallback,
                identifier: request.taskIdentifier,
                supportCancel: request.cancellable,
                withMessages: request.withMessages
            ).run(operation: request.callback) {
            }
        
        result(true)
    }
    
    private func cancelTask(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let request = parseCancelTaskRequest(from: call.arguments as! [String: Any])
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: request.taskIdentifier)
            result(true)
        } else {
            result(false)
        }
    }
    
    private func cancelAllTasks(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            result(true)
        } else {
            result(false)
        }
    }
    
    private func createTaskIfNeeded() {
        if needCreateTaskRequest {
            if createBackgroundTask(for: SwiftFlutterBackgroundExecutorPlugin.refreshTask) {
                createdRefreshTask = SwiftFlutterBackgroundExecutorPlugin.refreshTask
            }
        } else {
            if #available(iOS 13, *) {
                scheduleAppRefreshTask(for: SwiftFlutterBackgroundExecutorPlugin.refreshTask)
            }
        }
    }
    
    
    private func createBackgroundTask(for taskIdentifier: String) -> Bool {
        guard !taskIdentifier.isEmpty else {
            return false
        }
        if #available(iOS 13.0, *) {
            let isRegistered = BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: DispatchQueue.global()) { (task) in
                if let callback = self.callback {
                    let queue = OperationQueue()
                    queue.maxConcurrentOperationCount = 1
                    let appRefreshTaskOperation = AppRefreshTaskOperation(callback: callback, flutterPluginRegistrantCallback: SwiftFlutterBackgroundExecutorPlugin.flutterPluginRegistrantCallback)
                    queue.addOperation(appRefreshTaskOperation)
                    
                    task.expirationHandler = {
                        queue.cancelAllOperations()
                    }
                    let lastOperation = queue.operations.last
                    lastOperation?.completionBlock = { [self] in
                        task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
                        self.createTaskIfNeeded()
                    }
                } else {
                    task.setTaskCompleted(success: true)
                }
            }
            if !isRegistered {
                return false
            }
            return scheduleAppRefreshTask(for: taskIdentifier)
        } else {
            return false
        }
    }
    
    
    @available(iOS 13, *)
    @discardableResult
    private func scheduleAppRefreshTask(for taskIdentifier: String) -> Bool{
        do {
            let backgroundAppRefreshTaskTaskRequest = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            backgroundAppRefreshTaskTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: taskDelay)
            try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskTaskRequest)
            return true
        } catch {
            return false
        }
        
    }
    
    private func parseCreateRefreshTaskRequest(from arguments: [String: Any]) -> CreateRefreshTaskRequest {
        let jsonData = try! JSONSerialization.data(withJSONObject: arguments, options: .prettyPrinted)
        return try! JSONDecoder().decode(CreateRefreshTaskRequest.self, from: jsonData)
    }
    
    private func parseImmediatelyTaskRequest(from arguments: [String: Any]) -> ImmediatelyTaskRequest {
        let jsonData = try! JSONSerialization.data(withJSONObject: arguments, options: .prettyPrinted)
        return try! JSONDecoder().decode(ImmediatelyTaskRequest.self, from: jsonData)
    }
    
    private func parseCancelTaskRequest(from arguments: [String: Any]) -> CancelRefreshTaskRequest {
        let jsonData = try! JSONSerialization.data(withJSONObject: arguments, options: .prettyPrinted)
        return try! JSONDecoder().decode(CancelRefreshTaskRequest.self, from: jsonData)
    }
}
