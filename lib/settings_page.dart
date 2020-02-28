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
  Future<void> _signOut() async {
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      await firebaseAuth.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  Widget _accountSettings(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
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
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
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
            padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
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
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
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
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop("Cancel");
                            _signOut();
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(0xfff79c4f),
        leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: RichText(
            text: TextSpan(
              text: "Done",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: RichText(
          text: TextSpan(
            text: "Settings",
            style: TextStyle(
              color: CupertinoColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                    text: "Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    )),
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
