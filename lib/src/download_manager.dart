part of '../background_downloader.dart';

String downloderSendPort = 'downloader_send_port';

class DownloadManager with Helpers {
  DownloadManager({
    required this.url,
  });

  ///
  /// The [url] of the file for downloading
  ///
  final String url;

  ///
  /// Initialize Flutter downloader at the main function of your project.
  /// Make Sure to place ```WidgetsFlutterBinding.ensureInitialized()```
  ///
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

  ///
  /// Path to the temporary directory on the device that is not backed up and
  /// is suitable for storing caches of downloaded files.
  ///
  Future<Directory> get cacheDir => getTemporaryDirectory();

  ///
  /// [_port], RecievePort which is used for communication of data in isolates and needs SendPort.
  ///
  final ReceivePort _port = ReceivePort();

  ///
  /// [_downloadStream] is for download model event stream
  ///
  Stream<DownloadModel>? _downloadStream;

  ///
  /// [_controller] is Stream controller for download model event stream
  ///
  final StreamController<DownloadModel> _controller =
      StreamController<DownloadModel>.broadcast();

  ///
  /// For [getting download event stream] property which is basically returns [_downloadStream]
  ///
  Stream<DownloadModel>? getGeofenceStream() => _downloadStream;

  ///
  /// private boolean value [_showContent] to make sure the content
  /// is shown only after downloading tasks is loaded.
  ///
  late bool _showContent;

  ///
  /// [_isPermissionReady], a boolean value to check whether the permissions are provieded correctly
  ///
  late bool _isPermissionReady;

  ///
  /// [_localPath] is the path of the directory while downloaded files are saved.
  ///
  late String _localPath;

  ///
  /// getter for boolean value [_showContent]
  ///
  bool get showContent => _showContent;

  Future<void> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    if (tasks == null) return;

    if (tasks.isNotEmpty) {
      for (var task in tasks) {
        if (task.url == url) {
          logPrint('task => $task');
          _controller.add(
            DownloadModel(
              taskID: task.taskId,
              progress: task.progress,
              status: DownloadStatus.fromTaskStatus(task.status),
            ),
          );
        }
      }
    }

    _isPermissionReady = await checkStoragePermission();
    if (_isPermissionReady) {
      _localPath = (await cacheDir).absolute.path;
      await createDirectory(_localPath);
    }

    _showContent = true;
  }

  ///
  /// Registers [downloderSendPort] sendport and returns [isSucess] a boolean value,
  /// If [isSucess] is false, then try again.
  /// Then, listens to the [_port] where message is represented as:
  ///
  /// [taskID]: message[0] as List<dynamic> which is also representated as String
  ///
  /// [status]: message[1] as int which is representated as DownloadStatus Enum
  ///
  /// [progress]: message[2] as int
  ///
  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      downloderSendPort,
    );

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen(
      (dynamic message) {
        var taskID = (message as List<dynamic>)[0] as String;
        var status = DownloadStatus.fromInt(message[1] as int);
        var progress = message[2] as int;

        logPrint(
          'Callback on UI isolate: '
          'task ($taskID) is in status ($status) and process ($progress)',
        );

        _downloadStream = _controller.stream;

        _controller.sink.add(
            DownloadModel(taskID: taskID, progress: progress, status: status));
      },
    );
  }

  ///
  /// A callback to look up SendPort by name [downloaderSendPort]
  /// @pragma('vm:entry-point') must be placed above the callback function to
  /// avoid tree shaking in release mode for Android.
  ///
  @pragma('vm:entry-point')
  void _downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    logPrint(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName(downloderSendPort)
        ?.send([id, status, progress]);
  }

  ///
  /// Removes [downloderSendPort] mapping given its name.
  ///
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(downloderSendPort);
  }

  ///
  /// Starts the download method.
  ///
  /// [headers] optional field to input header like token or JWT for authenticating before downloading
  ///
  /// [savedDirectory] where user desires to save the file.
  ///
  /// ### Android-only
  /// [saveInPublicStorage] boolean to save file whether in public storage
  ///
  /// [showNotification] boolean to show notificaiton while downloading
  ///
  /// [openFileFromNotification] boolean whether to open file form notification
  ///
  Future<void> startDownload({
    String? savedDirectory,
    Map<String, String> headers = const {},
    bool saveInPublicStorage = false,
    bool showNotification = false,
    bool openFileFromNotification = false,
  }) async {
    await FlutterDownloader.enqueue(
      url: url,
      headers: headers,
      savedDir: savedDirectory ?? _localPath,
      saveInPublicStorage: saveInPublicStorage,
      showNotification: showNotification,
      fileName: url.split('/').last,
      openFileFromNotification: openFileFromNotification,
    );
  }

  ///
  /// Pauses a running download task with id [taskID].
  ///
  Future<void> pauseDownload(String taskID) async {
    await FlutterDownloader.pause(taskId: taskID);
  }

  ///
  /// Resumes a paused download task with id [taskID].
  ///
  Future<void> resumeDownload(String taskID) async {
    await FlutterDownloader.resume(taskId: taskID);
  }

  Future<void> removeDownload(String taskID,
      {bool shouldDeleteContent = true}) async {
    await FlutterDownloader.remove(
        taskId: taskID, shouldDeleteContent: shouldDeleteContent);
    await _prepare();
  }

  ///
  /// Retries a failed download task with id [taskID]
  ///
  Future<void> retryDownload(
    String taskID, {
    bool requiresStorageNotLow = true,
    int timeout = 15000,
  }) async {
    await FlutterDownloader.retry(
      taskId: taskID,
      requiresStorageNotLow: requiresStorageNotLow,
      timeout: timeout,
    );
  }

  ///
  /// Startes background isolate.
  /// and perpare download task for starting download service
  ///
  void initializeDownload() {
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(_downloadCallback, step: 1);

    _showContent = false;
    _isPermissionReady = false;

    unawaited(_prepare());
  }

  ///
  /// dispose the [_downloadStream] and remove [downloaderSendPort]
  ///
  void dispose() {
    if (_downloadStream != null) {
      _downloadStream = null;
    }
    _unbindBackgroundIsolate();
  }
}
