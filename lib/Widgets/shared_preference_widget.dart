import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceWidget {
  Future<Map<String, dynamic>> saveGoogleUserToPrefs(GoogleSignInAccount account) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'id': account.id,
      'email': account.email,
      'displayName': account.displayName,
      'photoUrl': account.photoUrl,
      'serverAuthCode': account.serverAuthCode,
    };

    await prefs.setString('googleUser', jsonEncode(userData));
    return userData;
  }

  Future<Map<String, dynamic>?> getSavedGoogleUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('googleUser');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> deleteGoogleUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    try {
      await googleSignIn.signOut();
      await prefs.remove('googleUser');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting Google user data: $e');
      }
      return false;
    }
  }

}