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

import 'package:flutter_background_executor/src/models/received_message.dart';

typedef MessageSender = Future<bool> Function({
  String? to,
  bool commonMessage,
  required String message,
});

class EngineConnector {
  final Stream<ReceivedMessage> messageStream;
  final MessageSender messageSender;
  final String currentTaskIdentifier;

  EngineConnector({
    required this.messageStream,
    required this.messageSender,
    required this.currentTaskIdentifier,
  });
}
