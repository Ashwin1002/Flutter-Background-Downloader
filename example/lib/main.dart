import 'dart:developer';

import 'package:background_downloader/background_downloader.dart';
import 'package:example/widgets/widgets.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DownloadManager.initialize(debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Downloader Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Downloads'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DownloadManager _downloadManager = DownloadManager(
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4');

  DownloadModel _downloadTask = DownloadModel.initial();

  @override
  void initState() {
    super.initState();

    _downloadManager.initializeDownload();

    _downloadManager.getDownloadStream()?.listen(
      (event) {
        log('event => $event');
        setState(() {
          _downloadTask = event;
        });
      },
    );
  }

  @override
  void dispose() {
    _downloadManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: InkWell(
          onTap: () async {
            // await _downloadManager.open(taskId: _taskID!);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const FilePreview(),
                  const SizedBox(width: 20.0),
                  const FileContent(),
                  const SizedBox(width: 20.0),
                  if (!_downloadManager.showContent)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    switch (_downloadTask.status) {
                      DownloadStatus.completed ||
                      DownloadStatus.cancelled =>
                        DownloadedButton(
                          onTap: () async => await _downloadManager
                              .removeDownload(_downloadTask.taskID),
                        ),
                      DownloadStatus.paused => DownloadingButton(
                          isPaused: true,
                          value: _downloadTask.progress / 100,
                          onTap: () async => await _downloadManager
                              .resumeDownload(_downloadTask.taskID),
                        ),
                      DownloadStatus.downloading => DownloadingButton(
                          value: _downloadTask.progress / 100,
                          onTap: () async => await _downloadManager
                              .pauseDownload(_downloadTask.taskID),
                        ),
                      _ => DownloadButton(
                          onTap: () => _downloadManager.startDownload(
                            showNotification: true,
                          ),
                        ),
                    }
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
