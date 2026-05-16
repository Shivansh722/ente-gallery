import "package:flutter/material.dart";

class PhotoTile extends StatelessWidget {
  const PhotoTile({required this.imagePath, super.key});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // Enforce a square tile so the grid feels uniform.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
