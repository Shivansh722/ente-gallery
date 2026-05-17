import "dart:math" as math;

import "package:flutter/material.dart";

const double kMinScale = 1.0;
const double kMaxScale = 8.0;

// Google Photos zooms to this scale on first double-tap.
const double kDoubleTapZoomScale = 2.5;
const Duration kDoubleTapAnimDuration = Duration(milliseconds: 220);

class ViewerPage extends StatefulWidget {
  const ViewerPage({
    required this.imagePath,
    required this.onInteractionChanged,
    required this.onScaleChanged,
    required this.onTap,
    super.key,
  });

  final String imagePath;

  /// Called with `true` when a multi-touch gesture starts, `false` when it
  /// ends.  The parent uses this to freeze [PageView] paging.
  final ValueChanged<bool> onInteractionChanged;

  /// Fired on every scale change so the parent can track whether this page
  /// is currently zoomed in.
  final ValueChanged<double> onScaleChanged;

  /// Single-tap callback; forwarded to the parent to toggle the app bar.
  final VoidCallback onTap;

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage>
    with SingleTickerProviderStateMixin {
  late final TransformationController _controller;
  late final AnimationController _animController;
  Animation<Matrix4>? _animation;

  // Raw pointer count tracked via [Listener] so we can lock the [PageView]
  // the instant a second finger touches down — before the gesture arena
  // resolves — preventing the horizontal swipe from stealing the pinch.
  int _pointerCount = 0;

  // Captured in onDoubleTapDown so the zoom centres on the tap location.
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _animController = AnimationController(
      vsync: this,
      duration: kDoubleTapAnimDuration,
    )
      ..addListener(_onAnimTick)
      ..addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── Animation ──────────────────────────────────────────────────────────────

  void _onAnimTick() {
    _controller.value = _animation!.value;
    _reportScale();
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      // Animation finished — unlock interaction state.
      // The parent's _isCurrentPageZoomed guard keeps the PageView locked
      // as long as the scale remains above 1×.
      widget.onInteractionChanged(false);
      _reportScale();
    }
  }

  void _reportScale() {
    widget.onScaleChanged(_controller.value.getMaxScaleOnAxis());
  }

  // ── Raw pointer tracking ───────────────────────────────────────────────────
  // [Listener] fires before the gesture arena, so we can lock the [PageView]
  // at the moment the second finger lands without waiting for a winner.

  void _onPointerDown(PointerDownEvent event) {
    _pointerCount++;
    if (_pointerCount >= 2) {
      // Stop any running double-tap animation and take over immediately.
      if (_animController.isAnimating) _animController.stop();
      widget.onInteractionChanged(true);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointerCount = math.max(0, _pointerCount - 1);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointerCount = math.max(0, _pointerCount - 1);
  }

  // ── InteractiveViewer callbacks ────────────────────────────────────────────

  void _onInteractionStart(ScaleStartDetails details) {
    if (_animController.isAnimating) _animController.stop();
    widget.onInteractionChanged(true);
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    _reportScale();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    _reportScale();
    // Always unlock here; the parent keeps paging frozen via
    // _isCurrentPageZoomed as long as scale > 1.
    widget.onInteractionChanged(false);
  }

  // ── Double-tap zoom ────────────────────────────────────────────────────────

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    final double current = _controller.value.getMaxScaleOnAxis();

    final Matrix4 start = _controller.value.clone();
    final Matrix4 end = current > 1.05
        ? Matrix4.identity() // already zoomed → zoom back to fit
        : _buildZoomMatrix(_doubleTapPosition, kDoubleTapZoomScale);

    _animation = Matrix4Tween(begin: start, end: end)
        .animate(CurvedAnimation(
          parent: _animController,
          curve: Curves.easeInOutCubic,
        ));

    // Lock paging for the duration of the animation.
    widget.onInteractionChanged(true);
    _animController.forward(from: 0);
  }

  /// Returns a [Matrix4] that zooms to [scale] while keeping the point at
  /// [focalPoint] (local/viewport coordinates) visually stationary.
  ///
  /// Math: let S = scene-point under the finger (inverse of current transform).
  /// The new matrix must satisfy:  new_matrix * S = focalPoint.
  /// → new_matrix = T(focalPoint − S·scale) × Scale(scale)
  /// which transforms a vector as: translate( scale(v) ) — scale first, then
  /// shift, so the focal point stays fixed on screen.
  Matrix4 _buildZoomMatrix(Offset focalPoint, double scale) {
    final Offset scenePoint = _controller.toScene(focalPoint);
    final double tx = focalPoint.dx - scenePoint.dx * scale;
    final double ty = focalPoint.dy - scenePoint.dy * scale;
    // Matrix4.translationValues gives T; multiply by the scale matrix S.
    // Result is T * S, i.e. vectors are scaled then translated.
    return Matrix4.translationValues(tx, ty, 0)
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Hero(
          tag: widget.imagePath,
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: GestureDetector(
              // onTap and onDoubleTap live in the same recognizer so Flutter
              // correctly waits for the double-tap window before firing onTap,
              // and cancels the single-tap when a double-tap is detected.
              onTap: widget.onTap,
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: _onDoubleTap,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: kMinScale,
                maxScale: kMaxScale,
                onInteractionStart: _onInteractionStart,
                onInteractionUpdate: _onInteractionUpdate,
                onInteractionEnd: _onInteractionEnd,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
