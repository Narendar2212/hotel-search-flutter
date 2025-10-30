// main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pip_demo/Widgets/shared_preference_widget.dart';
import 'UI_Screens/home_screen.dart';
import 'UI_Screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final user = await SharedPreferenceWidget().getSavedGoogleUser();
  runApp(MyApp(
    isUserSignedIn: user != null,
    savedUser: user,
  ));
}

class MyApp extends StatelessWidget {
  final bool isUserSignedIn;
  final Map<String, dynamic>? savedUser;

  const MyApp({
    super.key,
    required this.isUserSignedIn,
    this.savedUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: isUserSignedIn
          ? HomePage(savedUser: savedUser!)
          : const GoogleSignInPage(),
    );
  }
}
