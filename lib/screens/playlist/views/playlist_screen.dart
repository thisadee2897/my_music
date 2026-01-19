import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_music/screens/music/controllers/music_controller.dart';
import 'package:my_music/screens/music/views/music_screen.dart';
import 'package:my_music/screens/playlist/views/widgets/image_widget.dart';
import '../controllers/playlist_controller.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(albumProvider.notifier).fetchAlbums();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumGroupByAlbumId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.when(
        data: (albums) {
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final albumId = albums.keys.elementAt(index);
              final albumList = albums[albumId]!;
              return ListTile(
                onTap: () {
                  ref.read(musicByAlbumProvider.notifier).state = albumList;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MusicScreen(autoPlay: true),
                    ),
                  );
                },
                leading: ImageWidget(albumList: albumList),
                title: Text(albumList.first.albumName ?? 'Unknown Album'),
                subtitle: Text('Artist: ${albumList.first.artistName}'),
                trailing: IconButton.outlined(
                  onPressed: () {
                    // เซ็ตเพลงทั้งหมดในอัลบั้ม
                    ref.read(musicByAlbumProvider.notifier).state = albumList;
                    // เปิดหน้า MusicScreen และเล่นเพลงแรกทันที
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MusicScreen(autoPlay: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
