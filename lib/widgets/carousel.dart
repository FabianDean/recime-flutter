import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:recime_flutter/pages/recipe_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

/*
 * Will be used for reuse of carousel component throughout pages.
 * Cleans up code substantially by reducing file size across the board.
 * Will be fed a List and BuildContext
 */

class Carousel extends StatefulWidget {
  final BuildContext context;
  final List list;
  Carousel({Key key, @required this.list, @required this.context})
      : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _current = 0;
  final Firestore _dbRef = Firestore.instance;
  FirebaseUser _user;
  Map<String, dynamic> _userData;
  Map<String, dynamic> _likedRecipes;

  @override
  void initState() {
    super.initState();
    widget.list is List<String> ? null : _getData();
  }

  Future<void> _getData() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      // convert to async/await syntax later
      firebaseAuth.currentUser().then((user) {
        _user = user;
        _dbRef.collection("users").document(user.uid).get().then((document) {
          setState(() {
            _userData = document.data;
            _likedRecipes = Map.fromIterable(_userData["likedRecipes"],
                key: (v) => v["id"], value: (v) => v);
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future<void> _likeRecipe(dynamic recipe) async {
    bool _liked = _likedRecipes.containsKey(recipe["id"]);
    if (_liked) {
      Firestore.instance.collection('users').document(_user.uid).updateData({
        'likedRecipes': FieldValue.arrayRemove(
          [
            {
              'id': recipe["id"].toString(),
              'title': recipe["title"],
              'imageURL': recipe["imageURL"],
            },
          ],
        )
      }).then((value) {
        _dbRef.collection("users").document(_user.uid).get().then((document) {
          setState(() {
            _likedRecipes = Map.fromIterable((document.data)["likedRecipes"],
                key: (v) => v["id"], value: (v) => v);
          });
        });
      });
    } else {
      Firestore.instance.collection('users').document(_user.uid).updateData({
        'likedRecipes': FieldValue.arrayUnion(
          [
            {
              'id': recipe["id"].toString(),
              'title': recipe["title"],
              'imageURL': recipe["imageURL"],
            },
          ],
        )
      }).then((value) {
        _dbRef.collection("users").document(_user.uid).get().then((document) {
          setState(() {
            _likedRecipes = Map.fromIterable((document.data)["likedRecipes"],
                key: (v) => v["id"], value: (v) => v);
          });
        });
      });
    }
  }

  Widget build(BuildContext context) {
    return widget.list.length == 0
        ? Center(
            child: Text("No items to display."),
          )
        : Column(
            children: <Widget>[
              CarouselSlider(
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: widget.list.length > 1 ? true : false,
                onPageChanged: (index) {
                  setState(() {
                    _current = index;
                  });
                },
                items: widget.list.map((recipe) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              recipe is String ? recipe : recipe["imageURL"],
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null)
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      child,
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 55,
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10,
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: CupertinoColors
                                                .extraLightBackgroundGray,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: AutoSizeText(
                                                  recipe is String
                                                      ? "Recipe Title"
                                                      : recipe["title"],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  minFontSize: 14,
                                                  style: TextStyle(
                                                    color:
                                                        CupertinoColors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              CupertinoButton(
                                                padding: EdgeInsets.all(0),
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: CupertinoColors
                                                        .extraLightBackgroundGray,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: !(recipe is String) &&
                                                          _likedRecipes !=
                                                              null &&
                                                          _likedRecipes
                                                              .containsKey(
                                                                  recipe["id"])
                                                      ? Icon(
                                                          CupertinoIcons
                                                              .heart_solid,
                                                          color: CupertinoColors
                                                              .systemRed,
                                                          size: 30,
                                                        )
                                                      : Icon(
                                                          CupertinoIcons.heart,
                                                          color: CupertinoColors
                                                              .systemRed,
                                                          size: 30,
                                                        ),
                                                ),
                                                onPressed: () {
                                                  if (!(recipe is String))
                                                    _likeRecipe(recipe);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                      Color(0xfff79c4f),
                                    ),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        onTap: () {
                          if (!(recipe is String))
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => RecipePage(
                                  recipeID: recipe["id"],
                                ),
                              ),
                            );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: map<Widget>(
                  widget.list,
                  (index, url) {
                    return Container(
                      width: 10.0,
                      height: 10.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
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
}
