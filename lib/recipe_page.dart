import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipePage extends StatefulWidget {
  RecipePage({Key key, title: "Recipe"}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool _liked = false;

  void _likeRecipe() async {
    return Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _liked = !_liked;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: Color(0xfff79c4f),
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
              onPressed: () {},
            ),
            largeTitle: Text(
              "Chicken Soup",
              style: TextStyle(
                color: CupertinoColors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                right: 10,
                              ),
                              child: CupertinoButton(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors
                                        .extraLightBackgroundGray,
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
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "IMAGE",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 10,
                          top: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /**
                           * Row with "Ready In" and "Yields" 
                           * */
                            Padding(
                              padding: EdgeInsets.only(
                                top: 15,
                                bottom: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "30 min",
                                              style: TextStyle(
                                                color: Color(0xfff79c4f),
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
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "4 servings",
                                              style: TextStyle(
                                                color: Color(0xfff79c4f),
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
                            /**
                           * Ingredients section
                           */
                            Text(
                              "Ingredients",
                              style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(
                                top: 5,
                                bottom: 10,
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoColors.lightBackgroundGray,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Chicken broth",
                                    style: TextStyle(
                                      color: CupertinoColors.darkBackgroundGray,
                                    ),
                                  ),
                                  Text(
                                    "4 cups",
                                    style: TextStyle(
                                      color: Color(0xfff79c4f),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /**
                           * Directions section
                           */
                            Text(
                              "Directions",
                              style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 5,
                                bottom: 10,
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoColors.lightBackgroundGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}