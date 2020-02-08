import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key key, title: "Home"}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Explore")),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SearchBar(),
              Center(child: Text("Explore Page")),
              Text("Counter: $_counter"),
              CupertinoButton(
                child: Text("+"),
                onPressed: () {
                  _increment();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  SearchBar({Key key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              placeholder: "Search",
            ),
          ),
          CupertinoButton(
            child: Icon(Icons.search),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return SolidBottomSheet(
                    minHeight: 200,
                    headerBar: Container(
                      child: Icon(Icons.arrow_upward),
                    ),
                    body: Container(
                      height: 150,
                      child: Text("San Rafael Community "),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
