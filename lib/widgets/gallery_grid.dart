import "package:flutter/material.dart";

import "../widgets/photo_tile.dart";
import "../widgets/pinch_detector.dart";

class GalleryGrid extends StatelessWidget {
  const GalleryGrid({
    required this.photos,
    required this.columnCount,
    required this.isPinching,
    required this.onColumnCountChange,
    required this.onPinchActiveChange,
    required this.onPhotoTap,
    super.key,
  });

  final List<String> photos;
  final int columnCount;
  final bool isPinching;
  final void Function(int delta) onColumnCountChange;
  final void Function(bool isActive) onPinchActiveChange;
  final void Function(int index) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return PinchDetector(
      onColumnCountChange: onColumnCountChange,
      onPinchActiveChange: onPinchActiveChange,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        // Freeze scrolling while two fingers are active so the
        // GridView does not try to scroll and pinch simultaneously.
        physics: isPinching
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) {
          final String imagePath = photos[index];
          return PhotoTile(
            imagePath: imagePath,
            onTap: () => onPhotoTap(index),
          );
        },
      ),
    );
  }
}
