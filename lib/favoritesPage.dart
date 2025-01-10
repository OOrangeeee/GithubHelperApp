import 'package:flutter/material.dart';
import 'utils/storageHelper.dart';
import 'utils/httpHelper.dart'; // 导入 httpHelper
import 'searchPage.dart';
import 'cards.dart';
import 'main.dart'; // 导入 main.dart 以便返回主页
import 'utils/cacheHelper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final StorageHelper storageHelper = StorageHelper(); // 创建 StorageHelper 实例
  List<Map<String, String>> likedRepos = [];

  @override
  void initState() {
    super.initState();
    _loadLikedRepos(); // 加载收藏的仓库
  }

  // 加载收藏的仓库
  void _loadLikedRepos() async {
    List<Map<String, String>> repos = await storageHelper.getLikedRepos();
    if (mounted) {
      setState(() {
        likedRepos = repos;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('收藏仓库'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 标题卡片
                  Container(
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: theme.colorScheme.primary,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '我的收藏',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 收藏列表
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: likedRepos.length,
                      itemBuilder: (context, index) {
                        var repo = likedRepos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  repo['owner']![0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              title: Text(
                                repo['repoName']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '作者: ${repo['owner']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red),
                                onPressed: () async {
                                  await storageHelper.removeRepoInfo(
                                      repo['owner']!, repo['repoName']!);
                                  _loadLikedRepos();
                                },
                              ),
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                // 先尝试从缓存获取数据
                                String? cachedData = await CacheHelper()
                                    .getFromCache(
                                        repo['owner']!, repo['repoName']!);

                                String response;
                                if (cachedData != null) {
                                  response = cachedData;
                                } else {
                                  var queryParams = {
                                    'repoName': repo['repoName']!,
                                    'owner': repo['owner']!,
                                  };
                                  var headers = {
                                    'Accept': 'application/json',
                                  };
                                  response = await HttpHelper().httpGet(
                                    'urlhere',
                                    headers,
                                    queryParams,
                                  );
                                  // 保存到缓存
                                  await CacheHelper().saveToCache(
                                      repo['owner']!,
                                      repo['repoName']!,
                                      response);
                                }

                                Navigator.pop(context); // 关闭加载弹窗
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(
                                        jsonString: response,
                                        owner: repo['owner']!,
                                        repoName: repo['repoName']!),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '收藏',
          ),
        ],
        currentIndex: 1, // 当前选中的导航栏索引
        selectedItemColor: Colors.amber[800], // 选中时的颜色
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
