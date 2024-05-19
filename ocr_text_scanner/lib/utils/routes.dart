import 'package:flutter/material.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';
import 'package:ocr_text_scanner/pages/DetailViewPage.dart';
import 'package:ocr_text_scanner/pages/home.dart';
import 'package:ocr_text_scanner/utils/scan.dart';
import 'package:ocr_text_scanner/pages/upload.dart';

class MyRoutes {
  static const String homePage = '/';
  static const String scanPage = '/scan';
  static const String uploadPage = '/upload';
  static const String detailViewPage = '/detail_view';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(builder: (_) => HomePage());
      case scanPage:
        return MaterialPageRoute(builder: (_) => ScanPage());
      case uploadPage:
        return MaterialPageRoute(builder: (_) => UploadPage());
      case detailViewPage:
      // Extract the HistoryItem object passed as arguments
        final args = settings.arguments;
        // Ensure that the arguments are of type HistoryItem
        if (args is HistoryItem) {
          // Pass the HistoryItem object as an argument to DetailViewPage
          return MaterialPageRoute(builder: (_) => DetailViewPage(historyItem: args));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }


  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Page not found'),
        ),
      );
    });
  }
}
