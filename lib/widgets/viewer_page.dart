import "package:flutter/material.dart";

const double kMinScale = 0.8;
const double kMaxScale = 4.0;

class ViewerPage extends StatelessWidget {
  const ViewerPage({required this.imagePath, super.key});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // Each page is responsible only for rendering a single photo.
    // The PageView handles paging, while InteractiveViewer owns zoom/pan.
    return Center(
      child: Hero(
        // Hero tag must match between grid tile and viewer for smooth transition
        tag: imagePath,
        child: InteractiveViewer(
          minScale: kMinScale,
          maxScale: kMaxScale,
          // InteractiveViewer keeps focus on the image while allowing zoom.
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
