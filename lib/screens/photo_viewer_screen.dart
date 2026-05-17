import "dart:async";

import "package:flutter/material.dart";

import "../widgets/viewer_page.dart";

const Duration kAppBarAutoHideDuration = Duration(seconds: 3);

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    required this.allPhotos,
    required this.initialIndex,
    super.key,
  });

  final List<String> allPhotos;
  final int initialIndex;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isAppBarVisible = true;
  Timer? _appBarTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Start the auto-hide timer as soon as the viewer opens.
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _appBarTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAutoHide() {
    _appBarTimer?.cancel();
    _appBarTimer = Timer(kAppBarAutoHideDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _isAppBarVisible = false);
    });
  }

  void _showAppBar() {
    if (!mounted) {
      return;
    }
    setState(() => _isAppBarVisible = true);
    _scheduleAutoHide();
  }

  void _onPageChanged(int index) {
    if (!mounted) {
      return;
    }
    setState(() => _currentIndex = index);
    // Swiping should refresh the timer so the user has time to read the count.
    _scheduleAutoHide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // The full-screen PageView handles swipe navigation.
          GestureDetector(
            onTap: _showAppBar,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allPhotos.length,
              onPageChanged: _onPageChanged,
              // Snap ensures clean page transitions, not half-photos
              pageSnapping: true,
              itemBuilder: (BuildContext context, int index) {
                return ViewerPage(imagePath: widget.allPhotos[index]);
              },
            ),
          ),
          // The overlay AppBar fades away to keep the photo immersive.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: IgnorePointer(
                ignoring: !_isAppBarVisible,
                child: AnimatedOpacity(
                  opacity: _isAppBarVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    height: kToolbarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "${_currentIndex + 1} / ${widget.allPhotos.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Spacer keeps the counter centered relative to back button.
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
