import "package:flutter/material.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";

import "../widgets/photo_tile.dart";
import "../widgets/pinch_detector.dart";

class GalleryMasonry extends StatelessWidget {
  const GalleryMasonry({
    required this.photos,
    required this.aspectRatios,
    required this.columnCount,
    required this.isPinching,
    required this.scrollController,
    required this.onColumnCountChange,
    required this.onPinchActiveChange,
    required this.onPhotoTap,
    super.key,
  });

  final List<String> photos;
  final Map<String, double> aspectRatios;
  final int columnCount;
  final bool isPinching;
  final ScrollController scrollController;
  final void Function(int delta) onColumnCountChange;
  final void Function(bool isActive) onPinchActiveChange;
  final void Function(int index) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return PinchDetector(
      onColumnCountChange: onColumnCountChange,
      onPinchActiveChange: onPinchActiveChange,
      child: MasonryGridView.count(
        controller: scrollController,
        padding: const EdgeInsets.all(8),
        physics: isPinching
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
        crossAxisCount: columnCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) {
          final String imagePath = photos[index];
          return PhotoTile(
            imagePath: imagePath,
            // Aspect ratios are precomputed to keep masonry layout stable.
            aspectRatio: aspectRatios[imagePath],
            onTap: () => onPhotoTap(index),
          );
        },
      ),
    );
  }
}
