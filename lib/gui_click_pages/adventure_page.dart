import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key});

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '모험 1',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NaverNanumSquareRound',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '모험 2',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NaverNanumSquareRound',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '모험 3',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NaverNanumSquareRound',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120),
            Expanded(
              child: Center(
                child: const Text(
                  '더 많은 모험이 준비 중입니다...',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NaverNanumSquareRound',
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
