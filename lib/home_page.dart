import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            automaticallyImplyLeading: false,
            leading: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Hello, ",
                      ),
                      TextSpan(
                        text: "User",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.all(0),
              child: CircleAvatar(
                backgroundColor: CupertinoColors.systemGrey,
                child: Icon(
                  Icons.person,
                  color: CupertinoColors.black,
                  size: 30,
                ),
              ),
              onPressed: () {},
            ),
            backgroundColor: Color(0xfff79c4f),
          ),
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
