import "package:flutter/material.dart";

// Threshold prevents micro-gestures from causing jittery column changes.
// 0.15 means fingers must spread/close ~15% from the baseline distance
// before a column-count step fires. Lower = twitchy; higher = sluggish.
const double kPinchThreshold = 0.15;

/// Detects two-finger pinch gestures without interfering with single-finger
/// scrolling.
///
/// ### Why [Listener] instead of [GestureDetector]?
/// [GestureDetector] with `onScale*` callbacks enters the **gesture arena**
/// and competes with the [GridView]'s vertical-drag recognizer.  On any
/// ambiguous frame the arena picks a winner and the loser is silenced —
/// causing either the scroll or the pinch to drop events and feel janky.
///
/// [Listener] receives **raw pointer events before the arena runs**.  It
/// never claims ownership, so single-finger drags pass untouched to the
/// scroll view while we can still observe all pointer positions for
/// two-finger distance math.
///
/// ### Column-count direction
/// - Fingers **spreading** (distance grows, scale > 1) → zoom **in** → fewer columns.
/// - Fingers **closing**  (distance shrinks, scale < 1) → zoom **out** → more columns.
class PinchDetector extends StatefulWidget {
  const PinchDetector({
    required this.child,
    required this.onColumnCountChange,
    this.onPinchActiveChange,
    super.key,
  });

  final Widget child;

  /// Fired with -1 (pinch-out / zoom in) or +1 (pinch-in / zoom out).
  final void Function(int delta) onColumnCountChange;

  /// Fired with `true` when a second finger lands and `false` when it lifts.
  /// Use this to freeze the scroll view during active pinching.
  final void Function(bool isActive)? onPinchActiveChange;

  @override
  State<PinchDetector> createState() => _PinchDetectorState();
}

class _PinchDetectorState extends State<PinchDetector> {
  // Maps each pointer ID to its current screen position.
  final Map<int, Offset> _pointers = {};

  // Inter-finger distance at the start of each discrete pinch step.
  // Reset after every threshold crossing so steps are independent.
  double? _baselineDistance;

  bool _pinchActive = false;

  // ── pointer lifecycle ──────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) {
      // Capture the starting spread the moment the second finger lands.
      _baselineDistance = _distanceBetweenPointers();
      if (!_pinchActive) {
        _pinchActive = true;
        widget.onPinchActiveChange?.call(true);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;

    if (_pointers.length >= 2 &&
        _baselineDistance != null &&
        _baselineDistance! > 0) {
      // Scale is the ratio of current spread to baseline spread.
      final double scale = _distanceBetweenPointers() / _baselineDistance!;
      _handlePinchGesture(scale - 1.0);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    _onFingerLifted();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointers.remove(event.pointer);
    _onFingerLifted();
  }

  void _onFingerLifted() {
    if (_pointers.length < 2) {
      _baselineDistance = null;
      if (_pinchActive) {
        _pinchActive = false;
        widget.onPinchActiveChange?.call(false);
      }
    }
  }

  // ── math ──────────────────────────────────────────────────────────────────

  double _distanceBetweenPointers() {
    final List<Offset> pts = _pointers.values.toList();
    return (pts[0] - pts[1]).distance;
  }

  // ── gesture interpretation ─────────────────────────────────────────────────

  /// Converts a raw scale delta into a discrete -1 / +1 column change.
  ///
  /// [scaleDelta] = (currentSpread / baselineSpread) - 1.0
  ///   Positive → fingers spreading → zoom in → FEWER columns → emit -1
  ///   Negative → fingers closing  → zoom out → MORE  columns → emit +1
  void _handlePinchGesture(double scaleDelta) {
    if (scaleDelta > kPinchThreshold) {
      widget.onColumnCountChange(-1);
      // Advance baseline so the next step is measured fresh from here.
      _baselineDistance = _distanceBetweenPointers();
    } else if (scaleDelta < -kPinchThreshold) {
      widget.onColumnCountChange(1);
      _baselineDistance = _distanceBetweenPointers();
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
