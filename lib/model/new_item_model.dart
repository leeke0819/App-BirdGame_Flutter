import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewItemModel extends ChangeNotifier {
  Set<String> _newItems = {};
  Set<String> get newItems => Set.unmodifiable(_newItems);

  // 새로 획득한 아이템 추가
  void addNewItem(String itemCode) {
    _newItems.add(itemCode);
    print('새 아이템 추가: $itemCode, 현재 목록: $_newItems');
    _saveNewItems();
    notifyListeners();
  }

  // 새로 획득한 아이템 제거 (확인했을 때)
  void removeNewItem(String itemCode) {
    _newItems.remove(itemCode);
    print('새 아이템 제거: $itemCode, 현재 목록: $_newItems');
    _saveNewItems();
    notifyListeners();
  }

  // 모든 새 아이템 표시 제거
  void clearAllNewItems() {
    _newItems.clear();
    print('모든 새 아이템 제거됨');
    _saveNewItems();
    notifyListeners();
  }

  // SharedPreferences에서 새 아이템 데이터 완전 삭제
  Future<void> clearAllNewItemsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('new_items');
      _newItems.clear();
      print('SharedPreferences에서 새 아이템 데이터 완전 삭제됨');
      notifyListeners();
    } catch (e) {
      print('새 아이템 데이터 삭제 실패: $e');
    }
  }

  // 아이템이 새로 획득된 것인지 확인
  bool isNewItem(String itemCode) {
    return _newItems.contains(itemCode);
  }

  // SharedPreferences에서 새 아이템 목록 불러오기
  Future<void> loadNewItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newItemsList = prefs.getStringList('new_items') ?? [];
      _newItems = Set.from(newItemsList);
      print('새 아이템 목록 로드: $_newItems');
      notifyListeners();
    } catch (e) {
      print('새 아이템 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // SharedPreferences에 새 아이템 목록 저장
  Future<void> _saveNewItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('new_items', _newItems.toList());
    } catch (e) {
      print('새 아이템 목록을 저장하는데 실패했습니다: $e');
    }
  }
} 