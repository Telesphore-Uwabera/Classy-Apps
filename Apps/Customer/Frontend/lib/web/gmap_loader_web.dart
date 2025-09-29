// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void loadGoogleMapsJs(String apiKey) {
  final existing = html.document.getElementById('gmap-sdk');
  if (existing != null) return;
  final script = html.ScriptElement()
    ..id = 'gmap-sdk'
    ..type = 'text/javascript'
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places';
  html.document.head?.append(script);
}


