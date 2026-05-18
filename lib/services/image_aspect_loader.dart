import "dart:async";

import "package:flutter/widgets.dart";

//this file:
// loads every asset image,
// measures its width/height,
// computes a width/height ratio for each path,
// reports progress,
// and returns a map of imagePath -> aspectRatio.

//string -> path, double -> aspect ratio
Future<Map<String, double>> loadImageAspectRatios(
  List<String> imagePaths, {
  void Function(int loadedCount, int totalCount)? onProgress,
}) async {
  final Map<String, double> aspectRatios = <String, double>{};
  int loadedCount = 0;
  final int totalCount = imagePaths.length;

//call the progress callback with the initial state (0 loaded) so the UI can show an accurate progress indicator from the start
  onProgress?.call(loadedCount, totalCount);

//for each image path, resolve the image and compute its aspect ratio, storing results in a map and updating progress
  final List<Future<void>> tasks = imagePaths.map((String path) async {
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    // using Image.asset to leverage Flutter's image caching
    final ImageStream stream =
        Image.asset(path).image.resolve(const ImageConfiguration());

    late final ImageStreamListener listener;


    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    final ImageInfo info = await completer.future;
    final int height = info.image.height;
    final double ratio =
        height == 0 ? 1.0 : info.image.width / info.image.height;
    aspectRatios[path] = ratio;

    loadedCount += 1;
    onProgress?.call(loadedCount, totalCount);
  }).toList();

//waits for all aspect ratio compute to comp b4 returning the results
  await Future.wait(tasks);

  return aspectRatios;
}

