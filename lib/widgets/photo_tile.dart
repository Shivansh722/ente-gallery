import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    required this.imagePath,
    this.aspectRatio,
    this.onTap,
    super.key,
  });

  final String imagePath;
  final double? aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double effectiveAspectRatio = aspectRatio ?? 1.0;
    return GestureDetector(
      onTap: () {
        if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) {
          // Haptic feedback provides tactile confirmation of interaction
          HapticFeedback.lightImpact();
        }
        onTap?.call();
      },
      child: Hero(
        // Hero tag must match between grid tile and viewer for smooth transition
        tag: imagePath,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: effectiveAspectRatio,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              cacheHeight: 400,
              cacheWidth: 400,
              frameBuilder: (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }

                final Widget content = frame == null
                    ? Container(color: Colors.grey.shade800)
                    : child;

                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: content,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
