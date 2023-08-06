import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// This method DOES NOT WORK FAST so I disabled it

class PDFViewer extends StatelessWidget {
  final String pdfUrl;

  PDFViewer({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Color(0xFFCB9316),
      ),
      body: Center(  // Wrap PDFView with Center widget
        child: PDFView(
          filePath: pdfUrl,
          // You can add more configuration options for the PDFView widget as needed
        ),
      ),
    );
  }
}