import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../services/event_service.dart';

/// Halaman media menampilkan video promosi & galeri foto event
class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  Future<void> _showUrlInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    final eventService = Provider.of<EventService>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ganti Video Promosi'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan URL Video (https://file.mp4)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Ganti'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  eventService.setPromoVideoUrl(controller.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                const Text(
                'Video Promosi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

                  TextButton.icon(
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Ganti URL'),
                    onPressed: () => _showUrlInputDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1DB954),
                    ),
                  ),
                ],
              ),
            ),

            const PromoVideoPlayerWrapper(),
            const Divider(height: 32, thickness: 1, color: Colors.white24),

            PromoVideoPlayer(videoUrl: '',),
            Divider(height: 32, thickness: 1, color: Colors.white24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Galeri Foto Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8),
            EventPhotoGrid(),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan video promosi (asset lokal)
class PromoVideoPlayerWrapper extends StatelessWidget {
  const PromoVideoPlayerWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer mendengarkan perubahan pada promoVideoUrl
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        // Meneruskan URL yang diambil dari service ke PromoVideoPlayer
        return PromoVideoPlayer(videoUrl: eventService.promoVideoUrl);
      },
    );
  }
}

/// Widget utama pemutar video (Asset lokal atau Network)
class PromoVideoPlayer extends StatefulWidget {
  final String videoUrl; // Menerima URL/Path dari luar
  const PromoVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PromoVideoPlayer> createState() => _PromoVideoPlayerState();
}

class _PromoVideoPlayerState extends State<PromoVideoPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant PromoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ini PENTING: Jika URL berubah (saat tombol Ganti di klik), inisialisasi ulang
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initializeController();
    }
  }

  void _initializeController() async {
    await _controller?.dispose();

    final url = widget.videoUrl;

    if (url.isEmpty || url.startsWith('assets/')) {
      // Jika URL kosong atau diawali 'assets/', gunakan asset lokal
      _controller = VideoPlayerController.asset('assets/videos/promo.mp4');
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }

    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: spotifyGreen));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.white70,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget grid untuk menampilkan foto event
class EventPhotoGrid extends StatelessWidget {
  const EventPhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final eventsWithImages = eventService.events
            .where((event) => event.imagePath != null && event.imagePath!.isNotEmpty)
            .toList();

        if (eventsWithImages.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Belum ada foto event.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: eventsWithImages.length,
          itemBuilder: (context, index) {
            final event = eventsWithImages[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: GridTile(
                footer: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black54,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                child: Image.file(
                  File(event.imagePath!),
                  fit: BoxFit.cover,

                  // Penting: membatasi ukuran decode gambar
                  // agar tidak memakan memori terlalu besar
                  cacheHeight: 500,
                  cacheWidth: 500,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
