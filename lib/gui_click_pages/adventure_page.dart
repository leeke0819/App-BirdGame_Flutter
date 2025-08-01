import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_games/adventure_one.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key});

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.off(() => const MainPage()),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '모험',
          style: TextStyle(
            fontFamily: 'NaverNanumSquareRound',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => const AdventureOne());
              },
              child: Container(
                width: double.infinity,
                height: 140,
                margin: const EdgeInsets.only(
                    top: 20, left: 16, right: 16, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'images/GUI/adventure1_button_GUI.png',
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.fill,
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
            const SizedBox(height: 3),
            Container(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Get.off(() => const BookPage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/book_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Get.off(() => const AdventurePage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/adventure_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Get.off(() => const ShopPage());
                        await goldModel.fetchGold();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/shop_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Get.off(() => const BagPage());
                        await goldModel.fetchGold();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/bag_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
