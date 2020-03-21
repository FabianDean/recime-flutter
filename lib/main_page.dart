import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                    return HomePage(); //ImageSelectPage();
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
