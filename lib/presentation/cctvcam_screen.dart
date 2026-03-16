import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CctvHlsScreen extends StatefulWidget {
  const CctvHlsScreen({super.key});

  @override
  State<CctvHlsScreen> createState() => _CctvHlsScreenState();
}

class _CctvHlsScreenState extends State<CctvHlsScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse("http://192.168.18.94:8888/cctv_processed/index.m3u8"),
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CCTV Monitoring")),

      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
