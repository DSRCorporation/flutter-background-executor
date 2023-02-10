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
import SwiftUI

@propertyWrapper
public struct UserDefault<Value>: DynamicProperty {
    private let get: () -> Value
    private let set: (Value) -> Void
    
    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}

public extension UserDefault {
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == String {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Double {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Bool {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    private init(defaultValue: Value, key: String, store: UserDefaults) {
        get = {
            let value = store.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        
        set = { newValue in
            store.set(newValue, forKey: key)
        }
    }
}

public extension UserDefault where Value: ExpressibleByNilLiteral {
    
    init(_ key: String, store: UserDefaults = .standard) where Value == String? {
        self.init(wrappedType: String.self, key: key, store: store)
    }
    
    init(_ key: String, store: UserDefaults = .standard) where Value == Int64? {
        self.init(wrappedType: Int64.self, key: key, store: store)
    }
    
    private init<T>(wrappedType: T.Type, key: String, store: UserDefaults) {
        get = {
            let value = store.value(forKey: key) as? Value
            return value ?? nil
        }
        
        set = { newValue in
            let newValue = newValue as? Optional<T>
            
            if let newValue = newValue {
                store.set(newValue, forKey: key)
            } else {
                store.removeObject(forKey: key)
            }
        }
    }
}
