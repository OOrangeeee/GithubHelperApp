import 'package:flutter/material.dart';
import 'package:githubhelper/utils/httpHelper.dart';
import 'package:githubhelper/utils/storageHelper.dart';
import 'searchPage.dart';
import 'favoritesPage.dart';
import 'utils/cacheHelper.dart';
import 'dart:io';
import 'utils/directoryHelper.dart';

// Future<void> printFilePath() async {
//   final directory = await getApplicationDocumentsDirectory();
//   print('Application documents directory: ${directory.path}');
// }

void main() {
  runApp(const MyApp());
  // printFilePath();
  StorageHelper().printLikedRepos();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub 小助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 当前选中的导航栏索引

  // 页面列表
  static const List<Widget> _pages = <Widget>[
    MyHomePage(title: 'GitHub 小助手'),
    FavoritesPage(),
  ];

  // 导航栏点击事件处理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FavoritesPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 显示当前选中的页面
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
        currentIndex: _selectedIndex, // 当前选中的导航栏索引
        selectedItemColor: Colors.amber[800], // 选中时的颜色
        onTap: _onItemTapped, // 导航栏点击事件处理
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController repoController =
      TextEditingController(); // 仓库名称输入框控制器
  final TextEditingController ownerController =
      TextEditingController(); // 仓库拥有者输入框控制器
  final HttpHelper httpHelper = HttpHelper(); // 创建 HttpHelper 实例
  final String url = 'urlhere';

  @override
  void dispose() {
    repoController.dispose();
    ownerController.dispose();
    super.dispose();
  }

  // 添加这个方法来获取并显示文件信息
  Future<void> _showFileLocations() async {
    final appDir = await DirectoryHelper.getAppDirectory();
    final dir = Directory(appDir);
    List<FileSystemEntity> files = dir.listSync();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.folder_open),
              SizedBox(width: 8),
              Text('文件位置信息'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('应用数据目录:\n$appDir',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                const Text('文件列表:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...files.map((file) {
                  String fileName =
                      file.path.split(Platform.pathSeparator).last;
                  String fileType = fileName.startsWith('cache_')
                      ? '(缓存文件)'
                      : fileName == 'liked_repos.json'
                          ? '(收藏文件)'
                          : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $fileName $fileType'),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('关闭'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        actions: [
          // 添加这个按钮
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFileLocations,
            tooltip: '查看文件位置',
          ),
        ],
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Logo容器
                      Container(
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
                        child: Image.asset(
                          'lib/images/1.png',
                          width: 250.0,
                          height: 125.0,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 搜索表单容器
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            Text(
                              '请输入你想查询的Github仓库信息',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 输入框样式优化
                            TextField(
                              controller: repoController,
                              decoration: InputDecoration(
                                hintText: '仓库名称',
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.folder),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: ownerController,
                              decoration: InputDecoration(
                                hintText: '仓库拥有者',
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // 搜索按钮样式优化
                            ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                final owner = ownerController.text;
                                final repoName = repoController.text;

                                // 先尝试从缓存获取数据
                                String? cachedData = await CacheHelper()
                                    .getFromCache(owner, repoName);

                                String response;
                                if (cachedData != null) {
                                  response = cachedData;
                                } else {
                                  // 如果没有缓存，则发送请求
                                  var queryParams = {
                                    'repoName': repoName,
                                    'owner': owner,
                                  };
                                  var headers = {
                                    'Accept': 'application/json',
                                  };
                                  response = await httpHelper.httpGet(
                                      url, headers, queryParams);

                                  // 保存到缓存
                                  await CacheHelper()
                                      .saveToCache(owner, repoName, response);
                                }

                                Navigator.pop(context); // 关闭加载弹窗

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(
                                      jsonString: response,
                                      owner: owner,
                                      repoName: repoName,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 8),
                                  Text(
                                    '搜索',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
