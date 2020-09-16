import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _dbReference = Firestore.instance;
  final StorageReference _storageRef = FirebaseStorage.instance.ref();
  TextEditingController _usernameContr = TextEditingController();
  TextEditingController _emailContr = TextEditingController();
  TextEditingController _passwordContr = TextEditingController();
  String _errorMessage;
  bool _obscureText = true;

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  bool _saving = false;

  Future<void> _registerEmailAndPassword() async {
    setState(() {
      _saving = true;
    });
    try {
      /* Valid username
        1) Must be between 3-20 characters
        2) Only alphanumeric values and '_' allowed
        3) Cannot start or end with '_'
        4) Cannot chain more than two '_' together
      */
      RegExp regExp =
          RegExp(r"^(?=.{3,20}$)(?![_])(?!.*[_]{3})[a-zA-Z0-9_]+(?<![_])$");
      if (!regExp.hasMatch(_usernameContr.text)) {
        _errorMessage =
            "Invalid username.\n1) Must be 3-20 characters long\n2) Only special character allowed is '_'\n3) No more than two '_' can appear together\n4) Username must not start or end with '_'";
        throw Error;
      }
      final firebaseAuth = Provider.of<FirebaseAuth>(
        context,
        listen: false,
      );
      await firebaseAuth
          .createUserWithEmailAndPassword(
        email: _emailContr.text,
        password: _passwordContr.text,
      )
          .catchError(
        (error) {
          switch (error.code) {
            case 'ERROR_EMAIL_ALREADY_IN_USE':
              _errorMessage = "This email is already in use.";
              break;
            case 'ERROR_WEAK_PASSWORD':
              _errorMessage = "Your password is too weak.";
              break;
            case 'ERROR_INVALID_EMAIL':
              _errorMessage = "Your email address appears to be invalid.";
              break;
            case "ERROR_USER_DISABLED":
              _errorMessage = "User with this email has been disabled.";
              break;
            default:
          }
        },
      );
      if (_errorMessage != null) throw Error; // skip next step if error

      FirebaseUser _user = await firebaseAuth.currentUser();
      await _dbReference.collection("users").document(_user.uid).setData(
        {
          "username": _usernameContr.text,
          "email": _user.email,
          "dateJoined": (months[_user.metadata.creationTime.month - 1] +
              " " +
              _user.metadata.creationTime.year.toString()),
          "likedRecipes": [],
          "recentRecipes": [],
          "profilePicture": "",
        },
      ).catchError((error) {
        _errorMessage = "Database error.";
      });

      _storageRef.child("users/${_user.uid}");

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

  Widget _usernameField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Username",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _usernameContr,
            obscureText: false,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
          ),
        ],
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                  filled: true))
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
              filled: true,
            ),
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

  Widget _submitButton(BuildContext context) {
    return CupertinoButton(
        onPressed: () async {
          if (_usernameContr.text != "" &&
              _emailContr.text != "" &&
              _passwordContr.text != "") {
            await _registerEmailAndPassword();
            if (_errorMessage != null) {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  duration: Duration(
                    seconds: 8,
                  ),
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
              _errorMessage = null; // reset _errorMessage for next call
            }
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
              colors: [
                Color(0xfffbb448),
                Color(0xfff7892b),
              ],
            ),
          ),
          child: Text(
            'Register',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
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
        _usernameField(),
        _emailField(),
        _passwordField(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ModalProgressHUD(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: SizedBox(),
                      ),
                      _title(),
                      SizedBox(
                        height: 10,
                      ),
                      _emailPasswordWidget(),
                      _submitButton(context),
                      Expanded(
                        flex: 2,
                        child: SizedBox(),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _loginAccountLabel(),
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  child: _backButton(),
                ),
              ],
            ),
          ),
          inAsyncCall: _saving,
        ),
      ),
    );
  }
}
