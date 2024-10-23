import 'package:epubx/epubx.dart';
import 'dart:io';

class EpubService {
  Future<EpubBook> loadEpub(File epubFile) async {
    var bytes = await epubFile.readAsBytes();
    var epubBook = await EpubReader.readBook(bytes);
    return epubBook;
  }
}
