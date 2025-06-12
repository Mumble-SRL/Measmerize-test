import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

class SpMeasmerizeChartScaffold extends StatefulWidget {
  const SpMeasmerizeChartScaffold({
    super.key,
    required this.brandCode,
    required this.productCode,
    required this.languageCode,
    required this.countryCode,
  });

  final String brandCode;
  final String productCode;
  final String languageCode;
  final String countryCode;

  @override
  State<SpMeasmerizeChartScaffold> createState() =>
      _SpMeasmerizeChartScaffoldState();
}

class _SpMeasmerizeChartScaffoldState extends State<SpMeasmerizeChartScaffold> {
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  Future<void> _initWebViewController() async {
    String html = await rootBundle.loadString('assets/measmerize.html');
    html = html.replaceAll('\$BRAND_CODE', widget.brandCode);
    html = html.replaceAll('\$PRODUCT_CODE', widget.productCode);
    html = html.replaceAll('\$LANGUAGE_CODE', widget.languageCode);
    html = html.replaceAll('\$COUNTRY_CODE', widget.countryCode);

    WebViewController webViewController = WebViewController();
    await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    await webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          // You can add any additional logic here if needed
          print(url);
        },
        onHttpError: (error) {
          print(error);
        },
        onNavigationRequest: (request) {
          return NavigationDecision.navigate;
        },
      ),
    );

    if (mounted) {
      try {
        _writeHtml(html);

        webViewController.loadHtmlString(html);
        setState(() {
          _webViewController = webViewController;
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _writeHtml(String html) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/test.html';
    print(path);
    File f = File(path);
    print(f.path);
    await f.writeAsString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Measmerize'),
      ),
      body: _webViewController != null
          ? WebViewWidget(controller: _webViewController!)
          : const SizedBox.shrink(),
    );
  }
}
