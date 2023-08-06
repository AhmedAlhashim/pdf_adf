import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFDownloader {
  Future<void> downloadPDF(String url) async {
    try {
      final encodedUrl = Uri.encodeFull(url);
      final response = await http.get(Uri.parse(encodedUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/downloaded_file.pdf');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to download PDF');
    }
  }

  Future<String> getLocalFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/downloaded_file.pdf';
  }
}

class PDFViewerScreen extends StatefulWidget {
  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _url = "";
  String? _localFilePath;
  bool _downloadingPDF = false; // Flag to track if the PDF is being downloaded
  bool _showingPDF = false; // Flag to track if the PDF is being shown
  final PDFDownloader _pdfDownloader = PDFDownloader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E8E8E), Color(0xFF05833A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                  width: 400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _url = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter PDF URL',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadingPDF ? null : _downloadPDF,
                    icon: Icon(Icons.download),
                    label: Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFCB9316),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showingPDF ? null : _localFilePath != null ? _showPDF : null,
                    icon: Icon(Icons.open_in_browser),
                    label: Text('Show PDF'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFCB9316),
                    ),
                  ),
                ],
              ),
              if (_downloadingPDF)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              if (_localFilePath != null && _showingPDF)
                Expanded(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 1), // Start from the bottom
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: ModalRoute.of(context)!.animation!,
                      curve: Curves.easeOut,
                    )),
                    child: PDFView(
                      filePath: _localFilePath!,
                      // You can add more configuration options for the PDFView widget as needed
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPDF() async {
    if (_url.isNotEmpty) {
      try {
        setState(() {
          _localFilePath = null; // Reset the local file path
          _downloadingPDF = true; // Set the flag to true when downloading starts
        });
        await _pdfDownloader.downloadPDF(_url);
        final localFilePath = await _pdfDownloader.getLocalFilePath();
        setState(() {
          _localFilePath = localFilePath;
          _downloadingPDF = false; // Set the flag to false when downloading is completed
          _url = ""; // Clear the URL TextField after successful download
        });
      } catch (e) {
        setState(() {
          _downloadingPDF = false; // Set the flag to false on download failure
        });
        // Handle the error, e.g., show an error message
      }
    } else {
      // Show an error message or toast indicating the URL is empty
    }
  }

  Future<void> _showPDF() async {
    setState(() {
      _showingPDF = true; // Set the flag to true when showing the PDF
    });

    // Add a delay to simulate loading time (you can remove this if you don't need it)
    await Future.delayed(Duration(milliseconds: 500));

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        // Wrap the PDFView with a SlideTransition for animation
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1), // Start from the bottom
            end: Offset.zero,
          ).animate(animation),
          child: Scaffold(
            appBar: AppBar(
              title: Text('PDF Viewer'),
            ),
            body: PDFView(
              filePath: _localFilePath!,
              // You can add more configuration options for the PDFView widget as needed
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ));

    setState(() {
      _showingPDF = false; // Set the flag to false when showing the PDF is completed
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: PDFViewerScreen(),
  ));
}
