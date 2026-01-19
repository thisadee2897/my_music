import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_music/screens/playlist/models/album_model.dart';

class AlbumNotifer extends StateNotifier<AsyncValue<List<AlbumModel>>> {
  AlbumNotifer() : super(const AsyncValue.loading());

  // initial fetch function
  Future<void> fetchAlbums() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      var dio = Dio();
      Response response = await dio.get('https://api.jamendo.com/v3.0/tracks?client_id=f3865169&format=json&tags=chill,acoustic');


      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response.data['results']);
        return data.map((albumJson) => AlbumModel.fromJson(albumJson)).toList();
      } else {
        throw Exception('Failed to load albums');
      }
    });
  }
}

final albumProvider = StateNotifierProvider<AlbumNotifer, AsyncValue<List<AlbumModel>>>((ref) => AlbumNotifer());

final albumGroupByAlbumId = Provider<AsyncValue<Map<String, List<AlbumModel>>>>((ref) {
  final albumState = ref.watch(albumProvider);

  return albumState.when(
    data: (albums) {
      final Map<String, List<AlbumModel>> groupedAlbums = {};
      for (var album in albums) {
        final albumId = album.albumId ?? 'unknown';
        if (!groupedAlbums.containsKey(albumId)) {
          groupedAlbums[albumId] = [];
        }
        groupedAlbums[albumId]!.add(album);
      }
      return AsyncValue.data(groupedAlbums);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
