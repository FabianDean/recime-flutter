import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, title: "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  String _username = null;
  FirebaseUser _user = null;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      //_username = user.displayName;
      _user = user;
      _username = user.uid.substring(0, 11);
      print(_username);
    });
  }

  String _getUsername() {
    print(_username);
    return _username;
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
                        text: _getUsername(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                CupertinoIcons.photo_camera,
                color: CupertinoColors.black,
                size: 40,
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
