import 'package:flutter/material.dart';

class FileContent extends StatelessWidget {
  const FileContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Music header - The garden of dreams',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            '24.5 KB',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
          ),
        ],
      ),
    );
  }
}
