import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_music/extensions/duration_formatter.dart';
import 'package:my_music/screens/playlist/views/widgets/image_widget.dart';

import '../controllers/music_controller.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  @override
  Widget build(BuildContext context) {
    final datas = ref.watch(musicByAlbumProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 61, 89),
      appBar: AppBar(
        title: const Text('Music Player', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: datas.length,
        itemBuilder: (context, index) {
          final music = datas[index];
          return ListTile(
            leading: ImageWidget(albumList: datas),
            title: Text(music.name ?? 'Unknown Track', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Artist: ${music.artistName} -  ${music.duration!.toMinutesSeconds()}', style: const TextStyle(color: Colors.white70)),
          );
        },
      ),
    );
  }
}
