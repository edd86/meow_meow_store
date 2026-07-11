import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract final class QrUtils {
  static bool isNumericOnly(String value) => RegExp(r'^\d+$').hasMatch(value);

  static bool canGenerateQr(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && !isNumericOnly(trimmed);
  }

  static String sanitizeFileName(String name) =>
      name.replaceAll(RegExp(r'[^\w]'), '_');

  static Future<Uint8List> captureWidget(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<File> saveToTempFile(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> shareFile(File file, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }
}
