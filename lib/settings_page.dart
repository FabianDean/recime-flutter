import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, title: "Settings"}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _counter = 0;

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Settings")),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Center(child: Text("Settings Page")),
              Text("Counter: $_counter"),
              CupertinoButton(
                child: Text("+"),
                onPressed: () {
                  _increment();
                },
              ),
              CupertinoButton(
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
        ),
      ),
    );
  }
}
