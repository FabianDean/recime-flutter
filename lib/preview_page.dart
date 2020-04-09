import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage extends StatefulWidget {
  final String imagePath;
  PreviewPage({Key key, @required this.imagePath}) : super(key: key);

  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Color _mainColor = Color(0xfff79c4f);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await File(widget.imagePath)
            .delete(); // delete image capture before user goes back
        return true;
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(
            start: 0,
            top: 0,
            end: 20,
            bottom: 0,
          ),
          backgroundColor: _mainColor,
          actionsForegroundColor: CupertinoColors.black,
          leading: CupertinoButton(
            padding: EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Text(
            "New Post",
            style: TextStyle(
              color: CupertinoColors.white,
            ),
          ),
          trailing: CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Text("Share",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      content: Text("Nice post!"),
                      actions: <Widget>[
                        CupertinoButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 20,
                    ),
                    height: MediaQuery.of(context).size.width * 0.9,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.imagePath == null
                          ? Text("Nothing to show")
                          : Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                ),
                Text(
                  "Title",
                  style: TextStyle(
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
