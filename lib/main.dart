import 'package:flutter/material.dart';
import 'package:githubhelper/utils/httpHelper.dart';
import 'package:githubhelper/utils/storageHelper.dart'; // 导入 storageHelper
import 'cards.dart';
import 'searchPage.dart'; // 导入 searchPage
import 'favoritesPage.dart'; // 导入 favoritesPage
import 'package:path_provider/path_provider.dart';

// 打印 liked_repos.json 文件路径
Future<void> printFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  print('File path: ${directory.path}/liked_repos.json');
}

void main() {
  runApp(const MyApp());
  printFilePath();
  StorageHelper().printLikedRepos(); // 输出 liked_repos.json 文件内容
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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
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
                                // 构造查询参数
                                var queryParams = {
                                  'repoName': repoController.text,
                                  'owner': ownerController.text,
                                };
                                var headers = {
                                  'Accept': 'application/json',
                                };
                                String response = await httpHelper.httpGet(
                                    url, headers, queryParams);
                                Navigator.pop(context); // 关闭加载弹窗
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchPage(jsonString: response),
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
