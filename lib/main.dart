import 'package:flutter/material.dart';
import 'reader_screen.dart';  // Import the ReaderScreen widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPUB Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),  // This will be a simple file picker interface
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<void> openEpub(BuildContext context) async {
    // Use a package like file_picker or path_provider to select an EPUB file
    // Example using file_picker (you need to add file_picker as a dependency)
    import 'package:file_picker/file_picker.dart';
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null && result.files.single.path != null) {
      final epubFile = File(result.files.single.path!);
      // Navigate to ReaderScreen and pass the file
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReaderScreen(epubFile: epubFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EPUB Reader Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => openEpub(context),
          child: Text('Open EPUB'),
        ),
      ),
    );
  }
}
