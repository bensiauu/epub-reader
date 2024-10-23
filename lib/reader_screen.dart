import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'dart:io';

class ReaderScreen extends StatefulWidget {
  final File epubFile;

  const ReaderScreen({super.key, required this.epubFile});

  @override
  ReaderScreenState createState() => ReaderScreenState();
}

class ReaderScreenState extends State<ReaderScreen> {
  late Future<EpubBookRef> _epubBookRef;
  int _currentChapterIndex = 0;
  String _chapterContent = '';

  @override
  void initState() {
    super.initState();
    _epubBookRef = _loadEpub(widget.epubFile);
  }

  Future<EpubBookRef> _loadEpub(File epubFile) async {
    var bytes = await epubFile.readAsBytes();
    return await EpubReader.openBook(bytes); // Open the EPUB book lazily
  }

  Future<void> _loadChapter(EpubBookRef bookRef, int chapterIndex) async {
    // Await the TableOfContents items which is a Future
    var tocItems = await bookRef.getChapters(); // Await the future
    if (chapterIndex < tocItems.length) {
      var chapter = await tocItems[chapterIndex].readHtmlContent();
      setState(() {
        _chapterContent = chapter;
        _currentChapterIndex = chapterIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EPUB Reader - Lazy Load'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentChapterIndex > 0) {
                _loadChapterContent(_currentChapterIndex - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              _loadChapterContent(_currentChapterIndex + 1);
            },
          ),
        ],
      ),
      body: FutureBuilder<EpubBookRef>(
        future: _epubBookRef,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading EPUB'));
          } else if (snapshot.hasData) {
            var bookRef = snapshot.data!;
            if (_chapterContent.isEmpty) {
              // Load the first chapter initially
              _loadChapter(bookRef, _currentChapterIndex);
              return const Center(child: CircularProgressIndicator());
            } else {
              return _buildChapterContent();
            }
          } else {
            return const Center(child: Text('No content available.'));
          }
        },
      ),
    );
  }

  Widget _buildChapterContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _chapterContent,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _loadChapterContent(int chapterIndex) async {
    var bookRef = await _epubBookRef;
    // Await the TableOfContents items
    var tocItems = await bookRef.getChapters(); // Await the future
    if (chapterIndex >= 0 && chapterIndex < tocItems.length) {
      _loadChapter(bookRef, chapterIndex);
    }
  }
}
