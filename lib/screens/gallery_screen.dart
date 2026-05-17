import "package:flutter/material.dart";

import "../services/asset_loader.dart";
import "../services/image_aspect_loader.dart";
import "../screens/photo_viewer_screen.dart";
import "../widgets/gallery_grid.dart";
import "../widgets/gallery_masonry.dart";

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
  bool _isLoadingPhotos = true;
  bool _isLoadingAspectRatios = true;

  Map<String, double>? _aspectRatios;
  int _aspectRatiosLoaded = 0;
  int _aspectRatiosTotal = 0;

  bool _isMasonryMode = false;

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
      _isLoadingPhotos = false;
      _isLoadingAspectRatios = true;
      _aspectRatiosLoaded = 0;
      _aspectRatiosTotal = shuffledPhotoPaths.length;
    });

    // Preload aspect ratios to avoid layout jank during scroll
    await _loadAspectRatios(shuffledPhotoPaths);
  }

  Future<void> _loadAspectRatios(List<String> photoPaths) async {
    final Map<String, double> ratios = await loadImageAspectRatios(
      photoPaths,
      onProgress: (int loadedCount, int totalCount) {
        if (!mounted) {
          return;
        }

        setState(() {
          _aspectRatiosLoaded = loadedCount;
          _aspectRatiosTotal = totalCount;
        });
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _aspectRatios = ratios;
      _isLoadingAspectRatios = false;
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
          IconButton(
            icon: Icon(
              _isMasonryMode ? Icons.view_module : Icons.dashboard,
            ),
            tooltip: _isMasonryMode ? "Show grid" : "Show masonry",
            onPressed: () {
              setState(() => _isMasonryMode = !_isMasonryMode);
            },
          ),
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final bool isLoading =
        _isLoadingPhotos || _isLoadingAspectRatios || _aspectRatios == null;
    final bool showDeterminate =
        _isLoadingAspectRatios && _aspectRatiosTotal > 0;
    final double? progressValue = showDeterminate
        ? _aspectRatiosLoaded / _aspectRatiosTotal
        : null;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(value: progressValue),
      );
    }

    final void Function(int index) onPhotoTap = (int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoViewerScreen(
            allPhotos: _shuffledPhotoPaths,
            initialIndex: index,
          ),
        ),
      );
    };

    if (_isMasonryMode) {
      return GalleryMasonry(
        photos: _shuffledPhotoPaths,
        aspectRatios: _aspectRatios!,
        columnCount: _currentColumnCount,
        isPinching: _isPinching,
        onColumnCountChange: _onColumnCountChange,
        onPinchActiveChange: _onPinchActiveChange,
        onPhotoTap: onPhotoTap,
      );
    }

    return GalleryGrid(
      photos: _shuffledPhotoPaths,
      columnCount: _currentColumnCount,
      isPinching: _isPinching,
      onColumnCountChange: _onColumnCountChange,
      onPinchActiveChange: _onPinchActiveChange,
      onPhotoTap: onPhotoTap,
    );
  }
}
