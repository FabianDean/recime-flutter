import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/carousel.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _mainColor = Color(0xfff79c4f);
  final StorageReference _storageRef = FirebaseStorage.instance.ref();
  final Firestore _dbRef = Firestore.instance;
  Map<String, dynamic> _userData;
  String _profileImageURL;
  int _postedRecipes = 0;
  RefreshController _refreshController = RefreshController();
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
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      firebaseAuth.currentUser().then((user) {
        _dbRef
            .collection("users")
            .document(user.uid)
            .get()
            .then((document) async {
          setState(() {
            _userData = document.data;
          });
        });
        _storageRef
            .child("${user.uid}_profile.jpg")
            .getDownloadURL()
            .then((url) {
          setState(() {
            _profileImageURL = url;
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _loadRecipes() async {
    print("Loading recipes in ProfilePage");
    await Future.delayed(Duration(milliseconds: 500), () {});
    //_refreshController.refreshCompleted();
  }

  Widget _summarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: CupertinoColors.lightBackgroundGray,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _profileImageURL != null
                      ? Image.network(
                          _profileImageURL,
                          height: 80,
                          width: 80,
                          fit: BoxFit.scaleDown,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Color(0xfff79c4f),
                                ),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        )
                      : Image.asset("assets/No_Image_Available.png"),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                _userData != null ? _userData["username"] : "",
                style: TextStyle(
                  color: CupertinoColors.darkBackgroundGray,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.photo_library,
                    color: CupertinoColors.inactiveGray,
                    size: 22,
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
                            fontSize: 18,
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
                    size: 22,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: _userData != null
                              ? (_userData["likedRecipes"]).length.toString()
                              : "",
                          style: TextStyle(
                            color: _mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: (_userData != null &&
                                  (_userData["likedRecipes"]).length < 2)
                              ? " like".toUpperCase()
                              : " likes".toUpperCase(),
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
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: _userData != null ? _userData["dateJoined"] : "",
                    style: TextStyle(
                      color: _mainColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
        Carousel(
          context: context,
          list: imgList,
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
        Material(
          color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            primary: false,
            itemCount: _userData != null ? _userData["likedRecipes"].length : 0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final recipe = _userData["likedRecipes"][index];
              return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://spoonacular.com/recipeImages/${recipe["id"]}-240x150.jpg",
                      height: 60,
                      width: 50,
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
                  title: Text(
                    recipe["title"],
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _mainColor,
        middle: Text(
          _userData != null ? _userData["username"] : "",
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
      child: SafeArea(
        top: false,
        child: SmartRefresher(
          controller: _refreshController,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              _summarySection(context),
              _postsSection(context),
              SizedBox(
                height: 10,
              ),
              _likesSection(context),
              SizedBox(
                height: 15,
              ),
            ],
          ),
          onRefresh: () async {
            await _getUserData();
            _refreshController.refreshCompleted();
          },
        ),
      ),
    );
  }
}
