import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, title: "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false, middle: Text("Home")),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Center(child: Text("Home Page")),
                  Text("Counter: $_counter"),
                  CupertinoButton(
                    child: Text("+"),
                    onPressed: () {
                      _increment();
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
