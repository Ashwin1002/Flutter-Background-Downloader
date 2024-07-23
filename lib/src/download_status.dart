part of '../background_downloader.dart';

///
/// Defines a set of possible status while downloading a file.
///

enum DownloadStatus {
  undefined(0),
  queued(1),
  downloading(2),
  completed(3),
  failed(4),
  paused(5),
  cancelled(6);

  const DownloadStatus(this.value);

  final int value;

  bool get isQueued => this == DownloadStatus.queued;
  bool get isDownloading => this == DownloadStatus.downloading;
  bool get isCompleted => this == DownloadStatus.completed;
  bool get isFailed => this == DownloadStatus.failed;
  bool get isPaused => this == DownloadStatus.paused;
  bool get isCancelled => this == DownloadStatus.cancelled;

  /// Creates a new [DownloadStatus] from an [int].
  factory DownloadStatus.fromInt(int value) {
    switch (value) {
      case 0:
        return DownloadStatus.undefined;
      case 1:
        return DownloadStatus.queued;
      case 2:
        return DownloadStatus.downloading;
      case 3:
        return DownloadStatus.completed;
      case 4:
        return DownloadStatus.failed;
      case 5:
        return DownloadStatus.cancelled;
      case 6:
        return DownloadStatus.paused;
      default:
        throw ArgumentError('Invalid value: $value');
    }
  }

  /// Creates a new [DownloadStatus] from an [DownloadTaskStatus].
  factory DownloadStatus.fromTaskStatus(DownloadTaskStatus value) {
    switch (value) {
      case DownloadTaskStatus.undefined:
        return DownloadStatus.undefined;
      case DownloadTaskStatus.enqueued:
        return DownloadStatus.queued;
      case DownloadTaskStatus.running:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.complete:
        return DownloadStatus.completed;
      case DownloadTaskStatus.failed:
        return DownloadStatus.failed;
      case DownloadTaskStatus.canceled:
        return DownloadStatus.cancelled;
      case DownloadTaskStatus.paused:
        return DownloadStatus.paused;
      default:
        throw ArgumentError('Invalid value: $value');
    }
  }
}

extension DownloadStatusExt on DownloadStatus {
  A when<A>({
    required A Function() initial,
    required A Function() downloading,
    required A Function() done,
    required A Function() paused,
  }) {
    return switch (this) {
      DownloadStatus.completed || DownloadStatus.cancelled => done(),
      DownloadStatus.paused => paused(),
      DownloadStatus.downloading => downloading(),
      _ => initial(),
    };
  }
}
