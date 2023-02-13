# flutter_background_executor

This plugin is designed to create background update tasks. He is based on WorkManager for Android
and BackgroundTasks for iOS.

## Dart

To schedule a refresh task, call the createRefreshTask function.

```dart
class Example {
  Future<void> settingRefresh() async {
    await FlutterBackgroundExecutor().createRefreshTask(
      callback: call,
      settings: BackgroundExecutorSettings(
        androidDetails: AndroidBackgroundExecutorDetails(),
        iosDetails: IosBackgroundExecutorDetails(taskIdentifier: 'com.dsr_corporation.refresh-task'),
      ),
    );
  }
}
```

In this case, a static function is passed to the callback parameter

```dart
class Example {
  Future<void> settingRefresh() async {
    await FlutterBackgroundExecutor().createRefreshTask(
      callback: call,
      settings: BackgroundExecutorSettings(
        androidDetails: AndroidBackgroundExecutorDetails(),
        iosDetails: IosBackgroundExecutorDetails(taskIdentifier: 'com.dsr_corporation.refresh-task'),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> call() async {
  print('Called refresh task');
}
```

or

```dart
class Example {
  Future<void> settingRefresh() async {
    await FlutterBackgroundExecutor().createRefreshTask(
      callback: call,
      settings: BackgroundExecutorSettings(
        androidDetails: AndroidBackgroundExecutorDetails(),
        iosDetails: IosBackgroundExecutorDetails(taskIdentifier: 'com.dsr_corporation.refresh-task'),
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> call() async {
    print('Called refresh task');
  }
}
```

## Android

To set up a background task on Android, you can change the following options:

| Option                | Type               | Description                                                                                  | Default value                  |
|-----------------------|--------------------|----------------------------------------------------------------------------------------------|--------------------------------|
| requiredNetworkType   | AndroidNetworkType | The type of network required for the work to run.                                            | AndroidNetworkType.notRequired |
| requiresCharging      | bool               | Whether device should be charging for the work to run.                                       | false                          |
| requiresDeviceIdle    | bool               | Whether device should be idle for the work to run(Android 6+)                                | false                          |
| requiresBatteryNotLow | bool               | Whether the device's battery level must be acceptable for the work to run.                   | false                          |
| requiresStorageNotLow | bool               | Whether the device's available storage should be at an acceptable level for the work to run. | false                          |
| minUpdateDelay        | Duration           | Sets the delay that is allowed from the time a content.                                      | Duration(minutes: 15)          |
| maxUpdateDelay        | Duration           | Sets the maximum delay that is allowed from the first time a content.                        | Duration(hours: 1)             |
| initialDelay          | Duration           | Sets an initial delay for the work.                                                          | Duration(minutes: 3)           |
| repeatInterval        | Duration           | The repeat interval.                                                                         | Duration(minutes: 15)          |
| flexInterval          | Duration           | The duration for which this work repeats from the end of the repeatInterval.                 | Duration(minutes: 15)          |

## iOS

To set up a background task on iOS, you need to do the following:

1. Need to add capability `Background Modes` ![image](ios_setting_images/1.png)
2. Need to select `Background fetch` and `Background processing` ![image](ios_setting_images/2.png)
3. Need to set background task identifier in Info.plist on `Permitted background task scheduler identifiers`(`BGTaskSchedulerPermittedIdentifiers`) ![image](ios_setting_images/3.png)

The required steps for configuring background work are now complete. 
But in this case, the task will be configured only on the second run.
This is due to the fact that iOS allows you to configure background tasks only during the launch of the application itself.
In order to set up a task for the first run, you need to pass the task identifier to the plugin:

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        SwiftFlutterBackgroundExecutorPlugin.taskIdentifier = "com.dsr-corporation.refresh-task"
        ...
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}

```

or 

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UserDefaults.standarхВd.set("com.dsr-corporation.refresh-task", forKey: .taskIdentifierKey)
        ...
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}
```

For iOS, you can not set the frequency of the background task. 
The system itself determines the launch time depending on how the user uses the application and the phone as a whole.
To check the setting, you can use the command:

`e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"taskID"]`