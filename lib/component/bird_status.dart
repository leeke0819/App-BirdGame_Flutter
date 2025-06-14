import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class BirdStatus extends StatelessWidget {
  final int birdHungry;
  final int birdThirst;

  const BirdStatus({
    super.key,
    required this.birdHungry,
    required this.birdThirst,
  });

  void _checkStatus(BuildContext context) {
    if (birdHungry > 10) {
      showSimpleNotification(
        const Text(
          '새가 배불러 먹지 못합니다.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'NaverNanumSquareRound',
          ),
        ),
        background: Colors.orange,
        duration: const Duration(seconds: 2),
      );
    }
    if (birdThirst > 10) {
      showSimpleNotification(
        const Text(
          '새가 더는 목마르지 않습니다.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'NaverNanumSquareRound',
          ),
        ),
        background: Colors.blue,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 상태 체크
    _checkStatus(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 배고픔 상태 표시
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant, size: 20),
              const SizedBox(height: 4),
              SizedBox(
                height: 100,
                width: 20,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: LinearProgressIndicator(
                    value: birdHungry / 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    minHeight: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$birdHungry/10',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // 목마름 상태 표시
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, size: 20),
              const SizedBox(height: 4),
              SizedBox(
                height: 100,
                width: 20,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: LinearProgressIndicator(
                    value: birdThirst / 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$birdThirst/10',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
