import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_music/extensions/duration_formatter.dart';
import 'package:my_music/screens/playlist/views/widgets/image_widget.dart';
import 'package:my_music/services/audio_player_service.dart';

import '../controllers/music_controller.dart';

class MusicScreen extends ConsumerStatefulWidget {
  final bool autoPlay;
  const MusicScreen({super.key, this.autoPlay = false});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final datas = ref.read(musicByAlbumProvider);
        if (datas.isNotEmpty && datas.first.audio != null) {
          final audioService = ref.read(audioPlayerServiceProvider);
          await audioService.play(datas.first.audio!);
          ref.read(currentTrackIndexProvider.notifier).state = 0;
          ref.read(isPlayingProvider.notifier).state = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    final isPlaying = ref.read(isPlayingProvider);
    
    if (isPlaying) {
      await audioService.pause();
      ref.read(isPlayingProvider.notifier).state = false;
    } else {
      await audioService.resume();
      ref.read(isPlayingProvider.notifier).state = true;
    }
  }

  Future<void> _playNext() async {
    final datas = ref.read(musicByAlbumProvider);
    final currentIndex = ref.read(currentTrackIndexProvider);
    
    if (currentIndex < datas.length - 1) {
      final nextIndex = currentIndex + 1;
      final nextTrack = datas[nextIndex];
      
      if (nextTrack.audio != null) {
        final audioService = ref.read(audioPlayerServiceProvider);
        await audioService.play(nextTrack.audio!);
        ref.read(currentTrackIndexProvider.notifier).state = nextIndex;
        ref.read(isPlayingProvider.notifier).state = true;
      }
    }
  }

  Future<void> _playPrevious() async {
    final datas = ref.read(musicByAlbumProvider);
    final currentIndex = ref.read(currentTrackIndexProvider);
    
    if (currentIndex > 0) {
      final previousIndex = currentIndex - 1;
      final previousTrack = datas[previousIndex];
      
      if (previousTrack.audio != null) {
        final audioService = ref.read(audioPlayerServiceProvider);
        await audioService.play(previousTrack.audio!);
        ref.read(currentTrackIndexProvider.notifier).state = previousIndex;
        ref.read(isPlayingProvider.notifier).state = true;
      }
    }
  }

  Future<void> _playTrack(int index) async {
    final datas = ref.read(musicByAlbumProvider);
    final track = datas[index];
    
    if (track.audio != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      await audioService.play(track.audio!);
      ref.read(currentTrackIndexProvider.notifier).state = index;
      ref.read(isPlayingProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final datas = ref.watch(musicByAlbumProvider);
    final currentIndex = ref.watch(currentTrackIndexProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);
    
    if (datas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Music Player')),
        body: const Center(child: Text('No music available')),
      );
    }

    final currentTrack = datas[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1a2332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2332),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              currentTrack.name ?? 'Unknown Track',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              currentTrack.artistName ?? 'Unknown Artist',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Album Art Section
          Container(
            height: 80,
            color: const Color(0xFF243447),
            child: Row(
              children: [
                // Album Image
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: ImageWidget(albumList: datas),
                    ),
                  ),
                ),
                // Song Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.name ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentTrack.artistName ?? 'Unknown Artist',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Control Buttons
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  iconSize: 32,
                  onPressed: _playPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: Colors.white,
                  iconSize: 32,
                  onPressed: _playNext,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Progress Bar
          Container(
            color: const Color(0xFF243447),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                position.when(
                  data: (pos) {
                    final dur = duration.value ?? Duration.zero;
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: pos.inSeconds.toDouble().clamp(0.0, dur.inSeconds.toDouble()),
                        max: dur.inSeconds.toDouble() > 0 ? dur.inSeconds.toDouble() : 1.0,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          audioService.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(color: Colors.yellow),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: const Color(0xFF243447),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'UP NEXT'),
                Tab(text: 'LYRICS'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Up Next Tab
                ListView.builder(
                  itemCount: datas.length,
                  itemBuilder: (context, index) {
                    final music = datas[index];
                    final isCurrentTrack = index == currentIndex;
                    
                    return Container(
                      color: isCurrentTrack 
                          ? const Color(0xFF2d4159)
                          : const Color(0xFF1a2332),
                      child: ListTile(
                        onTap: () => _playTrack(index),
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: ImageWidget(albumList: datas),
                              ),
                              if (isCurrentTrack && isPlaying)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.bar_chart,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        title: Text(
                          music.name ?? 'Unknown Track',
                          style: TextStyle(
                            color: isCurrentTrack ? Colors.white : Colors.white,
                            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${music.artistName} • ${music.duration!.toMinutesSeconds()}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white54),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
                // Lyrics Tab
                const Center(
                  child: Text(
                    'Lyrics not available',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
