import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  GlobalKey _bottomSheetKey = GlobalKey();
  SolidController _bottomSheetController = SolidController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _ingredientController = TextEditingController();
  var _ingredients = [];

  Widget _searchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
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
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.all(0),
            child: Icon(
              Icons.search,
              color: CupertinoColors.black,
              size: 30,
            ),
            onPressed: () {
              _bottomSheetController.show();
            },
          )
        ],
      ),
    );
  }

  Widget _ingredientList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(5),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return Dismissible(
          // Show a red background as the item is swiped away.
          background: _stackBehindDismiss(),
          direction: DismissDirection.endToStart,
          key: Key(ingredient),
          onDismissed: (direction) {
            setState(() {
              _ingredients.removeAt(index);
            });
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
        return Divider();
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
      child: SafeArea(
        child: Stack(
          children: [
            Container(
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
                                children: <Widget>[
                                  Text(
                                    "Ingredients",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: CupertinoColors.darkBackgroundGray,
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
                            ),
                            Divider(
                              color: CupertinoColors.systemGrey3,
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
                              if (_ingredientController.text != "") {
                                _ingredients.add(_ingredientController.text);
                                _ingredientController.clear();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
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
                            _bottomSheetController.show();
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
                toggleVisibilityOnTap: true,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                headerBar: Container(
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
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                    ),
                  ),
                ),
                body: Container(
                  color: Colors.white,
                  child: Center(
                      child: Text(
                    "Search for a recipe to view its results!",
                    style: Theme.of(context).textTheme.title,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
