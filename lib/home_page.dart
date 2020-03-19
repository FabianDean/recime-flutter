import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/carousel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, title: "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore _dbReference = Firestore.instance;
  RefreshController _refreshController = RefreshController();
  Map<String, dynamic> _userData;
  Map<String, dynamic> _trendingData;
  String _timeOfDayGreeting;

  @override
  void initState() {
    super.initState();
    _getData();
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12)
      _timeOfDayGreeting = "Good morning,";
    else if (hour >= 12 && hour < 17)
      _timeOfDayGreeting = "Good afternoon,";
    else
      _timeOfDayGreeting = "Good evening,";
  }

  Future<void> _getData() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      // convert to aysyc/await syntax later
      firebaseAuth.currentUser().then((user) {
        _dbReference
            .collection("users")
            .document(user.uid)
            .get()
            .then((document) {
          setState(() {
            _userData = document.data;
          });
        });
        _dbReference
            .collection("recipes")
            .document("trending")
            .get()
            .then((document) {
          setState(() {
            _trendingData = document.data;
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  Widget _trendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Text(
            "Trending",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Carousel(
          context: context,
          list: _trendingData != null ? _trendingData["results"] : [],
        ),
      ],
    );
  }

  Widget _likesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Text(
            "Likes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Carousel(
          context: context,
          list: _userData != null ? _userData["likedRecipes"] : [],
        ),
      ],
    );
  }

  Widget _recentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Text(
            "Recents",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Carousel(
          context: context,
          list: _userData != null ? _userData["recentRecipes"] : [],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              backgroundColor: Color(0xfff79c4f),
              leading: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: AutoSizeText(
                      _timeOfDayGreeting,
                    ),
                  ),
                ],
              ),
              largeTitle: AutoSizeText(
                _userData != null ? _userData["username"] : "",
                style: TextStyle(
                  color: CupertinoColors.white,
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
            ),
            SliverFillRemaining(
              child: SafeArea(
                top: false,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SmartRefresher(
                        controller: _refreshController,
                        child: ListView(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          children: <Widget>[
                            _trendingSection(context),
                            _likesSection(context),
                            _recentsSection(context),
                            SizedBox(height: 15),
                          ],
                        ),
                        onRefresh: _getData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
