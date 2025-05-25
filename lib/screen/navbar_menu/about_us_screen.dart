import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final ByteData data = await rootBundle.load("assets/about_us/about_us.pdf");
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File("${tempDir.path}/about_us.pdf");

    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us")),
      body: localPath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            ),
    );
  }
}
