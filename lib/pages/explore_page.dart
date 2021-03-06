import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recime_flutter/pages/recipe_page.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Color _mainColor = Color(0xfff79c4f);
  final Firestore _dbReference = Firestore.instance;
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
  bool _loading = false;

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
        _dbReference.collection("users").document(usr.uid).get();
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _searchDirectFunction(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    String query = _controller.text.trim();
    if (query != "") {
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
            _loading = false;
          });
          await Future.delayed(
            Duration(
              milliseconds: 150,
            ),
          );
          _bottomSheetController.show();
        } else {
          print('Request failed with status: ${res.statusCode}.');
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> _searchByIngredientsFunction(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    if (_ingredients.length > 0) {
      setState(() {
        _searchByIngredients = true;
        _searchDirect = false;
      });

      String ingredients = _ingredients.join("%2C");
      ingredients = ingredients.replaceAll(
          new RegExp(r"\s+\b|\b\s"), "-"); // replace white space with "-"
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
            _loading = false;
          });
          await Future.delayed(
            Duration(
              milliseconds: 150,
            ),
          );
          _bottomSheetController.show();
        } else {
          print('Request failed with status: ${res.statusCode}.');
        }
      } catch (error) {
        print(error);
      }
    }
  }

  void _addIngredient() {
    String ingredient = _ingredientController.text.trim();
    if (ingredient != "") {
      ingredient = ingredient.replaceAll(new RegExp(r"\s+\b|\b\s"), " ");
      _ingredients.add(ingredient);
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
              onTap: () {},
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
            onPressed: () async {
              await _searchDirectFunction(context);
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
            color: _mainColor,
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
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  _mainColor,
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
                                color: _mainColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => RecipePage(
                            recipeID: _recipes[index]["id"].toString()),
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
    return ModalProgressHUD(
      child: query != null
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
                                      color: _mainColor,
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
            ),
      inAsyncCall: _loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _mainColor,
        middle: _searchBar(context),
      ),
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
                                        color: _mainColor,
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
                            color: _mainColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _mainColor,
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
                            color: _mainColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CupertinoButton(
                          child: Text(
                            "Search",
                            style: TextStyle(
                              color: _mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            await _searchByIngredientsFunction(context);
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
                body: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                    child: _bottomSheetBody(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
