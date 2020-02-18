import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, title: "Home"}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Test"),
      ),
    );
    // return WillPopScope(
    //     onWillPop: () async => false,
    //     child: CupertinoTabScaffold(
    //       tabBar: CupertinoTabBar(
    //         items: [
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.home),
    //             title: Text("Home"),
    //           ),
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.search),
    //             title: Text("Explore"),
    //           ),
    //           BottomNavigationBarItem(
    //               icon: Icon(Icons.settings), title: Text("Settings"))
    //         ],
    //       ),
    //       tabBuilder: (BuildContext context, int index) {
    //         return CupertinoTabView(
    //           builder: (context) {
    //             switch (index) {
    //               case 0:
    //                 return HomePage();
    //                 break;
    //               case 1:
    //                 return ExplorePage();
    //                 break;
    //               case 2:
    //                 return SettingsPage();
    //                 break;
    //               default:
    //                 return Text('Error: CupertinoTabView in main.dart');
    //             }
    //           },
    //         );
    //       },
    //     ));
  }
}
