import "package:flutter/material.dart";

class PhotoTile extends StatelessWidget {
  const PhotoTile({required this.imagePath, this.onTap, super.key});

  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Enforce a square tile so the grid feels uniform.
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        // Hero tag must match between grid tile and viewer for smooth transition
        tag: imagePath,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
