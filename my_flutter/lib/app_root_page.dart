import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/demo/test_stateful_widget_page.dart';
import 'package:my_flutter/tab_bar/tab_bar_page.dart';

class AppRootPage extends StatefulWidget {
  AppRootPage({Key? key}) : super(key: key);

  @override
  _AppRootPageState createState() => _AppRootPageState();
}

class _AppRootPageState extends State<AppRootPage> {
  // 创建一个给原生(OC)通道 (类似iOS的通知）
  static const methodChannel = const MethodChannel('com.pages.your/native_get');

  // 注册一个通知
  static const eventChannel = const EventChannel('com.pages.your/native_post');

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;

      print('flutter的log打印：现在输出count=$_counter');
      // 当个数累积到3的时候给客户端发参数
      if (_counter == 3) {
        _toNativeSomethingAndGetInfo();
      }

      // 当个数累积到5的时候给客户端发参数
      if (_counter == 1002) {
        Map<String, String> map = {"title": "这是一条来自flutter的参数"};
        methodChannel.invokeMethod('toNativePush', map);
      }

      // 当个数累积到8的时候给客户端发参数
      if (_counter == 1005) {
        Map<String, dynamic> map = {
          "content": "flutterPop回来",
          "data": [1, 2, 3, 4, 5]
        };
        methodChannel.invokeMethod('toNativePop', map);
      }
    });
  }

  // 给客户端发送一些东东 , 并且拿到一些东东
  Future<Null> _toNativeSomethingAndGetInfo() async {
    dynamic result;
    try {
      result = await methodChannel.invokeMethod('toNativeSomething', '大佬你点击了$_counter下');
    } on PlatformException catch (e) {
      print("OC回调给 Flutter1 $e");
      result = 100000;
    }
    setState(() {
      // 类型判断
      if (result is int) {
        print("OC回调给 Flutter2 $result");
        _counter = result;
      }
    });
  }

  // 渲染前的操作，类似viewDidLoad
  @override
  void initState() {
    super.initState();

    // 监听事件，同时发送参数12345
    //eventChannel.receiveBroadcastStream(12345).listen(_onEvent, onError: _onError);
  }

  String naviTitle = 'title';

  // 回调事件
  void _onEvent(Object event) {
    setState(() {
      naviTitle = event.toString();
    });
  }

  // 错误返回
  void _onError(Object error) {}

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return Scaffold();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: _pushSaved,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return TestStatefulWidgetPage(
                        settings: RouteSettings(),
                      );
                    },
                  ),
                );
              },
              child: Container(
                color: Colors.red,
                height: 100,
                width: 100,
                child: Center(
                  child: Text(
                    '测试按钮',
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return TabBarPage();
                }));
              },
              child: Container(
                color: Colors.green,
                height: 100,
                width: 100,
                child: Center(
                  child: Text(
                    '进入Tabbar页面',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        width: 100,
        color: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
