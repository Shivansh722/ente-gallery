import "dart:math";

class AssetLoader {
  const AssetLoader();

  Future<List<String>> loadShuffledGalleryPhotos() async {
    final List<String> orderedPhotoPaths = List<String>.generate(
      60,
      (int index) => "assets/gallery/photo_${index + 1}.jpg",
    );

    // Shuffle for visual variety on each app launch.
    orderedPhotoPaths.shuffle(Random());

    return orderedPhotoPaths;
  }
}
