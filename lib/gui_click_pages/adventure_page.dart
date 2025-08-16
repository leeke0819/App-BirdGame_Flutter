import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/model/new_item_model.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_games/adventure_one.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key});

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  late AudioPlayer buttonClickPlayer;
  late AudioPlayer errorSoundPlayer;

  @override
  void initState() {
    super.initState();
    buttonClickPlayer = AudioPlayer();
    errorSoundPlayer = AudioPlayer();
  }

  // 버튼 클릭 효과음 재생 (1초만 재생)
  Future<void> _playButtonClick() async {
    try {
      await buttonClickPlayer.play(AssetSource('sounds/button_click.wav'));
      await buttonClickPlayer.setVolume(0.5);
      
      // 1초 후에 오디오 중지
      Timer(const Duration(seconds: 1), () {
        if (buttonClickPlayer.state == PlayerState.playing) {
          buttonClickPlayer.stop();
        }
      });
    } catch (e) {
      print('버튼 클릭 효과음 재생 실패: $e');
    }
  }

  // 에러 효과음 재생
  Future<void> _playErrorSound() async {
    try {
      await errorSoundPlayer.play(AssetSource('sounds/error_or_ fail_sound.wav'));
      await errorSoundPlayer.setVolume(0.5);
    } catch (e) {
      print('에러 효과음 재생 실패: $e');
    }
  }

  @override
  void dispose() {
    buttonClickPlayer.dispose();
    errorSoundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final newItemModel = context.watch<NewItemModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _playButtonClick();
            Get.off(() => const MainPage());
          },
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
              onTap: () async {
                await _playButtonClick();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '모험 2',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NaverNanumSquareRound',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '출시 준비 중',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NaverNanumSquareRound',
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '모험 3',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NaverNanumSquareRound',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      '출시 준비 중',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NaverNanumSquareRound',
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: 0.90,
                                      heightFactor: 0.90,
                                      child: Image.asset(
                                        'images/GUI/bag_GUI.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // 새 아이템이 있을 때 표시 (bag_GUI.png 기준으로 위치)
                                    if (newItemModel.newItems.isNotEmpty)
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white, width: 1),
                                          ),
                                          child: const Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NaverNanumSquareRound',
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
