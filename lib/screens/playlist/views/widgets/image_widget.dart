import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_music/screens/playlist/models/album_model.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.albumList});

  final List<AlbumModel> albumList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
