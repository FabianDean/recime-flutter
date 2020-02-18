import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key, title: "Settings"}) : super(key: key);

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  Widget _accountSettings() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Edit username"),
              Icon(Icons.keyboard_arrow_right),
            ],
          ),
          Divider(
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Edit email"),
              Icon(Icons.keyboard_arrow_right),
            ],
          ),
          Divider(
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Edit password"),
              Icon(Icons.keyboard_arrow_right),
            ],
          ),
          Divider(
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Edit profile picture"),
              Icon(Icons.keyboard_arrow_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signoutButton(BuildContext context) {
    return CupertinoButton(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.red, width: 2),
          color: Colors.white,
        ),
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
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
                      Navigator.of(context, rootNavigator: true).pop("Cancel");
                      _signOut();
                      // Navigator.pushReplacementNamed(
                      //     context, '/welcome');
                      // add user logout functionality
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop("Cancel");
                    },
                  )
                ],
              );
            });
        // Get.off(WelcomePage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Settings")),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
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
              _accountSettings(),
              _signoutButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
