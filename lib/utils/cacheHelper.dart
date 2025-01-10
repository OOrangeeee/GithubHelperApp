import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'directoryHelper.dart';

class CacheHelper {
  static const int CACHE_DURATION_HOURS = 2;

  Future<String> _getCacheFilePath(String key) async {
    final appDir = await DirectoryHelper.getAppDirectory();
    return '$appDir/cache_$key.json';
  }

  String _generateCacheKey(String owner, String repoName) {
    return '${owner}_$repoName'.toLowerCase();
  }

  Future<void> saveToCache(String owner, String repoName, String data) async {
    try {
      // 不缓存错误响应
      Map<String, dynamic> jsonData = jsonDecode(data);
      if (jsonData.containsKey('error')) {
        return;
      }

      final cacheKey = _generateCacheKey(owner, repoName);
      final filePath = await _getCacheFilePath(cacheKey);
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };

      final file = File(filePath);
      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  Future<String?> getFromCache(String owner, String repoName) async {
    try {
      final cacheKey = _generateCacheKey(owner, repoName);
      final filePath = await _getCacheFilePath(cacheKey);
      final file = File(filePath);

      if (!await file.exists()) {
        return null;
      }

      final contents = await file.readAsString();
      final cacheData = jsonDecode(contents);
      final timestamp = cacheData['timestamp'] as int;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // 检查缓存是否过期
      if (currentTime - timestamp > CACHE_DURATION_HOURS * 60 * 60 * 1000) {
        await file.delete();
        return null;
      }

      return cacheData['data'] as String;
    } catch (e) {
      print('Cache read error: $e');
      return null;
    }
  }

  Future<void> clearCache(String owner, String repoName) async {
    try {
      final cacheKey = _generateCacheKey(owner, repoName);
      final filePath = await _getCacheFilePath(cacheKey);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }
}
