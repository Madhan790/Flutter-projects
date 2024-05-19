// upload.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';
import 'package:ocr_text_scanner/utils/HistoryProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  String? _extractedText;
  final picker = ImagePicker();

  Future<void> _imgFromGallery(BuildContext context) async {
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File? croppedFile = await _cropImage(image.path);
        if (croppedFile != null) {
          EasyLoading.show(status: 'Loading...');
          final extractedText = await FlutterTesseractOcr.extractText(croppedFile.path);
          setState(() {
            _imageFile = croppedFile;
            _extractedText = extractedText;
          });

          // Generate text file path
          String time = DateTime.now().millisecondsSinceEpoch.toString();
          Directory directory = await getApplicationDocumentsDirectory();
          String textFilePath = '${directory.path}/history_$time.txt';

          // Create the text file
          File textFile = File(textFilePath);
          await textFile.writeAsString(extractedText);

          // Create a new HistoryItem with the text file path
          HistoryItem newItem = HistoryItem(
            imagePath: croppedFile.path,
            firstLine: extractedText,
            time: time,
            textFilePath: textFilePath,
          );

          // Add the new item to history
          Provider.of<HistoryProvider>(context, listen: false).addToHistory(newItem);

          EasyLoading.dismiss();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print('Error: $e');
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: Platform.isAndroid
          ? [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ]
          : Platform.isIOS
          ? [
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ]
          : [
        WebUiSettings(
          context: context,
        ),
      ],
    );
    // Convert CroppedFile to File
    File? file = croppedFile != null ? File(croppedFile.path) : null;
    return file;
  }

  Widget _buildPreview() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return Text(
        'No image selected.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF8B828D),), // Change text color to white
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Extract text from image",
          style: TextStyle(
            color: Color(0xFF8B828D), // Change text color to white
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme color for background
        iconTheme: IconThemeData(
          color: Color(0xFF8B828D), // Change icon color to white
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor), // Use theme color for background
                    child: Center(child: _buildPreview()),
                    height: 250,
                    width: 650,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _imgFromGallery(context),
                    child: Text('Upload Image'),
                  ),
                  SizedBox(height: 50),
                  Container(
                    color: Colors.grey.shade600,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        color: Colors.grey.shade500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SelectableText(
                            _extractedText ?? 'No text extracted yet.',
                            style: TextStyle(
                              color: Colors.white, // Change text color to white
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: 500,
        height: 10,
        color: Colors.grey.shade800,
      ),
    );
  }
}

