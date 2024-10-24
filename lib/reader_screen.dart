import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import flutter_html
import 'package:epubx/epubx.dart';
import 'dart:io';
import 'epub_service.dart'; // Import the EpubService class

class ReaderScreen extends StatefulWidget {
  final File epubFile;

  const ReaderScreen({super.key, required this.epubFile});

  @override
  ReaderScreenState createState() => ReaderScreenState();
}

class ReaderScreenState extends State<ReaderScreen> {
  late Future<EpubBookRef> _epubBookRef;
  late EpubService epubService; // Initialize the EpubService class
  int _currentChapterIndex = 0;
  String _chapterContent = '';

  @override
  void initState() {
    super.initState();
    epubService = EpubService(); // Instantiate the EpubService
    _epubBookRef = epubService
        .loadEpub(widget.epubFile); // Use the EpubService to load the EPUB
  }

  // Refactor to use the EpubService to load chapters
  Future<void> _loadChapterContent(int chapterIndex) async {
    var bookRef = await _epubBookRef;
    var content = await epubService.loadChapter(
        bookRef, chapterIndex); // Use EpubService to load the chapter

    if (content != null && content.isNotEmpty) {
      setState(() {
        _chapterContent = content;
        _currentChapterIndex = chapterIndex;
      });
    } else {
      setState(() {
        _chapterContent = 'No content available for this chapter.';
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
            if (_chapterContent.isEmpty) {
              // Load the first chapter initially
              _loadChapterContent(_currentChapterIndex);
              return const Center(child: CircularProgressIndicator());
            } else {
              return _buildChapterContent(); // Render chapter with HTML
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
      child: Html(
        data: _chapterContent, // Render the HTML content
        style: {
          "body": Style(fontSize: FontSize(16.0)), // Customize styles if needed
        },
      ),
    );
  }
}
