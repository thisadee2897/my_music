import 'package:flutter_riverpod/legacy.dart';
import 'package:my_music/screens/playlist/models/album_model.dart';

final musicByAlbumProvider = StateProvider<List<AlbumModel>>((ref) => []);

// Provider สำหรับเก็บ index ของเพลงที่กำลังเล่น
final currentTrackIndexProvider = StateProvider<int>((ref) => 0);

// Provider สำหรับเช็คว่ากำลังเล่นหรือไม่
final isPlayingProvider = StateProvider<bool>((ref) => false);
