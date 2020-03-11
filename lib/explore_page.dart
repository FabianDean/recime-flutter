import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recime_flutter/recipe_page.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Firestore _dbReference = Firestore.instance;
  FirebaseUser user;
  Map<String, dynamic> _userData;
  GlobalKey _bottomSheetKey = GlobalKey();
  SolidController _bottomSheetController = SolidController();
  ScrollController _ingredientListController = ScrollController();
  ScrollController _resultsListController = ScrollController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _ingredientController = TextEditingController();
  var _ingredients = [];
  var _recipes;
  bool _searchDirect = false;
  bool _searchByIngredients = false;

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
      firebaseAuth.currentUser().then((usr) {
        user = usr;
        print("user: " + usr.uid);
        _dbReference
            .collection("users")
            .document(usr.uid)
            .get()
            .then((document) {
          print(document.data);
          setState(() {
            _userData = document.data;
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _searchDirectFunction(BuildContext context) async {
    String query = _controller.text.trim();
    if (query != "") {
      FocusScope.of(context)
          .requestFocus(new FocusNode()); // hide soft keyboard
      setState(() {
        _searchDirect = true;
        _searchByIngredients = false;
      });
      try {
        String url =
            "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/search?number=10&offset=0&query=$query";
        Map<String, String> headers = {
          "x-rapidapi-host":
              "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
          "x-rapidapi-key": DotEnv().env['RAPID_API_KEY'].toString(),
        };
        var res = await http.get(url, headers: headers);
        if (res.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(res.body);
          setState(() {
            _recipes = jsonResponse['results'];
          });
          print('Results:\n$_recipes');
        } else {
          print('Request failed with status: ${res.statusCode}.');
        }
      } catch (error) {
        print(error);
      }
      !_bottomSheetController.isOpened ? _bottomSheetController.show() : null;
    }
  }

  void _searchByIngredientsFunction(BuildContext context) async {
    if (_ingredients.length > 0) {
      FocusScope.of(context)
          .requestFocus(new FocusNode()); // hide soft keyboard
      setState(() {
        _searchByIngredients = true;
        _searchDirect = false;
      });
      String ingredients = _ingredients.join("%2C");
      ingredients = ingredients.replaceAll(RegExp(' +'), '');
      try {
        String url =
            "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients?number=10&ranking=1&ignorePantry=false&ingredients=${ingredients}";
        Map<String, String> headers = {
          "x-rapidapi-host":
              "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
          "x-rapidapi-key": DotEnv().env['RAPID_API_KEY'].toString(),
        };
        var res = await http.get(url, headers: headers);
        if (res.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(res.body);
          setState(() {
            _recipes = jsonResponse;
          });
          print('Results:\n$_recipes');
        } else {
          print('Request failed with status: ${res.statusCode}.');
        }
      } catch (error) {
        print(error);
      }
      !_bottomSheetController.isOpened ? _bottomSheetController.show() : null;
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.trim() != "") {
      _ingredients.add(_ingredientController.text.trim());
      _ingredientController.clear();
      setState(() {});
      if (_ingredients.length > 5) {
        _ingredientListController.animateTo(
            _ingredientListController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    }
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
              textInputAction: TextInputAction.search,
              controller: _controller,
              placeholder: "Search",
              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(
                  width: 1,
                  color: CupertinoColors.tertiarySystemBackground,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              onTap: () {
                if (_bottomSheetController.isOpened) {
                  _bottomSheetController.hide();
                }
              },
              onSubmitted: (value) async {
                await _searchDirectFunction(context);
              },
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.all(0),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.search,
                color: CupertinoColors.black,
                size: 26,
              ),
            ),
            onPressed: () {
              _searchDirectFunction(context);
            },
          )
        ],
      ),
    );
  }

  Widget _ingredientList(BuildContext context) {
    return ListView.separated(
      controller: _ingredientListController,
      padding: EdgeInsets.all(0),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return Dismissible(
          // Show a red background as the item is swiped away.
          background: _stackBehindDismiss(),
          direction: DismissDirection.endToStart,
          key: Key(ingredient),
          onDismissed: (direction) {
            setState(
              () {
                _ingredients.removeAt(index);
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CupertinoColors.lightBackgroundGray,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Row(
                children: <Widget>[
                  Text(
                    "•",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    ingredient,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.chevron_left,
                color: CupertinoColors.destructiveRed,
                size: 40,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: CupertinoColors.systemGrey2,
        );
      },
    );
  }

  Widget _stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget _ingredientField(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: CupertinoTextField(
        placeholder: "Ingredient",
        style: TextStyle(
          fontSize: 18,
        ),
        controller: _ingredientController,
        obscureText: false,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xfff79c4f),
          ),
          borderRadius: BorderRadius.circular(10),
          color: Color(0xfff3f3f4),
        ),
        onSubmitted: (value) {
          _addIngredient();
        },
      ),
    );
  }

  Widget _resultsList(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Text("Loading...");
          return ListView.separated(
            shrinkWrap: true,
            controller: _resultsListController,
            padding: EdgeInsets.all(5),
            itemCount: _recipes != null ? _recipes.length : 0,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];
              int totalIngredientCount = 0;
              if (!_searchDirect) {
                totalIngredientCount = recipe["usedIngredientCount"] +
                    recipe["missedIngredientCount"];
              }
              var likedRecipes = _userData["likedRecipes"];
              print(likedRecipes);
              bool liked =
                  likedRecipes.contains(recipe); // if true render solid heart
              print("liked: " + liked.toString());
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //color: CupertinoColors.lightBackgroundGray,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          "https://spoonacular.com/recipeImages/${recipe["id"]}-240x150.jpg",
                          //"https://imgur.com/a/8rY9NCb",  generic Image Not Available picture
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
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
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              recipe["title"],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _searchDirect
                                  ? "Ready in ${recipe["readyInMinutes"]} min | Serves ${recipe["servings"]}"
                                  : "${recipe["usedIngredientCount"].toString()} out of ${totalIngredientCount.toString()} ingredients",
                              maxLines: 2,
                              style: TextStyle(
                                color: Color(0xfff79c4f),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: CupertinoButton(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(0),
                    child: Icon(
                      liked ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                      color: CupertinoColors.systemRed,
                      size: 30,
                    ),
                    onPressed: () async {
                      if (liked) {
                        Firestore.instance
                            .collection('users')
                            .document(user.uid)
                            .updateData({
                          'likedRecipes': FieldValue.arrayRemove([recipe])
                        }).then((value) {
                          setState(() {
                            liked = false;
                          });
                        });
                      } else {
                        Firestore.instance
                            .collection('users')
                            .document(user.uid)
                            .updateData({
                          'likedRecipes': FieldValue.arrayUnion([recipe])
                        }).then((value) {
                          setState(() {
                            liked = true;
                          });
                        });
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => RecipePage(),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        },
      ),
    );
  }

  Widget _bottomSheetBody(BuildContext context) {
    var query;
    if (_searchDirect == false && _searchByIngredients == false) {
      query = null;
    } else if (_searchDirect == true && _searchByIngredients == false) {
      query = _controller.text;
    } else {
      query = "ingredients on hand";
    }
    return query != null
        ? Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: SingleChildScrollView(
              child: new Container(
                child: new Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 5,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Results for ",
                                  style: TextStyle(
                                      color: CupertinoColors.secondaryLabel),
                                ),
                                TextSpan(
                                  text: query.toString().trim(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xfff79c4f),
                                  ),
                                ),
                                TextSpan(
                                  text: ":",
                                  style: TextStyle(
                                      color: CupertinoColors.secondaryLabel),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _resultsList(context),
                  ],
                ),
              ),
            ),
          )
        : Container(
            color: Colors.white,
            child: Center(
              child: Text(
                "Search to view results here!",
                style: Theme.of(context).textTheme.title,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(0xfff79c4f),
        middle: _searchBar(context),
      ),
      /* use GestureDetector to remove soft keyboard when tapping anywhere outside */
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .requestFocus(new FocusNode()); // hide soft keyboard
        },
        child: SafeArea(
          /* Stack allows the SolidBottomSheet to slide over the page */
          child: Stack(
            children: [
              Container(
                /* hacky solution; needs more testing; SolidBottomSheet is displayed over Add and Search buttons */
                height: MediaQuery.of(context).size.height * 0.8 - 45,
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "What's in your kitchen?",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Material(
                        color: CupertinoColors.lightBackgroundGray,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "Ingredients",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: CupertinoColors
                                                .darkBackgroundGray,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.restaurant,
                                          color: Color(0xfff79c4f),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    _ingredients.length > 0
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: CupertinoButton(
                                              padding: EdgeInsets.all(0),
                                              child: Text("clear"),
                                              onPressed: () {
                                                setState(() {
                                                  _ingredients.clear();
                                                });
                                              },
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              Divider(
                                color: CupertinoColors.systemGrey,
                                thickness: 1,
                              ),
                              Expanded(
                                child: (_ingredients.length > 0)
                                    ? _ingredientList(context)
                                    : Center(
                                        child: Text(
                                          "Add ingredients below",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: CupertinoColors.inactiveGray,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _ingredientField(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xfff79c4f),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xfff79c4f),
                                width: 2,
                              ),
                            ),
                            child: CupertinoButton(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: () {
                                _addIngredient();
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xfff9f9f9),
                            border: Border.all(
                              color: Color(0xfff79c4f),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CupertinoButton(
                            child: Text(
                              "Search",
                              style: TextStyle(
                                color: Color(0xfff79c4f),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _searchByIngredientsFunction(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SolidBottomSheet(
                  key: _bottomSheetKey,
                  controller: _bottomSheetController,
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  headerBar: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: CupertinoColors.inactiveGray,
                      ),
                      height: 45,
                      child: Center(
                        child: Icon(
                          Icons.drag_handle,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      _bottomSheetController.isOpened
                          ? Future.delayed(
                              Duration(milliseconds: 150),
                              () {
                                _bottomSheetController.hide();
                              },
                            )
                          : Future.delayed(
                              Duration(milliseconds: 150),
                              () {
                                _bottomSheetController.show();
                              },
                            );
                    },
                  ),
                  body: _bottomSheetBody(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
