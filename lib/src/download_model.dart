part of '../background_downloader.dart';

///
/// A Helper model which stores 3 key information.
///
/// [taskID] of data type "String". TaskID helps to identify the unqiue downloading task which
///  is used for removing, pausing, resuming downloaded file.
///
/// [progress] of data type "Int" which stores the information about downloaded percentage.
/// It is in range from 0 - 100. If download is failed or cancelled the percentage is -1.
///
/// [status] of data type "Enum". It represents the status of a file while downloading.
///
@immutable
class DownloadModel {
  final String taskID;
  final int progress;
  final DownloadStatus status;

  const DownloadModel({
    required this.taskID,
    required this.progress,
    required this.status,
  });

  factory DownloadModel.initial() => const DownloadModel(
        taskID: '',
        progress: -1,
        status: DownloadStatus.undefined,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DownloadModel &&
        other.taskID == taskID &&
        other.progress == progress &&
        other.status == status;
  }

  @override
  int get hashCode => taskID.hashCode ^ progress.hashCode ^ status.hashCode;

  DownloadModel copyWith({
    String? taskID,
    int? progress,
    DownloadStatus? status,
  }) {
    return DownloadModel(
      taskID: taskID ?? this.taskID,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'DownloadModel(taskID: $taskID, progress: $progress, status: $status)';
}
