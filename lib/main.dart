import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangla PDF Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _createAndOpenBanglaPdf() async {
    try {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // Create a new PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      // Load the Bangla font
      final fontData =
          await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf');
      final List<int> fontBytes = fontData.buffer.asUint8List();
      final PdfFont banglaFont = PdfTrueTypeFont(fontBytes, 12);

      String banglaText = 'আমার নাম পেমেন্ট পদ্ধতি';

      final PdfTextElement textElement = PdfTextElement(
        text: banglaText,
        font: banglaFont,
      );

      textElement.draw(
        page: page,
        bounds: const Rect.fromLTWH(0, 0, 500, 50),
      );

      // Save the document
      List<int> bytes = await document.save();
      document.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/bangla_text.pdf');
      await file.writeAsBytes(bytes);

      print('PDF created at ${file.path}');
      _openPdf(file.path);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _openPdf(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PdfViewerScreen(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bangla PDF Generator"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _createAndOpenBanglaPdf,
          child: const Text("Generate and View Bangla PDF"),
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String path;

  const PdfViewerScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
