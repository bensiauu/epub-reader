import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import File from dart:io
import 'reader_screen.dart'; // Import the ReaderScreen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // This will be a simple file picker interface
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<void> openEpub() async {
    // Use file_picker to select an EPUB file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null && result.files.single.path != null) {
      final epubFile = File(result.files.single.path!);

      // Ensure the widget is still mounted before navigating
      if (!mounted) return;

      // Navigate to ReaderScreen and pass the file (with State's BuildContext)
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
        title: const Text('EPUB Reader Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => openEpub(),
          child: const Text('Open EPUB'),
        ),
      ),
    );
  }
}
