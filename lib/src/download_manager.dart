import 'dart:io';
import 'dart:isolate';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  DownloadManager._internal();

  factory DownloadManager() => DownloadManager._internal();

  ///
  /// Initialize Flutter downloader at the main function of your project
  /// Make Sure to place ```WidgetsFlutterBinding.ensureInitialized()```
  /// before the keeping the "initialize()" method
  ///
  static Future<void> initialize({
    bool debug = false,
    bool ignoreSsl = false,
  }) async {
    if (FlutterDownloader.initialized) return;
    await FlutterDownloader.initialize(
      debug: debug,
      ignoreSsl: ignoreSsl,
    );
  }

  Future<Directory> get cacheDir => getApplicationDocumentsDirectory();

  final ReceivePort _port = ReceivePort();

  String? _taskID;
  DownloadTaskStatus? _downloadTaskStatus;
  int _progress = 0;
  late bool _showContent;
  late bool _isPermissionReady;
  late String _localPath;
}
