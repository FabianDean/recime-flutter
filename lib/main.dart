import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:recime_flutter/pages/profile_page.dart';
import 'pages/main_page.dart';
import 'pages/welcome_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/settings/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseAuth>(
      create: (_) => FirebaseAuth.instance,
      child: CupertinoApp(
        // keep app in light theme
        theme: CupertinoThemeData(
          brightness: Brightness.light,
        ),
        title: 'ReciMe',
        home: LandingPage(),
        routes: {
          '/main': (_) => MainPage(),
          '/welcome': (_) => WelcomePage(),
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/home': (_) => HomePage(),
          '/explore': (_) => ExplorePage(),
          '/profile': (_) => ProfilePage(),
          '/settings': (_) => SettingsPage(),
        },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseAuth = Provider.of<FirebaseAuth>(context);
    return StreamBuilder<FirebaseUser>(
      stream: firebaseAuth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return WelcomePage();
          }
          return MainPage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
