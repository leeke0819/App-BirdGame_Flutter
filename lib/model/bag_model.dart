import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/api_bag.dart';

class BagItem {
  final String imagePath;
  final String itemName;
  final String itemDescription;
  final int amount;
  final String itemCode;

  BagItem({
    required this.imagePath,
    required this.itemName,
    required this.itemDescription,
    required this.amount,
    required this.itemCode,
  });

  factory BagItem.fromMap(Map<String, String> map) {
    return BagItem(
      imagePath: map['imagePath'] ?? '',
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      amount: int.tryParse(map['amount'] ?? '0') ?? 0,
      itemCode: map['itemCode'] ?? '',
    );
  }

  BagItem copyWith({
    int? amount,
  }) {
    return BagItem(
      imagePath: imagePath,
      itemName: itemName,
      itemDescription: itemDescription,
      amount: amount ?? this.amount,
      itemCode: itemCode,
    );
  }
}

class BagModel extends ChangeNotifier {
  List<BagItem> _items = [];
  List<BagItem> get items => List.unmodifiable(_items);

  /// 서버에서 가방 데이터를 불러와 상태를 갱신
  Future<void> fetchBag({int page = 0}) async {
    try {
      final rawItems = await fetchBagData(page: page);
      _items = rawItems.map((map) => BagItem.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('가방 데이터를 불러오는 데 실패했습니다: $e');
    }
  }

  /// 특정 아이템 수량 감소 (예: 먹이 줬을 때)
  void decreaseAmount(String itemCode, int count) {
    int index = _items.indexWhere((item) => item.itemCode == itemCode);
    if (index == -1) return;

    final item = _items[index];
    final updatedAmount = item.amount - count;

    if (updatedAmount <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(amount: updatedAmount);
    }

    notifyListeners();
  }

  /// 모든 가방 초기화
  void clear() {
    _items.clear();
    notifyListeners();
  }
}