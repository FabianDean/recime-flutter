import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage extends StatefulWidget {
  final String imagePath;
  PreviewPage({Key key, @required this.imagePath}) : super(key: key);

  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
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
          middle: Text(
            "Preview",
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  child: widget.imagePath == null
                      ? Text("Nothing to show")
                      : Image.file(
                          File(widget.imagePath),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
