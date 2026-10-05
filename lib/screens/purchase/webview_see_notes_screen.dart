// lib/screens/webview_see_notes_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSeeNotesScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewSeeNotesScreen({
    super.key,
    required this.url,
    this.title = 'Notes',
  });

  @override
  State<WebViewSeeNotesScreen> createState() => _WebViewSeeNotesScreenState();
}

class _WebViewSeeNotesScreenState extends State<WebViewSeeNotesScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => _progress = progress);
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.grey.shade200,
              color: Colors.black87,
              minHeight: 3,
            ),
        ],
      ),
    );
  }
}