import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share/share.dart';

class RecipePage extends StatefulWidget {
  final String recipeID;
  RecipePage({Key key, title: "Recipe", @required this.recipeID})
      : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final Color _mainColor = Color(0xfff79c4f);
  final Firestore _dbRef = Firestore.instance;
  FirebaseUser _user;
  Map<String, dynamic> _userData;
  Map<String, dynamic> _recipeData;

  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getRecipeData();
  }

  Future<void> _getUserData() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      firebaseAuth.currentUser().then((user) {
        _user = user;
        _dbRef
            .collection("users")
            .document(user.uid)
            .get()
            .then((document) async {
          setState(() {
            _userData = document.data;
            _liked = ((_userData["likedRecipes"]).firstWhere(
                        (itemToCheck) =>
                            itemToCheck["id"].toString() == widget.recipeID,
                        orElse: () => null)) !=
                    null
                ? true
                : false;
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getRecipeData() async {
    try {
      String url =
          "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/${widget.recipeID}/information";
      Map<String, String> headers = {
        "x-rapidapi-host":
            "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
        "x-rapidapi-key": DotEnv().env['RAPID_API_KEY'].toString(),
      };
      var res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(res.body);
        setState(() {
          _recipeData = jsonResponse;
        });
        await _addToRecents();
      } else {
        print('Request failed with status: ${res.statusCode}.');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _addToRecents() async {
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
          // delete oldest recently viewed recipe if length == 10, then add newest recent
          if ((document.data["recentRecipes"]).length == 10) {
            var oldest = (document.data["recentRecipes"]).elementAt(0);
            await _dbRef.collection('users').document(user.uid).updateData({
              'recentRecipes': FieldValue.arrayRemove([oldest]),
            });
          }

          await _dbRef.collection('users').document(user.uid).updateData({
            'recentRecipes': FieldValue.arrayUnion(
              [
                {
                  'id': _recipeData["id"].toString(),
                  'title': _recipeData["title"],
                  'imageURL': _recipeData["image"],
                },
              ],
            )
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  void _likeRecipe() async {
    if (_liked) {
      Firestore.instance.collection('users').document(_user.uid).updateData({
        'likedRecipes': FieldValue.arrayRemove(
          [
            {
              'id': _recipeData["id"].toString(),
              'title': _recipeData["title"],
              'imageURL': _recipeData["image"],
            },
          ],
        )
      }).then((value) {
        setState(() {
          _liked = false;
        });
      });
    } else {
      Firestore.instance.collection('users').document(_user.uid).updateData({
        'likedRecipes': FieldValue.arrayUnion(
          [
            {
              'id': _recipeData["id"].toString(),
              'title': _recipeData["title"],
              'imageURL': _recipeData["image"],
            },
          ],
        )
      }).then((value) {
        setState(() {
          _liked = true;
        });
      });
    }

    setState(() {
      _liked = !_liked;
    });
  }

  Widget _readyInAndYieldSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 15,
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.clock,
                color: CupertinoColors.inactiveGray,
              ),
              SizedBox(
                width: 5,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Ready in ",
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                    TextSpan(
                      text: _recipeData != null
                          ? _recipeData["readyInMinutes"].toString() + " min"
                          : "",
                      style: TextStyle(
                        color: _mainColor,
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
                Icons.restaurant,
                color: CupertinoColors.inactiveGray,
              ),
              SizedBox(
                width: 5,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Yields ",
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                    TextSpan(
                      text: _recipeData != null
                          ? _recipeData["servings"].toString() + " servings"
                          : "",
                      style: TextStyle(
                        color: _mainColor,
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

  Widget _ingredientsSection(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: CupertinoColors.lightBackgroundGray,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        itemCount: _recipeData != null
            ? (_recipeData["extendedIngredients"]).length
            : 0,
        itemBuilder: (context, index) {
          final item = _recipeData["extendedIngredients"][index];
          return ListTile(
            title: Text("• " + item["originalString"]),
          );
        },
      ),
    );
  }

  Widget _directionsSection(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: CupertinoColors.lightBackgroundGray,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        itemCount: _recipeData != null
            ? (_recipeData["analyzedInstructions"][0]["steps"]).length
            : 0,
        itemBuilder: (context, index) {
          final item = _recipeData["analyzedInstructions"][0]["steps"][index];
          return ListTile(
            leading: Text(
              (index + 1).toString(),
              style: TextStyle(
                fontSize: 18,
                color: _mainColor,
              ),
            ),
            title: Text(item["step"]),
          );
        },
      ),
    );
  }

  void _share(BuildContext context) {
    final String text = "Check out this recipe I found on ReciMe!\n" +
        _recipeData["title"] +
        "\n" +
        _recipeData["spoonacularSourceUrl"];
    final RenderBox box = context.findRenderObject();
    Share.share(text,
        subject: _recipeData["title"],
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: _mainColor,
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            leading: CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                CupertinoIcons.back,
                color: CupertinoColors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.only(
                right: 10,
              ),
              child: Icon(
                CupertinoIcons.share,
                color: CupertinoColors.black,
                size: 30,
              ),
              onPressed: () {
                _share(context);
              },
            ),
            largeTitle: Padding(
              padding: EdgeInsets.only(
                right: 5,
              ),
              child: AutoSizeText(
                _recipeData != null ? _recipeData["title"] : "",
                style: TextStyle(
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        _recipeData != null
                            ? Image.network(
                                _recipeData["image"],
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                        Color(0xfff79c4f),
                                      ),
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                "assets/No_Image_Available.png",
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 15,
                              right: 10,
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoColors.extraLightBackgroundGray,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: _liked
                                    ? Icon(
                                        CupertinoIcons.heart_solid,
                                        color: CupertinoColors.systemRed,
                                        size: 26,
                                      )
                                    : Icon(
                                        CupertinoIcons.heart,
                                        color: CupertinoColors.systemRed,
                                        size: 26,
                                      ),
                              ),
                              onPressed: () {
                                _likeRecipe();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _readyInAndYieldSection(context),
                        Text(
                          "Ingredients",
                          style: TextStyle(
                            color: CupertinoColors.darkBackgroundGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _ingredientsSection(context),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Directions",
                          style: TextStyle(
                            color: CupertinoColors.darkBackgroundGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _directionsSection(context),
                      ],
                    ),
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
