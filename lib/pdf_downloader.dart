import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFDownloader {
  // This function downloads a PDF file from a web link.
  Future<void> downloadPDF(String url) async {
    try {
      // Prepare the web link to handle any special characters.
      final encodedUrl = Uri.encodeFull(url);

      // Connect to the web link and fetch the PDF data.
      final response = await http.get(Uri.parse(encodedUrl));

      // Check if the data was fetched successfully (HTTP status code 200).
      if (response.statusCode == 200) {
        // Get the place where the app can store files.
        final dir = await getApplicationDocumentsDirectory();

        // Create a file to save the PDF data.
        final file = File('${dir.path}/downloaded_file.pdf');

        // Store the PDF data into the file.
        await file.writeAsBytes(response.bodyBytes);
      } else {
        // If fetching data fails, throw an exception.
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      // If any problems occur, show an error message and raise an exception.
      print('Error: ${e.toString()}');
      throw Exception('Failed to download PDF');
    }
  }

  // This function figures out where the downloaded PDF file is located.
  Future<String> getLocalFilePath() async {
    // Get the place where the app can store files.
    final dir = await getApplicationDocumentsDirectory();

    // Return the full path to the downloaded PDF file.
    return '${dir.path}/downloaded_file.pdf';
  }
}
