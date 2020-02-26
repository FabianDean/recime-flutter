import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, title: "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RefreshController _refreshController = RefreshController();
  String _username = null;
  FirebaseUser _user = null;
  int _currentTrending = 0;
  int _currentYourRecipes = 0;
  int _currentRecents = 0;
  List imgList = [
    'https://images.unsplash.com/photo-1502117859338-fd9daa518a9a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1554321586-92083ba0a115?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1536679545597-c2e5e1946495?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1543922596-b3bbaba80649?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1502943693086-33b5b1cfdf2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80'
  ];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      //_username = user.displayName;
      setState(() {
        _user = user;
        _username = user.uid.substring(0, 11);
      });
      print(_username);
    });
  }

  String _getUsername() {
    print(_username);
    return _username;
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future<void> _loadRecipes() async {
    print("Loading recipes in HomePage");
    await Future.delayed(Duration(milliseconds: 500), () {});
    _refreshController.refreshCompleted();
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
        CarouselSlider(
          viewportFraction: 0.7,
          enlargeCenterPage: true,
          onPageChanged: (index) {
            setState(() {
              _currentTrending = index;
            });
          },
          items: imgList.map((imgUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.extraLightBackgroundGray,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.fill,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null)
                          return Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              child,
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors
                                        .extraLightBackgroundGray,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "Gluten-free Vegan Spaghetti Squash"
                                                      .length >
                                                  20
                                              ? "Gluten-free Vegan Spaghetti Squash"
                                                      .substring(0, 20) +
                                                  "..."
                                              : "Gluten-free Vegan Spaghetti Squash",
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: CupertinoColors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        CupertinoIcons.heart,
                                        color: CupertinoColors.systemRed,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Color(0xfff79c4f),
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            imgList,
            (index, url) {
              return Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentTrending == index
                      ? Color(0xfff79c4f)
                      : CupertinoColors.lightBackgroundGray,
                ),
              );
            },
          ),
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
            "Your Recipes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        CarouselSlider(
          viewportFraction: 0.7,
          enlargeCenterPage: true,
          onPageChanged: (index) {
            setState(() {
              _currentYourRecipes = index;
            });
          },
          items: imgList.map((imgUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.extraLightBackgroundGray,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.fill,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Color(0xfff79c4f),
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            imgList,
            (index, url) {
              return Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentYourRecipes == index
                      ? Color(0xfff79c4f)
                      : CupertinoColors.lightBackgroundGray,
                ),
              );
            },
          ),
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
        CarouselSlider(
          viewportFraction: 0.7,
          enlargeCenterPage: true,
          onPageChanged: (index) {
            setState(() {
              _currentRecents = index;
            });
          },
          items: imgList.map((imgUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.extraLightBackgroundGray,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.fill,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Color(0xfff79c4f),
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            imgList,
            (index, url) {
              return Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentRecents == index
                      ? Color(0xfff79c4f)
                      : CupertinoColors.lightBackgroundGray,
                ),
              );
            },
          ),
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
              largeTitle: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: CupertinoColors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: _getUsername(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
                        onRefresh: _loadRecipes,
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
