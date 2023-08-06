import 'dart:io';
import 'dart:async';
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
