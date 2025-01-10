import 'package:flutter/material.dart';
import 'dart:convert';
import 'utils/storageHelper.dart'; // 导入 storageHelper

class SearchPage extends StatefulWidget {
  final String jsonString;

  const SearchPage({super.key, required this.jsonString});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  final StorageHelper storageHelper = StorageHelper();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _checkIfLiked();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    // 错误页面UI优化
    if (jsonResponse.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('搜索结果'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: theme.colorScheme.onError,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '找不到仓库',
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Map<String, dynamic> repoInfo = jsonResponse['RepoInfo'];
    String mainBranchName = repoInfo['MainBranch']['MainBranchName'].isEmpty
        ? '无主分支'
        : repoInfo['MainBranch']['MainBranchName'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('仓库详情'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 仓库基本信息卡片
                    _buildInfoCard(
                      theme,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  repoInfo['Owner'][0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      repoInfo['RepoName'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '作者: ${repoInfo['Owner']}',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: IconButton(
                                  iconSize: 30,
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isLiked = !isLiked;
                                      if (isLiked) {
                                        _controller
                                            .forward()
                                            .then((_) => _controller.reverse());
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 主分支信息卡片
                    _buildInfoCard(
                      theme,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('主分支信息'),
                          const SizedBox(height: 10),
                          _buildInfoRow('分支名称', mainBranchName),
                          _buildInfoRow('提交数量',
                              '${repoInfo['MainBranch']['MainBranchCommitNum']}'),
                          _buildInfoRow(
                              '最新提交',
                              repoInfo['MainBranch']
                                  ['MainBranchLatestCommitTime']),
                          _buildInfoRow('主要贡献者',
                              repoInfo['MainBranch']['MainContributor']),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 分支列表
                    _buildSectionTitle('所有分支'),
                    const SizedBox(height: 10),
                    ...repoInfo['Branches'].map<Widget>((branch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildBranchCard(theme, branch),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(ThemeData theme, Map<String, dynamic> branch) {
    String commitMsg = branch['LatestCommitMsg'];
    if (commitMsg.length > 100) {
      commitMsg = '${commitMsg.substring(0, 97)}...';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.call_split,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                branch['BranchName'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '最新提交: $commitMsg',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '提交时间: ${branch['LatestCommitTime']}',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
