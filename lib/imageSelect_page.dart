import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'postPreview_page.dart';

class ImageSelectPage extends StatefulWidget {
  ImageSelectPage({Key key}) : super(key: key);

  @override
  _ImageSelectPageState createState() => _ImageSelectPageState();
}

class _ImageSelectPageState extends State<ImageSelectPage> {
  Future _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null)
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => PostPreviewPage(image: image),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Text(
          "Photo",
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              color: Colors.black,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CupertinoButton(
                              child: Icon(
                                Icons.filter,
                                color: CupertinoColors.inactiveGray,
                                size: 30,
                              ),
                              onPressed: () async {
                                await _getImage(ImageSource.gallery);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: CupertinoButton(
                              child: Icon(
                                CupertinoIcons.circle,
                                color: CupertinoColors.inactiveGray,
                                size: 70,
                              ),
                              onPressed: () async {
                                await _getImage(ImageSource.camera);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
