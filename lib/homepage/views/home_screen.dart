import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_music/screens/playlist/controllers/playlist_controller.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      appBar: AppBar(title: const Text('My Playlist',style: TextStyle(fontWeight: FontWeight.bold),)),
      body: state.when(
        data: (albums) {
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final albumId = albums.keys.elementAt(index);
              final albumList = albums[albumId]!;
              return ListTile(
                onTap: () {
                  // Navigate to album details or play music
                },
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    imageUrl: albumList.first.albumImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const Icon(Icons.music_note),
                  ),
                ),
                title: Text(albumList.first.albumName ?? 'Unknown Album'),
                subtitle: Text('Artist: ${albumList.first.artistName}'),
                trailing: IconButton.outlined(onPressed: (){}, icon: Icon(Icons.play_arrow))
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
