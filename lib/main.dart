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
  final String url = '';

  @override
  void dispose() {
    repoController.dispose();
    ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // 获取当前的文本主题
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 上方图片
                Image.asset(
                  'lib/images/1.png',
                  width: 300.0,
                  height: 150.0,
                ),
                const SizedBox(height: 10), // 添加间距
                // 提示信息
                TextCard(
                  text: '请输入你想查询的Github仓库信息',
                  borderRadius: 10.0,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.6),
                  fontColor: theme.colorScheme.onPrimary,
                  width: 300.0,
                  height: 50.0,
                  fontSizePresent: 0.35,
                ),
                const SizedBox(height: 10), // 添加间距
                InputCard(
                  controller: repoController,
                  hintText: '仓库名称',
                  borderRadius: 10.0,
                  textAlign: TextAlign.center,
                  width: 300.0,
                  height: 50.0,
                  fontSizePresent: 0.35,
                ),
                const SizedBox(height: 10), // 添加间距
                InputCard(
                  controller: ownerController,
                  hintText: '仓库拥有者',
                  borderRadius: 10.0,
                  textAlign: TextAlign.center,
                  width: 300.0,
                  height: 50.0,
                  fontSizePresent: 0.35,
                ),
                const SizedBox(height: 10), // 添加间距
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
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
                    String response =
                        await httpHelper.httpGet(url, headers, queryParams);
                    Navigator.pop(context); // 关闭加载弹窗
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(jsonString: response),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 50), // 设置按钮的最小尺寸
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 设置按钮的圆角半径
                    ),
                    backgroundColor: theme.colorScheme.surface, // 设置按钮的背景颜色
                    foregroundColor: theme.colorScheme.onSurface, // 设置按钮文本的颜色
                  ),
                  child: Text('搜索'), // 按钮文本
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
