import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key}) : super(key: key);
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final Color _mainColor = Color(0xfff79c4f);
  final GlobalKey<FormFieldState> currKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> passKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _currPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmController = new TextEditingController();
  FocusNode _currFocusNode;
  FocusNode _newFocusNode;
  FocusNode _confirmFocusNode;
  FirebaseUser _user;
  String _passwordValidator;
  bool _currObscureText = true;
  bool _newObscureText = true;
  bool _confirmObscureText = true;

  @override
  void initState() {
    super.initState();
    final firebaseAuth = Provider.of<FirebaseAuth>(
      context,
      listen: false,
    );
    firebaseAuth.currentUser().then((user) {
      _user = user;
    });
    _currFocusNode = FocusNode();
    _newFocusNode = FocusNode();
    _confirmFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _currFocusNode.dispose();
    _newFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _requestFocus(FocusNode focusNode) {
    setState(() {
      focusNode.hasFocus
          ? FocusScope.of(context).unfocus()
          : FocusScope.of(context).requestFocus(focusNode);
    });
  }

  Future<void> _sendRequest() async {
    try {
      await _user.updatePassword(_newPasswordController.text);
    } catch (error) {
      print(error);
    }
  }

  Future<String> _validateCurrentPassword(String current) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _user.email, password: current);
    } catch (error) {
      print("ERROR CODE: " + error.code);
      if (error.code == "ERROR_WRONG_PASSWORD") {
        return "Incorrect password";
      }
    }
    return null;
  }

  Widget FormUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Material(
          color: CupertinoColors.systemGroupedBackground,
          child: TextFormField(
            key: currKey,
            controller: _currPasswordController,
            focusNode: _currFocusNode,
            obscureText: _currObscureText,
            onTap: () {
              _requestFocus(_currFocusNode);
            },
            decoration: InputDecoration(
              labelText: "Current password",
              labelStyle: TextStyle(
                color: CupertinoColors.secondaryLabel,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _mainColor),
              ),
            ),
            validator: (value) {
              return _passwordValidator;
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Text(_currObscureText ? "Show" : "Hide"),
          onPressed: () {
            setState(() {
              _currObscureText = !_currObscureText;
            });
          },
        ),
        SizedBox(
          height: 20,
        ),
        Material(
          color: CupertinoColors.systemGroupedBackground,
          child: TextFormField(
            key: passKey,
            controller: _newPasswordController,
            focusNode: _newFocusNode,
            obscureText: _newObscureText,
            onTap: () {
              _requestFocus(_newFocusNode);
            },
            decoration: InputDecoration(
              labelText: "New password",
              labelStyle: TextStyle(
                color: CupertinoColors.secondaryLabel,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _mainColor),
              ),
            ),
            validator: (password) {
              var result = password.length < 6
                  ? "Password should have at least 6 characters"
                  : null;
              return result;
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Text(_newObscureText ? "Show" : "Hide"),
          onPressed: () {
            setState(() {
              _newObscureText = !_newObscureText;
            });
          },
        ),
        Material(
          color: CupertinoColors.systemGroupedBackground,
          child: TextFormField(
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            obscureText: _confirmObscureText,
            onTap: () {
              _requestFocus(_confirmFocusNode);
            },
            decoration: InputDecoration(
              labelText: "Confirm password",
              labelStyle: TextStyle(
                color: CupertinoColors.secondaryLabel,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _mainColor),
              ),
            ),
            validator: (confirmation) {
              var password = passKey.currentState.value;
              return password == confirmation ? null : "Passwords do not match";
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Text(_confirmObscureText ? "Show" : "Hide"),
          onPressed: () {
            setState(() {
              _confirmObscureText = !_confirmObscureText;
            });
          },
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
                child: Text("Change password"),
              ),
              color: _mainColor,
              onPressed: () async {
                try {
                  var response = await _validateCurrentPassword(
                      _currPasswordController.text);
                  setState(() {
                    _passwordValidator = response;
                  });
                  // check if password entered is valid
                  if (_formKey.currentState.validate()) {
                    //_sendRequest();
                  }
                } catch (e) {}
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _mainColor,
        actionsForegroundColor: CupertinoColors.black,
        middle: Text(
          "Change password",
          style: TextStyle(
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: false,
              child: FormUI(context),
            ),
          ],
        ),
      ),
    );
  }
}
