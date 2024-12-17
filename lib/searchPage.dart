import 'package:flutter/material.dart';
import 'dart:convert';
import 'cards.dart';
import 'utils/storageHelper.dart'; // 导入 storageHelper

class SearchPage extends StatefulWidget {
  final String jsonString;

  const SearchPage({super.key, required this.jsonString});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLiked = false; // 是否点赞
  final StorageHelper storageHelper = StorageHelper(); // 创建 StorageHelper 实例

  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // 检查是否已点赞
  }

  // 检查是否已点赞
  void _checkIfLiked() async {
    Map<String, dynamic> jsonResponse = jsonDecode(widget.jsonString);
    if (jsonResponse.containsKey('RepoInfo')) {
      Map<String, dynamic> repoInfo = jsonResponse['RepoInfo'];
      bool liked = await storageHelper.isRepoLiked(
          repoInfo['Owner'], repoInfo['RepoName']);
      setState(() {
        isLiked = liked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Map<String, dynamic> jsonResponse = jsonDecode(widget.jsonString);

    if (jsonResponse.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('搜索结果'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: Image.asset(
                'lib/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: TextCard(
                text: '找不到仓库',
                borderRadius: 10.0,
                backgroundColor: theme.colorScheme.error.withOpacity(0.6),
                fontColor: theme.colorScheme.onError,
                width: 300.0,
                height: 50.0,
                fontSizePresent: 0.35,
              ),
            ),
          ],
        ),
      );
    }

    Map<String, dynamic> repoInfo = jsonResponse['RepoInfo'];
    String mainBranchName = repoInfo['MainBranch']['MainBranchName'];
    if (mainBranchName.isEmpty) {
      mainBranchName = '无主分支';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索结果'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'lib/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - kToolbarHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 整个页面用一个 Card 呈现
                      Card(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 仓库名称和拥有者用一个 Card 嵌套
                              TextCard(
                                text:
                                    '仓库名称: ${repoInfo['RepoName']}\n拥有者: ${repoInfo['Owner']}',
                                borderRadius: 10.0,
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.6),
                                fontColor: theme.colorScheme.onPrimary,
                                width: double.infinity,
                                height: 100.0,
                                fontSizePresent: 0.17,
                              ),
                              const SizedBox(height: 10),
                              // 主分支信息用一个 Card 嵌套
                              TextCard(
                                text:
                                    '主分支: $mainBranchName\n主分支提交数: ${repoInfo['MainBranch']['MainBranchCommitNum']}\n主分支最新提交时间: ${repoInfo['MainBranch']['MainBranchLatestCommitTime']}\n主要贡献者: ${repoInfo['MainBranch']['MainContributor']}',
                                borderRadius: 10.0,
                                backgroundColor: theme.colorScheme.secondary
                                    .withOpacity(0.6),
                                fontColor: theme.colorScheme.onSecondary,
                                width: double.infinity,
                                height: 150.0,
                                fontSizePresent: 0.17,
                              ),
                              const SizedBox(height: 10),
                              const Text('分支列表:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              // 分支信息用各自的 Card 嵌套
                              ...repoInfo['Branches'].map<Widget>((branch) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextCard(
                                    text:
                                        '分支名称: ${branch['BranchName']}\n最新提交信息: ${branch['LatestCommitMsg']}\n最新提交时间: ${branch['LatestCommitTime']}',
                                    borderRadius: 10.0,
                                    backgroundColor: theme.colorScheme.tertiary
                                        .withOpacity(0.6),
                                    fontColor: theme.colorScheme.onTertiary,
                                    width: double.infinity,
                                    height: 120.0,
                                    fontSizePresent: 0.17,
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 10),
                              // 点赞按钮
                              Center(
                                child: IconButton(
                                  iconSize: 40.0, // 设置按钮大小
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isLiked = !isLiked; // 切换点赞状态
                                      if (isLiked) {
                                        storageHelper.saveRepoInfo(
                                          repoInfo['Owner'],
                                          repoInfo['RepoName'],
                                        );
                                      } else {
                                        storageHelper.removeRepoInfo(
                                          repoInfo['Owner'],
                                          repoInfo['RepoName'],
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
