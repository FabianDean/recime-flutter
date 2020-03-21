import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PostPreviewPage extends StatefulWidget {
  final File image;
  PostPreviewPage({Key key, @required this.image}) : super(key: key);

  _PostPreviewPageState createState() => _PostPreviewPageState();
}

class _PostPreviewPageState extends State<PostPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Center(
            child: Container(
              height: 400,
              width: 400,
              child: widget.image == null
                  ? Text("Nothing selected")
                  : Image.file(
                      widget.image,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
