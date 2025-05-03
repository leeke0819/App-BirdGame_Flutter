import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/user.dart';

class GoldModel extends ChangeNotifier {
  int _gold = 0;
  int get gold => _gold;
  
  Future<void> fetchGold() async {
    final newGold = await fetchUserGold();
    if (newGold != null && newGold != _gold) {
      _gold = newGold;
      notifyListeners(); // UI 자동 반영
    }
  }

  void updateGold(int newGold) {
    _gold = newGold;
    notifyListeners();
  }
}