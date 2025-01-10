import 'package:flutter/material.dart';
import 'utils/storageHelper.dart';
import 'utils/httpHelper.dart'; // 导入 httpHelper
import 'searchPage.dart';
import 'cards.dart';
import 'main.dart'; // 导入 main.dart 以便返回主页

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
    setState(() {
      likedRepos = repos;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('收藏仓库'),
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
            child: ListView.builder(
              itemCount: likedRepos.length,
              itemBuilder: (context, index) {
                var repo = likedRepos[index];
                return GestureDetector(
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
                    var queryParams = {
                      'repoName': repo['repoName']!,
                      'owner': repo['owner']!,
                    };
                    var headers = {
                      'Accept': 'application/json',
                    };
                    String response = await HttpHelper().httpGet(
                      'urlhere',
                      headers,
                      queryParams,
                    );
                    Navigator.pop(context); // 关闭加载弹窗
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(jsonString: response),
                      ),
                    );
                  },
                  child: TextCard(
                    text: '作者: ${repo['owner']}\n仓库名称: ${repo['repoName']}',
                    borderRadius: 10.0,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.6),
                    fontColor: theme.colorScheme.onPrimary,
                    width: double.infinity,
                    height: 100.0,
                    fontSizePresent: 0.17,
                  ),
                );
              },
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
