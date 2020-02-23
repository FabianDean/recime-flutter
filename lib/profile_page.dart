import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recime_flutter/settings_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, title: "Profile"}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            trailing: CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                CupertinoIcons.settings,
                color: CupertinoColors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
            backgroundColor: Color(0xfff79c4f),
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Center(child: Text("Profile Page")),
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
