import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((x) => setState(() {}));
  }

  static int OCR_CAM = FlutterMobileVision.CAMERA_BACK;
  static String word = "TEXT";

  Future<Null> _read() async {
    List<OcrText> texts = [];

    try {
      texts = await FlutterMobileVision.read(
        multiple: true,
        camera: OCR_CAM,
        waitTap: false,
        preview: FlutterMobileVision.PREVIEW,
      );
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }
    if (!mounted) return;
    setState(() {});
  }

  void backpressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backpressed(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scan Using Camera"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: InkWell(
              onTap: () {
                _read();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                height: 40,
                width: 400,
                child: Center(
                  child: Text(
                    "Scan Using Camera",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
