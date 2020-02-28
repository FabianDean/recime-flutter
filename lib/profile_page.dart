import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _mainColor = Color(0xfff79c4f);
  String _username;
  FirebaseUser _user;
  int _postedRecipes = 0;
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
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      firebaseAuth.currentUser().then((user) {
        //_username = user.displayName;
        setState(() {
          _user = user;
          _username = user.uid.substring(0, 15);
        });
      });
    } catch (error) {
      print(error);
    }
  }

  String _getUsername() {
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
    print("Loading recipes in ProfilePage");
    await Future.delayed(Duration(milliseconds: 500), () {});
    //_refreshController.refreshCompleted();
  }

  Widget _summarySection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.photo_library,
                color: CupertinoColors.inactiveGray,
                size: 25,
              ),
              SizedBox(
                width: 5,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "13",
                      style: TextStyle(
                        color: _mainColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: " posts".toUpperCase(),
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.heart_solid,
                color: CupertinoColors.inactiveGray,
                size: 30,
              ),
              SizedBox(
                width: 5,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "26",
                      style: TextStyle(
                        color: _mainColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: " likes".toUpperCase(),
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postsSection(BuildContext context) {
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
            "Posts",
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
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          onPageChanged: (index) {
            setState(() {
              _postedRecipes = index;
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
                              _mainColor,
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
                  color: _postedRecipes == index
                      ? _mainColor
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
            top: 15,
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
        Material(
          color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            primary: false,
            itemCount: imgList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final recipe = imgList[index];
              return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Container(
                    height: 60,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "Chicken Soup",
                  ),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Icon(
                      CupertinoIcons.heart_solid,
                      color: CupertinoColors.systemRed,
                    ),
                    onPressed: () {},
                  ));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: _mainColor,
            largeTitle: Text(
              _username == null ? "" : _getUsername(),
              style: TextStyle(
                color: CupertinoColors.white,
              ),
            ),
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
          ),
          SliverFillRemaining(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  _summarySection(context),
                  _postsSection(context),
                  SizedBox(height: 10),
                  _likesSection(context),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: CupertinoColors.inactiveGray,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Joined ",
                              style: TextStyle(
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                            TextSpan(
                              text: "August 2011",
                              style: TextStyle(
                                color: _mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
