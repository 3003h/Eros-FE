import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as pimage;
import 'package:jinja/jinja.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:shared_storage/shared_storage.dart' as ss;

import '../global.dart';

void compactZip(String outputPath, String inputDirPath) {
  loggerTime.d('start compactZip');
  final encoder = ZipFileEncoder();
  encoder.create(outputPath);
  encoder.addDirectory(Directory(inputDirPath), includeDirName: false);
  encoder.close();
  loggerTime.d('end compactZip');
}

void isolateCompactDirToZip(List<String> para) {
  final outputPath = para[0];
  final inputDirPath = para[1];
  final encoder = ZipFileEncoder();
  encoder.create(outputPath);
  encoder.addDirectory(Directory(inputDirPath), includeDirName: false);
  encoder.close();
}

Future<String> buildEpub(GalleryTask task, {String? tempPath}) async {
  final _tempPath =
      tempPath ?? path.join(Global.extStoreTempPath, 'export_epub_temp');

  Directory _tempDir = Directory(_tempPath);
  if (_tempDir.existsSync()) {
    _tempDir.deleteSync(recursive: true);
  }
  _tempDir.createSync(recursive: true);

  final metaPath = path.join(_tempPath, 'META-INF');
  _createDir(metaPath);

  // OEBPS 目录创建
  final oebpsPath = path.join(_tempPath, 'OEBPS');
  _createDir(oebpsPath);

  final contentPath = path.join(oebpsPath, 'content');
  _createDir(contentPath);

  final resourcesPath = path.join(contentPath, 'resources');
  _createDir(resourcesPath);

  // mimetype
  final fileMimetype = File(path.join(_tempPath, 'mimetype'));
  fileMimetype.writeAsStringSync('application/epub+zip\n');

  // css 创建
  final cssText = await rootBundle
      .loadString('assets/templates/epub/OEBPS/content/resources/index_0.css');
  final fileCss = File(path.join(resourcesPath, 'index_0.css'));
  fileCss.writeAsStringSync(cssText);

  // container
  final containerText = await rootBundle
      .loadString('assets/templates/epub/META-INF/container.xml');
  final fileContainer = File(path.join(metaPath, 'container.xml'));
  fileContainer.writeAsStringSync(containerText);

  late final Uint8List imageData;
  late final String coverName;
  late final String name;
  late final List<Map<String, String>> fileNameList;

  // 画廊图片
  if (task.realDirPath?.isContentUri ?? false) {
    const columns = <ss.DocumentFileColumn>[
      ss.DocumentFileColumn.displayName,
      ss.DocumentFileColumn.id,
    ];

    final Stream<ss.DocumentFile> onFileLoaded =
        ss.listFiles(Uri.parse(task.realDirPath!), columns: columns);

    final List<ss.DocumentFile> fileList = (await onFileLoaded.toList())
        .whereNot((e) => e.name?.startsWith('.') ?? false)
        .toList();
    imageData = (await fileList.first.getContent())!;
    coverName = '#cover${path.extension(fileList.first.name!)}';
    name = fileList.first.name!.toLowerCase();

    // 模板数据
    fileNameList = fileList
        .map(
          (e) => {
            'withoutExtension': path.basenameWithoutExtension(e.name!),
            'name': path.basename(e.name!),
            'extension': path.extension(e.name!) == '.jpg'
                ? 'jpeg'
                : path.extension(e.name!).split('.').last.toLowerCase(),
          },
        )
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    // 图片复制到 resourcesPath
    for (final domFile in fileList) {
      final _file =
          File(path.join(resourcesPath, path.basename(domFile.name!)));
      final _fileData = await domFile.getContent();
      if (_fileData != null) {
        _file.writeAsBytesSync(_fileData);
      }
    }
  } else {
    final _galleryDir = Directory(task.realDirPath!);
    final List<File> fileList = _galleryDir
        .listSync()
        .whereType<File>()
        .where((element) => !path.basename(element.path).startsWith('.'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // 封面图片数据
    imageData = fileList.first.readAsBytesSync();
    coverName = '#cover${path.extension(fileList.first.path)}';
    name = fileList.first.path.toLowerCase();

    // 模板数据
    fileNameList = fileList
        .map(
          (e) => {
            'withoutExtension': path.basenameWithoutExtension(e.path),
            'name': path.basename(e.path),
            'extension': path.extension(e.path) == '.jpg'
                ? 'jpeg'
                : path.extension(e.path).split('.').last.toLowerCase(),
          },
        )
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    // 图片复制到 resourcesPath
    for (final file in fileList) {
      File(file.path)
          .copySync(path.join(resourcesPath, path.basename(file.path)));
    }
  }

  final image = pimage.decodeImage(imageData);
  if (image == null) {
    throw EhError(error: 'read image error');
  }

  final paletteGenerator = await PaletteGenerator.fromImageProvider(
    MemoryImage(imageData),
    maximumColorCount: 20,
  );

  // 获取主色
  final dColor = paletteGenerator.darkMutedColor?.color ?? Colors.black;

  final backgroundImage =
      pimage.Image(image.width, (image.width * 4 / 3).round()).fill(
    pimage.Color.fromRgba(dColor.red, dColor.green, dColor.blue, dColor.alpha),
  );

  final pimage.Image cover = pimage.copyResize(
      pimage.copyInto(backgroundImage, image, center: true),
      width: 1200);

  logger.d('${cover.width} ${cover.height}');

  final List<int> coverImage = name.endsWith('.jpg') || name.endsWith('.jpeg')
      ? pimage.encodeJpg(cover, quality: 80)
      : pimage.encodeNamedImage(cover, name)!;
  File(path.join(resourcesPath, coverName)).writeAsBytesSync(coverImage);

  // 模板操作
  final environment = Environment();

  // index 模板内容读取
  final indexTemplateText = await rootBundle
      .loadString('assets/templates/epub/OEBPS/content/index.html.tpl');
  final indexTemplate = environment.fromString(indexTemplateText);

  // metadata 模板内容读取
  final metadataTemplateText = await rootBundle
      .loadString('assets/templates/epub/OEBPS/metadata.xml.tpl');
  final metadataTemplate = environment.fromString(metadataTemplateText);

  // toc 模板内容读取
  final tocTemplateText =
      await rootBundle.loadString('assets/templates/epub/OEBPS/toc.ncx.tpl');
  final tocTemplate = environment.fromString(tocTemplateText);

  // 写入index
  for (final _imgFile in fileNameList) {
    final _xhtml = indexTemplate.render(
      fileName: _imgFile['name'],
    );
    final _xhtmlFile = File(
        path.join(contentPath, 'index_${_imgFile['withoutExtension']}.xhtml'));
    _xhtmlFile.createSync(recursive: true);
    _xhtmlFile.writeAsStringSync('$_xhtml');
  }

  // 写入 metadata.opf
  final metadata = metadataTemplate.render(
      title: htmlEscape.convert(task.title.shortTitle),
      fileNameList: fileNameList,
      coverName: coverName,
      coverExtension: path.extension(coverName) == '.jpg'
          ? 'jpeg'
          : path.extension(coverName).split('.').last.toLowerCase());
  final metadataFile = File(path.join(oebpsPath, 'metadata.opf'));
  metadataFile.createSync();
  metadataFile.writeAsStringSync('$metadata');

  // 写入 toc.ncx
  final toc = tocTemplate.render();
  final tocFile = File(path.join(oebpsPath, 'toc.ncx'));
  tocFile.createSync();
  tocFile.writeAsStringSync('$toc');

  return _tempPath;
}

void _createDir(String path) {
  final _dir = Directory(path);
  if (!_dir.existsSync()) {
    _dir.createSync(recursive: true);
  }
}
