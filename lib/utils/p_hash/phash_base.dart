import 'dart:io';
import 'dart:math';

import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

class Pixel {
  Pixel(this._red, this._green, this._blue, this._alpha);
  final int _red;
  final int _green;
  final int _blue;
  final int _alpha;

  @override
  String toString() {
    return 'red: $_red, green: $_green, blue: $_blue, alpha: $_alpha';
  }
}

const int _kSize = 32;

BigInt calculatePHash(Image image) {
  // print('^^^^ calculatePHash ${image.width} ${image.height}');
  image = copyResize(image, width: 32, height: 32);
  final List<Pixel> pixelList = [];
  const bytesPerPixel = 4;
  final bytes = image.getBytes();
  for (var i = 0; i <= bytes.length - bytesPerPixel; i += bytesPerPixel) {
    pixelList.add(Pixel(bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]));
  }

  try {
    final BigInt pHash = _calcPhash(pixelList);
    return pHash;
  } catch (e, s) {
    logger.e('^^^^ calculatePHash error $e\n$s');
    rethrow;
  }
}

BigInt calculateFromList(List<int> data) {
  return calculatePHash(getValidImage(data));
}

BigInt calculateFromFile(String path) {
  final imageFile = File(path);
  final List<int> data = imageFile.readAsBytesSync();
  return calculatePHash(getValidImage(data));
}

///Helper function to convert a Unit8List to a nD matrix
List<List<Pixel>> _unit8ListToMatrix(List<Pixel> pixelList) {
  final copy = pixelList.sublist(0);
  // pixelList.clear();
  final pixelListDest = <List<Pixel>>[];

  for (int r = 0; r < _kSize; r++) {
    final res = <Pixel>[];
    for (var c = 0; c < _kSize; c++) {
      var i = r * _kSize + c;

      if (i < copy.length) {
        res.add(copy[i]);
      } else {
        res.add(Pixel(0, 0, 0, 0));
      }
    }

    pixelListDest.add(res);
  }

  return pixelListDest;
}

/// Helper function which computes a binary hash of a [List] of [Pixel]
BigInt _calcPhash(List<Pixel> pixelList) {
  String bitString = '';
  final matrix = List<List<num>>.filled(32, []);
  final row = List<num>.filled(32, 0);
  final rows = List<List<num>>.filled(32, []);
  final col = List<num>.filled(32, 0);

  final data = _unit8ListToMatrix(pixelList); //returns a matrix used for DCT

  for (int y = 0; y < _kSize; y++) {
    for (int x = 0; x < _kSize; x++) {
      final color = data[x][y];
      row[x] = getLuminanceRgb(color._red, color._green, color._blue);
    }

    rows[y] = _calculateDCT(row);
  }

  for (int x = 0; x < _kSize; x++) {
    for (int y = 0; y < _kSize; y++) {
      col[y] = rows[y][x];
    }

    matrix[x] = _calculateDCT(col);
  }

  // Extract the top 8x8 pixels.
  var pixels = <num>[];

  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      pixels.add(matrix[y][x]);
    }
  }

  // Calculate hash.
  final bits = <num>[];
  final compare = _average(pixels);

  for (final pixel in pixels) {
    bits.add(pixel > compare ? 1 : 0);
  }

  bits.forEach((element) {
    bitString += (1 * element).toString();
  });

  return BigInt.parse(bitString, radix: 2);
}

///Helper function to perform 1D discrete cosine tranformation on a matrix
List<num> _calculateDCT(List<num> matrix) {
  final transformed = List<num>.filled(32, 0);
  final _size = matrix.length;

  for (int i = 0; i < _size; i++) {
    num sum = 0;

    for (int j = 0; j < _size; j++) {
      sum += matrix[j] * cos((i * pi * (j + 0.5)) / _size);
    }

    sum *= sqrt(2 / _size);

    if (i == 0) {
      sum *= 1 / sqrt(2);
    }

    transformed[i] = sum;
  }

  return transformed;
}

///Helper funciton to compute the average of an array after dct caclulations
num _average(List<num> pixels) {
  // Calculate the average value from top 8x8 pixels, except for the first one.
  final n = pixels.length - 1;
  return pixels.sublist(1, n).reduce((a, b) => a + b) / n;
}

int hammingDistance(BigInt x, BigInt y) {
  BigInt s = x ^ y;
  int ret = 0;
  while (s != BigInt.zero) {
    s &= s - BigInt.one;
    ret++;
  }
  return ret;
}

/// Helper function to validate [List]
/// of bytes format and return [Image].
/// Throws exception if format is invalid.
Image getValidImage(List<int> bytes) {
  Image? image;
  try {
    image = decodeImage(Uint8List.fromList(bytes));
  } on Exception {
    throw const FormatException(
        'Insufficient data provided to identify image.');
  }

  if (image == null) {
    throw const FormatException('image null');
  }

  return image;
}
