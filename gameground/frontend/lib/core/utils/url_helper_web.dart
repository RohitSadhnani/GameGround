// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation that updates the browser address bar.
void updateBrowserUrl(String path, {String title = 'GameGround'}) {
  html.window.history.replaceState(null, title, '#$path');
  html.document.title = title;
}
