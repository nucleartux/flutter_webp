import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// static method will help you compress image
///
/// most method will return [List<int>]
///
/// convert List<int> to [Uint8List] and use [Image.memory(uint8List)] to display image
/// ```dart
/// var u8 = Uint8List.fromList(list)
/// ImageProvider provider = MemoryImage(Uint8List.fromList(list));
/// ```
///
class FlutterWebp {
  static const MethodChannel _channel = const MethodChannel('flutter_webp');

  static set showNativeLog(bool value) {
    _channel.invokeMethod("showLog", value);
  }

  /// Compress image from [List<int>] to [List<int>]
  static Future<List<int>> compressWithList(
    List<int> image, {
    @required int width,
    @required int height,
    int quality = 100,
    int rotate = 0,
  }) async {
    assert(
      image != null,
      "A non-null List<int> must be provided to FlutterWebp.",
    );
    if (image == null) {
      return [];
    }
    if (image.isEmpty) {
      return [];
    }
    final result = await _channel.invokeMethod("compressWithList", [
      Uint8List.fromList(image),
      width,
      height,
      quality,
      rotate,
    ]);

    return convertDynamic(result);
  }

  /// Compress file of [path] to [List<int>].
  static Future<List<int>> compressWithFile(
    String path, {
    @required int width,
    @required int height,
    int quality = 100,
    int rotate = 0,
  }) async {
    assert(
      path != null,
      "A non-null String must be provided to FlutterWebp.",
    );
    if (path == null || !File(path).existsSync()) {
      return [];
    }
    final result = await _channel.invokeMethod("compressWithFile", [
      path,
      width,
      height,
      quality,
      rotate,
    ]);
    return convertDynamic(result);
  }

  /// From [path] to [targetPath]
  static Future<File> compressAndGetFile(
    String path,
    String targetPath, {
    @required int width,
    @required int height,
    int quality = 100,
    int rotate = 0,
  }) async {
    assert(
      path != null,
      "A non-null String must be provided to FlutterWebp.",
    );
    if (path == null || !File(path).existsSync()) {
      return null;
    }

    final String result =
        await _channel.invokeMethod("compressWithFileAndGetFile", [
      path,
      width,
      height,
      quality,
      targetPath,
      rotate,
    ]);

    if (result == null) {
      return null;
    }

    return File(result);
  }

  /// From [asset] to [List<int>]
  static Future<List<int>> compressAssetImage(
    String assetName, {
    @required int width,
    @required int height,
    int quality = 100,
    int rotate = 0,
  }) async {
    assert(
      assetName != null,
      "A non-null String must be provided to FlutterWebp.",
    );
    if (assetName == null) {
      return [];
    }

    var img = AssetImage(assetName);
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    var uint8List = data.buffer.asUint8List();

    if (uint8List == null || uint8List.isEmpty) {
      return [];
    }

    return compressWithList(
      uint8List,
      height: height,
      width: width,
      quality: quality,
      rotate: rotate,
    );
  }

  /// convert [List<dynamic>] to [List<int>]
  static List<int> convertDynamic(List<dynamic> list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    return list
        .where((item) => item is int)
        .map((item) => item as int)
        .toList();
  }
}

/// get [ImageInfo] from [ImageProvider]
Future<ImageInfo> getImageInfo(BuildContext context, ImageProvider provider,
    {Size size}) async {
  final ImageConfiguration config =
      createLocalImageConfiguration(context, size: size);
  final Completer<ImageInfo> completer = new Completer<ImageInfo>();
  final ImageStream stream = provider.resolve(config);

  ImageStreamListener listener;

  listener = ImageStreamListener(
    (ImageInfo image, bool syncCall) {
      stream.removeListener(listener);
      completer.complete(image);
    },
    onError: (dynamic error, StackTrace stackTrace) {
      completer.complete(null);

      FlutterError.reportError(new FlutterErrorDetails(
        library: 'flutter_webp',
        exception: error,
        stack: stackTrace,
        silent: true,
      ));
      stream.removeListener(listener);
    },
  );

  stream.addListener(listener);

  return completer.future;
}
