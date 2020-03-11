import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, title: "Settings"}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _errorMessage;

  Future<void> _signOut() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      await firebaseAuth.signOut().catchError((error) {
        _errorMessage = "Error signing out";
      });

      if (_errorMessage != null) throw Error;
    } catch (e) {
      print(_errorMessage != null ? _errorMessage : e);
    }
  }

  Widget _accountSettings(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit username',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.black),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onPressed: () {},
          ),
          Divider(
            color: CupertinoColors.black,
          ),
          CupertinoButton(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit email',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.black),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onPressed: () {},
          ),
          Divider(
            color: CupertinoColors.black,
          ),
          CupertinoButton(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit password',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.black),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onPressed: () {},
          ),
          Divider(
            color: CupertinoColors.black,
          ),
          CupertinoButton(
            padding: EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit profile picture',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.black),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _signoutButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                Icon(
                  Icons.exit_to_app,
                  color: CupertinoColors.destructiveRed,
                ),
              ],
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text("Logout"),
                      content: Text("\nAre you sure you want to logout?"),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: Text("Logout"),
                          onPressed: () async {
                            Navigator.of(context, rootNavigator: true)
                                .pop("Cancel");
                            await _signOut();
                            if (_errorMessage != null) {
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Error signing out."),
                                    ],
                                  ),
                                ),
                              );
                              _errorMessage = null;
                            }
                          },
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop("Cancel");
                          },
                        )
                      ],
                    );
                  });
              // Get.off(WelcomePage());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: _scaffoldKey,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(0xfff79c4f),
        leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text(
            "Done",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Text.rich(
                  TextSpan(
                      text: "Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      )),
                ),
              ),
              _accountSettings(context),
              SizedBox(height: 20),
              _signoutButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
