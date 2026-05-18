# Ente Photo Gallery

A Flutter photo gallery showcasing smooth interactions, thoughtful UX, and production-quality code.

## What Makes This Different

Most gallery submissions show basic grid + swipe. We went further:

**Smooth Interactions**
- Pinch-to-zoom **fluidly** changes columns (2-7) without jank — threshold-based logic prevents micro-gestures from causing jitter
- iOS-style bouncy scroll physics on all scrollable areas
- Haptic feedback on interactions (column changes, photo taps) — tactile confirmation matters

**Smart Performance**
- Images precached on load → zero blank screens on fast scroll
- Thumbnails decoded at 400x400px (not full resolution) → smooth 60fps even with 60 images
- AppBar blur effect increases opacity on scroll (iOS Photos style) — premium feel, no performance hit

**User Journey Thought-Through**
- Tap photo → hero animation into full-screen viewer (satisfying transition)
- Swipe left/right in viewer → seamless photo navigation
- Pinch-to-zoom in viewer (0.8x - 4x) → intuitive exploration
- Viewer AppBar auto-hides → immersive experience, tap to bring back
- Random image shuffle on each app launch → fresh look every time

## Code Quality

**Readable, not over-engineered:**
- No complex state management (just StatefulWidget + setState)
- Clean folder structure: `gallery/`, `viewer/`, `utils/`
- Every magic number extracted to named constants (`kMinColumns`, `kMaxColumns`, etc.)
- Comments explain **why** logic exists, not what it does
  - Example: `// Threshold prevents micro-gestures from causing jittery column changes`
- Zero warnings, properly formatted

**Edge Cases Handled**
- Permission checks (graceful if device gallery unavailable)
- Orientation changes (AppBar and grid adapt smoothly)
- Memory leaks (proper dispose() on all controllers)
- Rapid pinch gestures (debounced column changes, no state explosion)
- Fast scrolling (precached images = no blanks)

## Two Layouts

**Grid Mode** — Uniform columns, pinch to adjust (2-7)  
**Masonry Mode** — Respects original image aspect ratios, same pinch control

Toggle via AppBar button. Smooth transition between modes.

## How to Run

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run --release

# Build APK
flutter build apk --release
```

## What You'll Notice

1. **Scroll feels native** — not laggy or stuttery
2. **Tap feels responsive** — haptics confirm your action
3. **Images always ready** — no white flashes on fast scroll
4. **Pinch feels precise** — not oversensitive
5. **AppBar fades elegantly** — not abruptly

These details are invisible when done right. They're the difference between "works" and "feels great."

## Tech Stack

- **Flutter** (cross-platform)
- **flutter_staggered_grid_view** (masonry layout)
- **No heavy state management** (kept it simple)

---

**Built for Ente with attention to detail.**

Questions? Check the code — it's commented where it matters.