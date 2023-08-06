import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'pdf_downloader.dart';
import 'pdf_viewer.dart';
import 'pdf_action_button.dart';

class PDFViewerScreen extends StatefulWidget {
  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _pdfUrl = '';
  String? _localFilePath;
  bool _isDownloading = false;
  bool _isPDFShown = false;
  final PDFDownloader _pdfDownloader = PDFDownloader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFF05833A)],
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
                      _pdfUrl = value;
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
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PDFActionButton(
                      onPressed: _isDownloading ? null : _onActionButtonPressed,
                      icon: _isPDFShown ? Icons.open_in_browser : Icons.download,
                      label: _isPDFShown ? 'Show PDF' : 'Download & Show PDF',
                    ),
                    SizedBox(width: 16),

                    // This button DOES NOT WORK FAST
                    // PDFActionButton(
                    //   onPressed: _pdfUrl.isNotEmpty ? _showPDFDirectly : null,
                    //   icon: Icons.open_in_new,
                    //   label: 'Show PDF Directly',
                    // ),
                  ],
                ),
              ),
              if (_isDownloading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              if (_localFilePath != null && _isPDFShown)
                Expanded(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 1),
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

  Future<void> _onActionButtonPressed() async {
    if (_isPDFShown) {
      _showPDF();
    } else {
      await _downloadAndShowPDF();
    }
  }

  Future<void> _downloadAndShowPDF() async {
    if (_pdfUrl.isNotEmpty) {
      try {
        setState(() {
          _localFilePath = null;
          _isDownloading = true;
        });
        await _pdfDownloader.downloadPDF(_pdfUrl);
        final localFilePath = await _pdfDownloader.getLocalFilePath();
        setState(() {
          _localFilePath = localFilePath;
          _isDownloading = false;
          _isPDFShown = true;
          _pdfUrl = '';
        });
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });
        // Handle the error, e.g., show an error message
      }
    } else {
      // Show an error message or toast indicating the URL is empty
    }
  }

  Future<void> _showPDF() async {
    setState(() {
      _isPDFShown = true; // Set the flag to true when showing the PDF
    });

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1), // Start from the bottom
            end: Offset.zero,
          ).animate(animation),
          child: Scaffold(
            appBar: AppBar(
              title: Text('PDF Viewer'),
              backgroundColor: Color(0xFFCB9316),
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
      _isPDFShown = false; // Set the flag to false when showing the PDF is completed
    });
  }

  void _showPDFDirectly() {
    if (_pdfUrl.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFViewer(pdfUrl: _pdfUrl),
        ),
      );
    } else {
      // Show an error message or toast indicating the URL is empty
    }
  }
}
