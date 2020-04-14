import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePicturePage extends StatefulWidget {
  UpdatePicturePage({Key key}) : super(key: key);
  @override
  _UpdatePicturePageState createState() => _UpdatePicturePageState();
}

class _UpdatePicturePageState extends State<UpdatePicturePage> {
  final Color _mainColor = Color(0xfff79c4f);
  final Firestore _dbRef = Firestore.instance;
  FirebaseUser _user;
  File _image;
  String _profilePictureURL;
  bool _saving = false;

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
      _user = await firebaseAuth.currentUser();
      var document = await _dbRef.collection("users").document(_user.uid).get();
      setState(() {
        if ((document.data)["profilePicture"] != "")
          _profilePictureURL = (document.data)["profilePicture"];
      });
    } catch (error) {
      print(error);
    }
  }

  Widget _currentPicture(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(200),
      child: _profilePictureURL != null
          ? Image.network(
              _profilePictureURL,
              height: 250,
              fit: BoxFit.scaleDown,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      _mainColor,
                    ),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            )
          : Image.asset("assets/No_Image_Available.png"),
    );
  }

  Future<Null> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    print("IMAGE PATH: " + image.path);
    image = await ImageCropper.cropImage(
      sourcePath: image.path,
      cropStyle: CropStyle.circle,
      aspectRatio: CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop',
        toolbarColor: _mainColor,
        toolbarWidgetColor: Colors.white,
        hideBottomControls: true,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Crop',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    );
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _updatePicture() async {
    setState(() {
      _saving = true;
    });
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child("/users")
        .child(_user.uid)
        .child("profilePicture.jpg");
    final StorageUploadTask task = firebaseStorageRef.putFile(_image);
    await task.onComplete;
    String profilePictureURL = await firebaseStorageRef.getDownloadURL();

    await _dbRef
        .collection("users")
        .document(_user.uid)
        .updateData({"profilePicture": profilePictureURL});

    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _mainColor,
        actionsForegroundColor: CupertinoColors.black,
        middle: Text(
          "Update Profile Picture",
          style: TextStyle(
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: ModalProgressHUD(
        child: SafeArea(
          minimum: EdgeInsets.only(
            top: 20,
            bottom: 20,
            right: 20,
            left: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                child: _image == null
                    ? _currentPicture(context)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Image.file(
                          _image,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.7,
                      maxWidth: 600),
                  child: CupertinoButton(
                    child: Container(
                      child: Text(
                        "Take new picture",
                        style: TextStyle(
                          color: _mainColor,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await _getImage(ImageSource.camera);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.7,
                      maxWidth: 600),
                  child: CupertinoButton(
                    child: Container(
                      child: Text("Select from photos",
                          style: TextStyle(
                            color: _mainColor,
                          )),
                    ),
                    onPressed: () async {
                      await _getImage(ImageSource.gallery);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: _image != null
                    ? Container(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.7,
                            maxWidth: 600),
                        child: CupertinoButton(
                          child: Container(
                            child: Text("Update picture"),
                          ),
                          color: _mainColor,
                          onPressed: () async {
                            await _updatePicture();
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        inAsyncCall: _saving,
      ),
    );
  }
}
