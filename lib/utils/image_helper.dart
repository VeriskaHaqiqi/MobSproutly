import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

class ImageHelper {
  static Widget fromPath(String path, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    if (kIsWeb) {
      if (path.startsWith('blob:')) {
        return FutureBuilder<Response<List<int>>>(
          future: Dio().get<List<int>>(
            path,
            options: Options(responseType: ResponseType.bytes),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data?.data != null) {
              return Image.memory(
                Uint8List.fromList(snapshot.data!.data!),
                width: width,
                height: height,
                fit: fit,
                errorBuilder: errorBuilder,
              );
            } else if (snapshot.hasError) {
              if (errorBuilder != null) {
                return errorBuilder(context, snapshot.error!, null);
              }
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            }
            // Loading state
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade100,
              child: const Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        );
      }
      
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } else {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
  }

  // Backwards compatibility
  static Widget fromFile(File file, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return fromPath(file.path, width: width, height: height, fit: fit, errorBuilder: errorBuilder);
  }
}
