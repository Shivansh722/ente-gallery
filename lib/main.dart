import "package:flutter/material.dart";

import "app.dart";

void main() {
  // Keep the entrypoint minimal and delegate UI setup to App.
  runApp(const App());
  showDebugBanner: false;
}
