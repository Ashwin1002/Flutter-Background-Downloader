import 'package:flutter/material.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }
}
