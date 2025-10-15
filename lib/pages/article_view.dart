import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String articleUrl;
  final String publisherName;

  const ArticleView({super.key, required this.articleUrl, required this.publisherName});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  late final WebViewController _controller;
  var _loadingPercentage = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _loadingPercentage = 0;
              });
            }
          },
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingPercentage = progress / 100;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              setState(() {
                _loadingPercentage = 1.0;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // You can show a snackbar or a different view on error
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.articleUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.publisherName),
        actions: [],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_loadingPercentage < 1.0)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _loadingPercentage,
              )
            )
        ]
      )
    );
  }
}