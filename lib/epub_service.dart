import 'package:epubx/epubx.dart';
import 'dart:io';

class EpubService {
  // Load the EPUB book lazily
  Future<EpubBookRef> loadEpub(File epubFile) async {
    var bytes = await epubFile.readAsBytes();
    var epubBookRef = await EpubReader.openBook(bytes);
    return epubBookRef;
  }

  // Load chapter content lazily and handle missing content
  Future<String?> loadChapter(EpubBookRef bookRef, int chapterIndex) async {
    var chapters = await bookRef.getChapters();

    if (chapterIndex < chapters.length) {
      var chapter = chapters[chapterIndex];
      var content = await _getChapterWithSubchaptersContent(bookRef, chapter);
      return content;
    }

    return 'No content available.';
  }

  // Recursively concatenate the content of a chapter and its subchapters
  Future<String> _getChapterWithSubchaptersContent(
      EpubBookRef bookRef, EpubChapterRef chapter) async {
    // Initialize an empty string to hold the full content
    var fullContent = '';

    // Load the content of the main chapter
    var contentFileName = chapter.ContentFileName;
    if (contentFileName != null) {
      var htmlContentFile = bookRef.Content?.Html?[contentFileName];
      if (htmlContentFile != null) {
        var content = await htmlContentFile.ReadContentAsync();
        if (content.isNotEmpty) {
          fullContent += content;
        }
      }
    }

    // Recursively load the content of subchapters, if any
    for (var subchapter in chapter.SubChapters!) {
      var subchapterContent =
          await _getChapterWithSubchaptersContent(bookRef, subchapter);
      fullContent += subchapterContent;
    }

    return fullContent;
  }
}
