import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _pictures = [];
  bool _asPdf = false;
  bool _isPdfResult = false;
  bool _isGalleryImportAllowed = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            SwitchListTile(
              title: const Text("Scan as PDF"),
              subtitle: const Text("Compile pages into a single PDF document"),
              value: _asPdf,
              onChanged: (value) {
                setState(() {
                  _asPdf = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Allow Gallery Import"),
              subtitle: const Text("Import documents from photo library"),
              value: _isGalleryImportAllowed,
              onChanged: (value) {
                setState(() {
                  _isGalleryImportAllowed = value;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: onPressed, child: const Text("Add Pictures")),
            const SizedBox(height: 20),
            if (_isPdfResult)
              for (var picture in _pictures)
                Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      OpenFile.open(picture);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            picture,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.open_in_new,
                                  size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                "Tap to open PDF",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            else
              for (var picture in _pictures) Image.file(File(picture))
          ],
        )),
      ),
    );
  }

  void onPressed() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures(
              isGalleryImportAllowed: _isGalleryImportAllowed,
              asPdf: _asPdf,
              iosScannerOptions: IosScannerOptions(
                imageFormat: IosImageFormat.jpg,
                jpgCompressionQuality: 0.5,
              )) ??
          [];
      if (!mounted) return;
      setState(() {
        _pictures = pictures;
        _isPdfResult = _asPdf;
      });
    } catch (exception) {
      // Handle exception here
    }
  }
}
