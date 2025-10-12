import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;

  const AlbumCard({super.key, required this.album, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: album.image != null
                  ? Image.network(album.image!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.photo,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            album.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          // Text(
          //   "${album.publishs?.length ?? 0} fotos",
          //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
          // ),
        ],
      ),
    );
  }
}
