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

class FlutterEngineRunner {
    let flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    let identifier: String
    let supportCancel: Bool
    let withMessages: Bool
    
    init(
        flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?,
        identifier: String? = nil,
        supportCancel: Bool = true,
        withMessages: Bool = false
    ) {
        self.flutterPluginRegistrantCallback = flutterPluginRegistrantCallback
        self.identifier = identifier ?? Definitions.refreshTaskName
        self.supportCancel = supportCancel
        self.withMessages = withMessages
    }
    
    func run(operation: Int64, _ completion: @escaping () -> Void) {
        guard let callbackInfo = FlutterCallbackCache.lookupCallbackInformation(operation), RunningTaskUtils.register(task: identifier) else {
            completion()
            return
        }
        
        var flutterEngine: FlutterEngine? = FlutterEngine(
            name: Definitions.backgroundEngineName,
            project: nil,
            allowHeadlessExecution: true
        )
        let backgroundMethodChannelName: String
        backgroundMethodChannelName = "\(identifier)\(Definitions.backgroundMethodChannelSuffix)"
        flutterEngine!.run(
            withEntrypoint: callbackInfo.callbackName,
            libraryURI: callbackInfo.callbackLibraryPath,
            initialRoute: nil,
            entrypointArgs: [String(withMessages), identifier]
        )
        flutterPluginRegistrantCallback?(flutterEngine!)
        
        var backgroundMethodChannel: FlutterMethodChannel? = FlutterMethodChannel(
            name: backgroundMethodChannelName,
            binaryMessenger: flutterEngine!.binaryMessenger
        )
        func stopTask() {
            RunningTaskUtils.unregister(task: identifier)
            RunningTaskUtils.removeStopCallback(byKey: identifier)
            cleanupFlutterResources()
            completion()
        }
        if supportCancel {
            RunningTaskUtils.add(for: identifier, stopCallback: stopTask)
        }
        func cleanupFlutterResources() {
            flutterEngine?.destroyContext()
            backgroundMethodChannel = nil
            flutterEngine = nil
        }
        backgroundMethodChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case Definitions.backgroundTaskEndMethod:
                stopTask()
            case Definitions.sendMessageMethod:
                MessageUtils.sendMessage(call, result: result, from: self?.identifier ?? Definitions.refreshTaskName)
            default:
                break
            }
        }
        if withMessages {
            MessageUtils.createEventChannel(for: identifier, with: flutterEngine!.binaryMessenger)
        }
    }
    
}
