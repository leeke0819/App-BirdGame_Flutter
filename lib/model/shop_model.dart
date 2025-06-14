import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/api_shop.dart';
import 'package:overlay_support/overlay_support.dart';

class ShopModel extends ChangeNotifier {
  int selectedQuantity = 1;
  final TextEditingController quantityController = TextEditingController();

  void showCenterToast(String message, {Color bgColor = Colors.black, Color textColor = Colors.white}) {
    showOverlay(
      (context, t) {
        return Positioned(
          top: MediaQuery.of(context).size.height / 2 - 30,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: t,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: bgColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      duration: Duration(milliseconds: 500),
    );
  }

  Future<void> handleBuyItem(BuildContext context, String itemCode, [int quantity = 1]) async {
    int result = await buyItem(itemCode, context, quantity);
    if (result == 1) {
      showCenterToast(
        "구매 완료!",
        bgColor: const Color(0xFF4CAF50),
      );
    } else {
      showCenterToast(
        "구매 실패: 골드가 부족합니다.",
        bgColor: const Color(0xFFE53935),
        textColor: Colors.white,
      );
    }
  }

  Future<void> handleSellItem(BuildContext context, String itemCode, [int quantity = 1]) async {
    int result = await sellItem(itemCode, context, quantity);
    if (result == 1) {
      showCenterToast(
        "판매 완료!",
        bgColor: const Color(0xFF4CAF50),
      );
    } else {
      showCenterToast(
        "판매 실패: 판매할 아이템이 없습니다.",
        bgColor: const Color(0xFFE53935),
        textColor: Colors.white,
      );
    }
  }

  void showQuantityDialog(BuildContext context, String itemCode, bool isBuying, Function(String, int) onBuy, Function(String, int) onSell) {
    selectedQuantity = 1;
    quantityController.text = "1";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isBuying ? '구매 수량 선택' : '판매 수량 선택',
                style: const TextStyle(
                  fontFamily: 'NaverNanumSquareRound',
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setState(() {
                              selectedQuantity--;
                              quantityController.text = selectedQuantity.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontFamily: 'NaverNanumSquareRound',
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                selectedQuantity = int.tryParse(value) ?? 1;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            selectedQuantity++;
                            quantityController.text = selectedQuantity.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: selectedQuantity.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: selectedQuantity.toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedQuantity = value.toInt();
                        quantityController.text = selectedQuantity.toString();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isBuying) {
                      onBuy(itemCode, selectedQuantity);
                    } else {
                      onSell(itemCode, selectedQuantity);
                    }
                  },
                  child: Text(
                    isBuying ? '구매' : '판매',
                    style: const TextStyle(
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }
}
