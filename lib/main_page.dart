import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'profile_page.dart';
import 'imageSelect_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, title: "Home"}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // clean up app data since content will be refetched again
    _clearAppData();
  }

  Future<void> _clearAppData() async {
    try {
      // final String imagePickerPath =
      //     "/private/var/mobile/Containers/Data/Application/267ABA8E-CCF6-4161-906F-B57441E03510/tmp";
      var appDir = (await getTemporaryDirectory()).path;
      new Directory(appDir).delete(recursive: true);
      // new Directory(imagePickerPath).delete(recursive: true);
    } catch (error) {
      print("Error in _clearAppData() in main_page.dart");
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            activeColor: Color(0xfff79c4f),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
              )
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return ImageSelectPage();
                    break;
                  case 1:
                    return ExplorePage();
                    break;
                  case 2:
                    return ProfilePage();
                    break;
                  default:
                    return Text('Error: CupertinoTabView in main.dart');
                }
              },
            );
          },
        ));
  }
}
