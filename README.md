# Background Downloader

A Flutter downloader library which handles download in separate thread with background processing. This works in both Android and IOS.

## Features
- Manage Downloads By tasks
- Able to listen to status and progress changes
- Partial Download Feature
- Able to download, resume, retry, cancel or remove tasks
  
## Platform Supported
1. Android
2. IOS

## Getting Started
In your ```pubspec.yaml``` file add:

```
dependencies:
  background_downloader: any
```
Then, in your code import:

```
import 'package:background_downloader/background_downloader.dart';
```

### Android Configuration
Inside your ```AndroidManifest.xml``` file, add the following:

Add, permisssions:
```
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
```
Add, external storage read and write permission for sdk version less than 28.
Optional, if you need to install packages/apks, add:
```
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

Under ```<application> ... <\application>```
Optional, Add below code to open file from notification:
```
  <provider
      android:name="vn.hunghd.flutterdownloader.DownloadedFileProvider"
      android:authorities="${applicationId}.flutter_downloader.provider"
      android:exported="false"
      android:grantUriPermissions="true">
      <meta-data
          android:name="android.support.FILE_PROVIDER_PATHS"
          android:resource="@xml/provider_paths"/>
  </provider>
```

Optional, Add below code to configure maximum number of concurrent download tasks
```
<!-- Begin FlutterDownloader customization -->
<!-- disable default Initializer -->
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    android:exported="false"
    tools:node="merge">
    <meta-data
        android:name="androidx.work.WorkManagerInitializer"
        android:value="androidx.startup"
        tools:node="remove" />
</provider>

<!-- declare customized Initializer -->
  <provider
      android:name="vn.hunghd.flutterdownloader.FlutterDownloaderInitializer"
      android:authorities="${applicationId}.flutter-downloader-init"
      android:exported="false">
      <!-- changes this number to configure the maximum number of concurrent tasks -->
      <meta-data
          android:name="vn.hunghd.flutterdownloader.MAX_CONCURRENT_TASKS"
          android:value="5" />
  </provider>
  <!-- End FlutterDownloader customization -->
```

### IOS Configuration
Inside your ```AppDelegate.swift``` file, replace the current code with the following code:

```
import Flutter
import UIKit
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
```

### Usage
Please refer to ```/example``` folder for a working example.

#### Initialize Download
In your ```main.dart``` file, add the following lines of code before ```runApp``` method:
```
  WidgetsFlutterBinding.ensureInitialized();
  await DownloadManager.initialize(debug: true);
```

Now, You can use the ```DownloadManager`` class.

#### Initialize DownloadManager
```
  final DownloadManager _downloadManager = DownloadManager(
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4');
  _downloadManage.initializeDownload();
```

#### Dispose DownloadManager
```
  _downloadManage.dispose();
```

Place the above code in you ```initState()``` of your dart code.

#### Listen to DownloadManager stream
```
 DownloadModel _downloadTask = DownloadModel.initial();

 _downloadManager.getDownloadStream()?.listen(
      (event) {
        log('event => $event');
        setState(() {
          _downloadTask = event;
        });
      },
    );
```

#### Start Download
```
  await _downloadManager.startDownload(_downloadTask.taskID)
```

#### Pause Download
```
  await _downloadManager.pauseDownload(_downloadTask.taskID)
```

#### Resume Download
```
   await _downloadManager.resumeDownload(_downloadTask.taskID)
```

#### Remove Download
```
  await _downloadManager.removeDownload(_downloadTask.taskID)
```

#### Cancel Download
```
  await _downloadManager.cancelDownload(_downloadTask.taskID)
```

#### Retry Download
```
  await _downloadManager.retryDownload(_downloadTask.taskID)
```

#### Open Downloaded File
```
  bool isDownloaded = await _downloadManager.openFile(_downloadTask.taskID);
```

#TODO
- Multiple downloads at once
