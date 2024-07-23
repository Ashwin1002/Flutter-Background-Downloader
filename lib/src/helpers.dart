part of '../background_downloader.dart';

mixin Helpers {
  ///
  /// Prints the object in debugMode
  ///
  void logPrint(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  ///
  /// Checking if the storage permssion is granted in Android and returns a boolean value.
  ///
  /// 'deviceInfo' gets the current android version and sdk info. The sdk version greater than
  /// 28 doesn't require storage permission.
  ///
  /// 'isStoragePermissonGranted' checks is the storage permission is granted.
  ///
  /// 'requestStoragePermission' request permission for storage read and write access
  /// for sdk version less than 28
  ///
  ///
  Future<bool> checkAndroidStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final isStoragePermissonGranted = await Permission.storage.isGranted;

      if (deviceInfo.version.sdkInt > 28 || isStoragePermissonGranted) {
        return true;
      }

      final requestStoragePermission = await Permission.storage.request();

      return requestStoragePermission == PermissionStatus.granted;
    }
    throw StateError('Unknown Platform');
  }

  ///
  /// Checks if the storage permission is granted in Android and IOS and
  /// returns a boolean value.
  ///
  /// Note: IOS doesn't require storage permission
  ///
  Future<bool> checkStoragePermission() async {
    return (Platform.isIOS || (await checkAndroidStoragePermission()));
  }

  ///
  /// Creates a directory if not exist. Takes [path] as an argument.
  ///
  Future<void> createDirectory(String path) async {
    final savedDir = Directory(path);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }
  }
}
