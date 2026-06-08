import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String name = "Maria";
  String email = "maria@email.com";

  void updateProfile({
    required String newName,
    required String newEmail,
  }) {
    name = newName;
    email = newEmail;
    notifyListeners();
  }
}