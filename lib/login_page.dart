import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color _mainColor = Color(0xfff79c4f);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _emailContr = TextEditingController();
  TextEditingController _passwordContr = TextEditingController();
  bool _saving = false;
  bool _obscureText = true;
  String _errorMessage;

  Future<void> _signInEmailAndPassword() async {
    setState(() {
      _saving = true;
    });
    try {
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: _emailContr.text,
        password: _passwordContr.text,
      )
          .catchError(
        (error) {
          switch (error.code) {
            case "ERROR_USER_NOT_FOUND":
              _errorMessage = "User not found. Check email again.";
              break;
            case "ERROR_WRONG_PASSWORD":
              _errorMessage = "Incorrect password.";
              break;
            case "ERROR_INVALID_EMAIL":
              _errorMessage = "Your email address appears to be invalid.";
              break;
            case "ERROR_USER_DISABLED":
              _errorMessage = "User with this email has been disabled.";
              break;
            default:
          }
        },
      );

      if (_errorMessage != null) throw Error;

      Navigator.pop(context);
    } catch (e) {
      print(_errorMessage != null ? _errorMessage : e);
    }
    setState(() {
      _saving = false;
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Email",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _emailContr,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _passwordContr,
            obscureText: _obscureText,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                _obscureText ? "Show" : "Hide",
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CupertinoButton(
        onPressed: () async {
          await _signInEmailAndPassword();
          if (_errorMessage != null) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _errorMessage,
                    ),
                  ],
                ),
              ),
            );
            _errorMessage = null;
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)],
            ),
          ),
          child: Container(
            height: 25,
            child: Text(
              'Login',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ));
  }

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => RegisterPage()));
            },
            child: Text(
              'Register',
              style: TextStyle(
                  color: _mainColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return ClipRRect(
      child: Align(
        heightFactor: 0.4,
        widthFactor: 0.7,
        child: Image.asset(
          "assets/icon/icon.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _emailField(),
        _passwordField(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: SizedBox(),
                          ),
                          _title(),
                          SizedBox(
                            height: 10,
                          ),
                          _emailPasswordWidget(),
                          SizedBox(
                            height: 10,
                          ),
                          _submitButton(),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: CupertinoButton(
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  final firebaseAuth =
                                      Provider.of<FirebaseAuth>(
                                    context,
                                    listen: false,
                                  );
                                  await firebaseAuth.sendPasswordResetEmail(
                                    email: _emailContr.text,
                                  );
                                  // on success
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              "Check your email to reset password"),
                                        ],
                                      ),
                                    ),
                                  );
                                } catch (error) {
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            error.code == "ERROR_USER_NOT_FOUND"
                                                ? "No user found with that email"
                                                : "Invalid email",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _createAccountLabel(),
                    ),
                    Positioned(
                      top: 5,
                      left: 0,
                      child: _backButton(),
                    ),
                  ],
                ),
              ),
            ),
            inAsyncCall: _saving,
          ),
        ),
      ),
    );
  }
}
