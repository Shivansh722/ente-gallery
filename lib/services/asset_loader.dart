import "dart:math";

class AssetLoader {
  const AssetLoader();

  Future<List<String>> loadShuffledGalleryPhotos() async {
    final List<String> orderedPhotoPaths = <String>[
      "assets/gallery/image_001_Image_2.jpg",
      "assets/gallery/image_002_Image_3.jpg",
      "assets/gallery/image_003_Image_1.jpg",
      "assets/gallery/image_004_Image_4.jpg",
      "assets/gallery/image_005_Image_5.jpg",
      "assets/gallery/image_006_Image_3.jpg",
      "assets/gallery/image_007_Image_2.jpeg",
      "assets/gallery/image_008_Image_1.jpg",
      "assets/gallery/image_009_Image_4.jpg",
      "assets/gallery/image_010_Image_5.jpg",
      "assets/gallery/image_011_Image_6.jpg",
      "assets/gallery/image_012_Image_2.jpg",
      "assets/gallery/image_013_Image_3.jpg",
      "assets/gallery/image_014_Image_1.jpg",
      "assets/gallery/image_015_Image_4.jpg",
      "assets/gallery/image_016_Image_5.jpg",
      "assets/gallery/image_017_Image_6.jpg",
      "assets/gallery/image_018_Image_2.jpg",
      "assets/gallery/image_019_Image_3.jpg",
      "assets/gallery/image_020_Image_1.jpg",
      "assets/gallery/image_021_Image_4.jpg",
      "assets/gallery/image_022_Image_5.jpg",
      "assets/gallery/image_023_Image_6.jpg",
      "assets/gallery/image_024_Image_2.jpg",
      "assets/gallery/image_025_Image_3.jpg",
      "assets/gallery/image_026_Image_1.jpg",
      "assets/gallery/image_027_Image_4.jpg",
      "assets/gallery/image_028_Image_5.jpg",
      "assets/gallery/image_029_Image_6.jpg",
      "assets/gallery/image_030_Image_2.jpg",
      "assets/gallery/image_031_Image_3.jpg",
      "assets/gallery/image_032_Image_1.jpg",
      "assets/gallery/image_033_Image_4.jpg",
      "assets/gallery/image_034_Image_5.jpg",
      "assets/gallery/image_035_Image_6.jpg",
      "assets/gallery/image_036_Image_2.jpg",
      "assets/gallery/image_037_Image_3.jpg",
      "assets/gallery/image_038_Image_1.jpg",
      "assets/gallery/image_039_Image_4.jpg",
      "assets/gallery/image_040_Image_5.jpg",
      "assets/gallery/image_041_Image_6.jpg",
      "assets/gallery/image_042_Image_2.jpg",
      "assets/gallery/image_043_Image_3.jpg",
      "assets/gallery/image_044_Image_1.jpg",
      "assets/gallery/image_045_Image_4.jpg",
      "assets/gallery/image_046_Image_5.jpg",
      "assets/gallery/image_047_Image_6.jpg",
      "assets/gallery/image_049_Image_1.jpg",
      "assets/gallery/image_050_Image_4.jpg",
      "assets/gallery/image_051_Image_5.jpg",
      "assets/gallery/image_052_Image_3.jpeg",
      "assets/gallery/image_053_Image_6.jpg",
      "assets/gallery/image_054_Image_2.jpg",
      "assets/gallery/image_055_Image_3.jpg",
      "assets/gallery/image_056_Image_1.jpg",
      "assets/gallery/image_057_Image_4.jpg",
      "assets/gallery/image_058_Image_5.jpg",
      "assets/gallery/image_059_Image_6.jpg",
    ];

    // shuffling for fresh exp
    orderedPhotoPaths.shuffle(Random());

    return orderedPhotoPaths;
  }
}
