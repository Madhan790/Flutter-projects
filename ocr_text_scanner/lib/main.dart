import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ocr_text_scanner/pages/upload.dart';
import 'package:ocr_text_scanner/utils/HistoryItemAdapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ocr_text_scanner/providers/theme_provider.dart'; // Import the ThemeProvider
import 'package:ocr_text_scanner/pages/home.dart';
import 'package:ocr_text_scanner/utils/HistoryProvider.dart'; // Import HistoryProvider
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Import EasyLoading

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(HistoryItemAdapter());
  await Hive.initFlutter();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? themeMode = prefs.getString('themeMode');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        // Other providers...
      ],
      child: ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(themeMode),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(), // Ensure EasyLoading is initialized before MaterialApp
          title: 'OCR Text Scanner',
          themeMode: themeProvider.currentTheme.brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          home: HomePage(),
          routes: {
            '/upload': (context) => UploadPage(),
          },
        );
      },
    );
  }
}
