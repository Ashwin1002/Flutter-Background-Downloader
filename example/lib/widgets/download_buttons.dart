import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.file_download,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}

class DownloadingButton extends StatelessWidget {
  const DownloadingButton({
    super.key,
    this.onTap,
    this.value,
    this.isPaused = false,
  });

  final VoidCallback? onTap;
  final double? value;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            value: value ?? 0,
            strokeWidth: 6,
          ),
          if (isPaused) const Icon(Icons.pause),
        ],
      ),
    );
  }
}

class DownloadedButton extends StatelessWidget {
  const DownloadedButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Card(
        elevation: 0,
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.file_download_done,
            size: 24.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
