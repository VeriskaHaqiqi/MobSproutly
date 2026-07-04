import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileHelper {
  static Future<MultipartFile> createMultipartFile(String path, {String? filename}) async {
    var name = filename ?? path.split(RegExp(r'[/\\]')).last;
    if (kIsWeb && !name.contains('.')) {
      name += '.jpg';
    }
    
    if (kIsWeb) {
      // On Web, the path is a blob URL. We can fetch it to get bytes.
      final dio = Dio();
      final response = await dio.get(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return MultipartFile.fromBytes(response.data, filename: name);
    } else {
      return MultipartFile.fromFile(path, filename: name);
    }
  }
}
