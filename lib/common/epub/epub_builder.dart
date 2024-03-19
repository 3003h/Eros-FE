import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:eros_fe/utils/logger.dart';
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
  late final String filePath;
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
        .toList()
      ..sort((a, b) => a.name!.compareTo(b.name!));
    imageData = (await fileList.first.getContent())!;
    coverName = '#cover${path.extension(fileList.first.name!)}';
    filePath = fileList.first.name!.toLowerCase();

    logger.t('fileList: ${fileList.map((e) => e.name).toList()}');

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
    filePath = fileList.first.path.toLowerCase();

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

  // final backgroundImage = pimage.Image(
  //   width: image.width,
  //   height: (image.width * 4 / 3).round(),
  // );

  // final backgroundImage_ = backgroundImage.fill(
  //   pimage.ColorRgba8(
  //     dColor.red,
  //     dColor.green,
  //     dColor.blue,
  //     dColor.alpha,
  //   ),
  // );

  // final pimage.Image cover = pimage.copyResize(
  //   pimage.copyInto(
  //     backgroundImage,
  //     image,
  //     center: true,
  //   ),
  //   width: 1200,
  // );

  final backgroundColor = pimage.ColorRgba8(
    dColor.red,
    dColor.green,
    dColor.blue,
    dColor.alpha,
  );

  final cover = _buildCover(image, backgroundColor);

  logger.d('${cover.width} ${cover.height}');

  final List<int> coverImage =
      filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')
          ? pimage.encodeJpg(cover, quality: 80)
          : pimage.encodeNamedImage(filePath, cover)!;

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
    final _xhtml = indexTemplate.render({
      'fileName': _imgFile['name'],
    });
    final _xhtmlFile = File(
        path.join(contentPath, 'index_${_imgFile['withoutExtension']}.xhtml'));
    _xhtmlFile.createSync(recursive: true);
    _xhtmlFile.writeAsStringSync('$_xhtml');
  }

  // 写入 metadata.opf
  final metadata = metadataTemplate.render({
    'mainTitle': htmlEscape.convert(task.title.shortTitle),
    'fileNameList': fileNameList,
    'coverName': coverName,
    'coverExtension': path.extension(coverName) == '.jpg'
        ? 'jpeg'
        : path.extension(coverName).split('.').last.toLowerCase(),
  });
  final metadataFile = File(path.join(oebpsPath, 'metadata.opf'));
  metadataFile.createSync();
  metadataFile.writeAsStringSync(metadata);

  // 写入 toc.ncx
  final toc = tocTemplate.render();
  final tocFile = File(path.join(oebpsPath, 'toc.ncx'));
  tocFile.createSync();
  tocFile.writeAsStringSync('$toc');

  return _tempPath;
}

enum CoverTransformType {
  // 缩放
  resize,

  // 高宽比低于最大值，大于目标，按宽度缩放后，裁切高度
  cropHeight,

  // 高宽比低于目标，大于最小值，按高度缩放后，裁切宽度
  cropWidth,

  // 按宽度缩放后，填充高度
  fillHeight,

  // 高宽比超出最大值，按高度缩放后，填充宽度
  fillWidth,
}

pimage.Image _buildCover(
  pimage.Image image,
  pimage.Color backgroundColor,
) {
  pimage.Image cover = image;

  const coverAspectRatio = 3 / 2;
  const maxAspectRatio = 16 / 9;
  const minAspectRatio = 1.0;

  const coverWidth = 600;
  final coverHeight = (coverWidth * coverAspectRatio).round();

  // 源图片高宽比
  final double _aspectRatio = image.height / image.width;

  CoverTransformType _transformType = CoverTransformType.resize;

  if (_aspectRatio > maxAspectRatio) {
    // 高宽比超出最大值，按高度缩放后，填充宽度
    _transformType = CoverTransformType.fillWidth;
  } else if (_aspectRatio <= maxAspectRatio &&
      _aspectRatio > coverAspectRatio) {
    // 高宽比低于最大值，大于目标，按宽度缩放后，裁切高度
    _transformType = CoverTransformType.cropHeight;
  } else if (_aspectRatio == coverAspectRatio) {
    // 目标比例一致， 只进行缩放
    _transformType = CoverTransformType.resize;
  } else if (_aspectRatio < coverAspectRatio &&
      _aspectRatio >= minAspectRatio) {
    // 高宽比低于目标，大于最小值，按高度缩放后，裁切宽度
    _transformType = CoverTransformType.cropWidth;
  } else if (_aspectRatio < minAspectRatio) {
    // 高宽比低于最小值，按宽度缩放后，填充高度
    _transformType = CoverTransformType.fillHeight;
  }

  switch (_transformType) {
    case CoverTransformType.resize:
      // 只进行缩放
      cover = pimage.copyResize(
        cover,
        width: coverWidth,
        interpolation: pimage.Interpolation.cubic,
      );
      break;
    case CoverTransformType.cropHeight:
      // 按宽度缩放后，裁切高度
      // 按照 coverWidth copyResize
      cover = pimage.copyResize(
        cover,
        width: coverWidth,
        interpolation: pimage.Interpolation.cubic,
      );

      final int _cropHeight = (cover.height - coverHeight) ~/ 2;
      cover = pimage.copyCrop(
        cover,
        x: 0,
        y: _cropHeight,
        width: cover.width,
        height: coverHeight,
      );
      break;
    case CoverTransformType.cropWidth:
      // 裁切宽度超过的部分
      // 按照 coverHeight copyResize
      cover = pimage.copyResize(
        cover,
        height: coverHeight,
        interpolation: pimage.Interpolation.cubic,
      );

      // 裁切宽度
      final int _cropWidth = (cover.width - coverWidth) ~/ 2;
      cover = pimage.copyCrop(
        cover,
        x: _cropWidth,
        y: 0,
        width: coverWidth,
        height: cover.height,
      );
      break;
    case CoverTransformType.fillHeight:
      // 按照 coverWidth copyResize
      cover = pimage.copyResize(
        cover,
        width: coverWidth,
        interpolation: pimage.Interpolation.cubic,
      );

      // 填充
      cover = pimage.copyExpandCanvas(
        cover,
        newWidth: coverWidth,
        newHeight: coverHeight,
        backgroundColor: backgroundColor,
      );

      break;
    case CoverTransformType.fillWidth:
      // 按照 coverHeight copyResize
      cover = pimage.copyResize(
        cover,
        height: coverHeight,
        interpolation: pimage.Interpolation.cubic,
      );
      // 填充
      cover = pimage.copyExpandCanvas(
        cover,
        newWidth: coverWidth,
        newHeight: coverHeight,
        backgroundColor: backgroundColor,
      );
      break;
  }

  return cover;
}

void _createDir(String path) {
  final _dir = Directory(path);
  if (!_dir.existsSync()) {
    _dir.createSync(recursive: true);
  }
}
