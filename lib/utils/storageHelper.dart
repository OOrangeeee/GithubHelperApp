import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'directoryHelper.dart';

class StorageHelper {
  // 获取文件路径
  Future<String> _getFilePath() async {
    final appDir = await DirectoryHelper.getAppDirectory();
    return '$appDir/liked_repos.json';
  }

  // 保存仓库信息
  void saveRepoInfo(String owner, String repoName) async {
    List<Map<String, String>> likedRepos = await _readLikedRepos();
    likedRepos.add({'owner': owner, 'repoName': repoName});
    await _writeLikedRepos(likedRepos);
  }

  // 移除仓库信息
  Future<void> removeRepoInfo(String owner, String repoName) async {
    List<Map<String, String>> likedRepos = await _readLikedRepos();
    likedRepos.removeWhere(
        (repo) => repo['owner'] == owner && repo['repoName'] == repoName);
    await _writeLikedRepos(likedRepos);
  }

  // 获取所有收藏的仓库信息
  Future<List<Map<String, String>>> getLikedRepos() async {
    return await _readLikedRepos();
  }

  // 判断仓库是否已收藏
  Future<bool> isRepoLiked(String owner, String repoName) async {
    List<Map<String, String>> likedRepos = await _readLikedRepos();
    return likedRepos
        .any((repo) => repo['owner'] == owner && repo['repoName'] == repoName);
  }

  // 读取收藏的仓库信息
  Future<List<Map<String, String>>> _readLikedRepos() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(contents);
        return jsonData.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      print('Error reading liked repos: $e');
    }
    return [];
  }

  // 写入收藏的仓库信息
  Future<void> _writeLikedRepos(List<Map<String, String>> likedRepos) async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      await file.writeAsString(jsonEncode(likedRepos));
    } catch (e) {
      print('Error writing liked repos: $e');
    }
  }

  // 打印收藏的仓库信息
  Future<void> printLikedRepos() async {
    List<Map<String, String>> likedRepos = await _readLikedRepos();
    print('Liked Repos: ${jsonEncode(likedRepos)}');
  }
}
