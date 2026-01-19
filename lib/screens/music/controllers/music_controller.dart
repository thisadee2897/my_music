import 'package:flutter_riverpod/legacy.dart';
import 'package:my_music/screens/playlist/models/album_model.dart';

final musicByAlbumProvider = StateProvider<List<AlbumModel>>((ref) => []);
