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

enum MessageUtils {
    private static var eventChannels: [String: FlutterEventSink] = [:]
    private static var keys: Set<String> = []
    
    static func createEventChannel(for identifier: String = Definitions.mainTaskName, with messenger: FlutterBinaryMessenger) {
        if keys.contains(identifier) {
            return;
        }
        keys.insert(identifier)
        let channelName = "\(identifier)\(Definitions.backgroundEventChannelSuffix)"
        FlutterEventChannel(name: channelName, binaryMessenger: messenger).setStreamHandler(MessageStreamHandler(identifier: identifier))
    }
    
    static func sendMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult, from: String = Definitions.mainTaskName) {
        let receivedMessage = parseReceivedMessage(call)
        if receivedMessage.commonMessage {
            let response = ForwardedMessage(from: from, message: receivedMessage.message)
            let encoder = JSONEncoder()
            let json = try! JSONSerialization.jsonObject(with: encoder.encode(response)) as? [String : Any]
            for pair in eventChannels {
                if pair.key != from {
                    pair.value(json)
                }
            }
            result(true)
        } else {
            if let to = receivedMessage.to, let channel = eventChannels[to] {
                let response = ForwardedMessage(from: from, message: receivedMessage.message)
                let encoder = JSONEncoder()
                let json = try! JSONSerialization.jsonObject(with: encoder.encode(response)) as? [String : Any]
                channel(json)
                result(true)
            } else {
                result(false)
            }
        }
    }
    
    private static func parseReceivedMessage(_ call: FlutterMethodCall) -> ReceivedMessage {
        let jsonData = try! JSONSerialization.data(withJSONObject: call.arguments as! [String: Any], options: .prettyPrinted)
        return try! JSONDecoder().decode(ReceivedMessage.self, from: jsonData)
    }
    
    fileprivate static func register(sink: @escaping FlutterEventSink, with identifier: String) {
        eventChannels[identifier] = sink
    }
    
    fileprivate static func unregisterHandler(by identifier: String) {
        keys.remove(identifier)
        eventChannels[identifier] = nil
    }
}

class MessageStreamHandler: NSObject, FlutterStreamHandler {
    
    private let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        MessageUtils.register(sink: events, with: identifier)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        MessageUtils.unregisterHandler(by: identifier)
        return nil
    }
    
}
