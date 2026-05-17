import "package:flutter/material.dart";

import "../services/asset_loader.dart";
import "../screens/photo_viewer_screen.dart";
import "../widgets/photo_tile.dart";
import "../widgets/pinch_detector.dart";

// Column-count bounds enforced on every pinch event.
const int kMinColumns = 2;
const int kMaxColumns = 7;

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

  // Live column count; mutated by pinch gestures.
  int _currentColumnCount = kInitialColumnCount;

  // True while two fingers are on screen. Used to freeze the scroll view so
  // the GridView doesn't fight the pinch gesture for the same touch events.
  bool _isPinching = false;

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

  // ── pinch callbacks ────────────────────────────────────────────────────────

  /// Adjusts [_currentColumnCount] by [delta] and clamps to valid bounds.
  void _onColumnCountChange(int delta) {
    setState(() {
      _currentColumnCount =
          (_currentColumnCount + delta).clamp(kMinColumns, kMaxColumns);
    });
  }

  /// Freezes / unfreezes the scroll view while two fingers are active.
  ///
  /// Without this, the GridView would try to scroll in response to the same
  /// two-finger move events that PinchDetector is reading, creating jitter.
  void _onPinchActiveChange(bool isActive) {
    setState(() => _isPinching = isActive);
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Gallery"),
        actions: [
          // Debug indicator: shows the live column count without any dev tool.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "$_currentColumnCount cols",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PinchDetector(
              onColumnCountChange: _onColumnCountChange,
              onPinchActiveChange: _onPinchActiveChange,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                // Freeze scrolling while two fingers are active so the
                // GridView does not try to scroll and pinch simultaneously.
                physics: _isPinching
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _currentColumnCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _shuffledPhotoPaths.length,
                itemBuilder: (BuildContext context, int index) {
                  final String imagePath = _shuffledPhotoPaths[index];
                  return PhotoTile(
                    imagePath: imagePath,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotoViewerScreen(
                            allPhotos: _shuffledPhotoPaths,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
