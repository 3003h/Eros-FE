import 'dart:math';

import '../index.dart';

final RegExp _chapterPageExp = RegExp(r'^[Pp]?(\d+)\s*[-・·*]?\s+(.*)$');
final RegExp _chapterNameExp = RegExp(r'^(.+?)[….\-・·*]{3,}(.+)$');

// class Chapter {
//   Chapter({required this.page, required this.author, this.title});
//
//   final int page;
//   final String author;
//   final String? title;
//
//   @override
//   String toString() =>
//       "P${page.toString().padLeft(3, '0')} . $author" +
//       (title != null ? ' ... $title' : '');
// }

class ChapterFindData {
  ChapterFindData({
    required this.chapter,
    required this.page,
    required this.pageSize,
    this.nextChapter,
  });

  final Chapter chapter;
  final Chapter? nextChapter;
  final int page;
  final int pageSize;

  int get inChapterPage => page - chapter.page + 1;

  int get inChapterPageSize => (nextChapter?.page ?? pageSize) - chapter.page;

  int get startPage => chapter.page;

  int get endPage =>
      max(startPage, nextChapter == null ? pageSize : nextChapter!.page - 1);
}

extension ChapterList on List<Chapter> {
  ChapterFindData? findByPage(int page, int pageSize) {
    final nowIndex = lastIndexWhere((element) => element.page <= page);
    if (nowIndex == -1) return null;
    final nextIndex = nowIndex + 1;
    Chapter? nextChapter;
    final nowChapter = this[nowIndex];
    if (nextIndex < length) {
      nextChapter = this[nextIndex];
    }
    return ChapterFindData(
      chapter: nowChapter,
      nextChapter: nextChapter,
      page: page,
      pageSize: pageSize,
    );
  }
}

List<Chapter> parseChapter(String code) {
  final List<Chapter> result = [];

  for (final line in code.split('\n')) {
    final matchResult = _chapterPageExp.firstMatch(line.trim());
    if (matchResult == null) continue;
    final page = int.parse(matchResult.group(1)!);
    final name = matchResult.group(2) ?? '';
    String? title;
    var author = name;
    final nameMatchResult = _chapterNameExp.firstMatch(name.trim());
    if (nameMatchResult != null) {
      author = nameMatchResult.group(1)!;
      title = nameMatchResult.group(2);
    }

    result.add(Chapter(page: page, title: title, author: author));
  }

  result.sort((a, b) => a.page - b.page);

  return result;
}
