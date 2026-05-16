import "package:flutter/material.dart";

import "../services/asset_loader.dart";
import "../widgets/photo_tile.dart";

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const int kInitialColumnCount = 3;

  final AssetLoader _assetLoader = const AssetLoader();

  List<String> _shuffledPhotoPaths = <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load assets once at startup to keep build lightweight.
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final List<String> shuffledPhotoPaths =
        await _assetLoader.loadShuffledGalleryPhotos();

    if (!mounted) {
      return;
    }

    setState(() {
      _shuffledPhotoPaths = shuffledPhotoPaths;
      // Flip the loading flag after data is ready to render.
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Gallery"),
      ),
      body: _isLoading
          ? const Center(
              // Keep the UI responsive while assets are being prepared.
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: kInitialColumnCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _shuffledPhotoPaths.length,
              itemBuilder: (BuildContext context, int index) {
                final String imagePath = _shuffledPhotoPaths[index];
                return PhotoTile(imagePath: imagePath);
              },
            ),
    );
  }
}
