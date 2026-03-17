import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class CctvHlsScreen extends StatefulWidget {
  const CctvHlsScreen({super.key});

  @override
  State<CctvHlsScreen> createState() => _CctvHlsScreenState();
}

class _CctvHlsScreenState extends State<CctvHlsScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      // Uri.parse("http://192.168.18.94:8888/cctv_processed/index.m3u8"),
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.play();
      setState(() {});
    });
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });

    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          isFullscreen ? null : const CustomAppBar(title: "CCTV Monitoring"),

      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),

                      // CONTROL BAR
                      Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                            ),

                            const Spacer(),

                            IconButton(
                              icon: Icon(
                                isFullscreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: toggleFullscreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // contoh konten tambahan agar bisa discroll
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "CCTV Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Monitoring CCTV area tambang batubara secara real-time menggunakan Raspberry Pi dan model deteksi objek.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
