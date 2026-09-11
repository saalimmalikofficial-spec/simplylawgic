String? extractYoutubeVideoId(String url) {
  final uri = Uri.tryParse(url);

  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  if (uri.host.contains('youtube.com')) {
    if (uri.queryParameters['v'] != null) {
      return uri.queryParameters['v'];
    }

    if (uri.pathSegments.contains('embed')) {
      final index = uri.pathSegments.indexOf('embed');
      if (index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }
  }

  return null;
}