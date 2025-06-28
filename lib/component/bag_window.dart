import 'package:bird_raise_app/model/bag_model.dart';
import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:provider/provider.dart';

class BagWindow extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> itemAmounts;
  final List<String> itemCodes;
  final Function(String) onFeed;

  const BagWindow({
    super.key,
    required this.imagePaths,
    required this.itemAmounts,
    required this.itemCodes,
    required this.onFeed,
  });

  @override
  State<BagWindow> createState() => _BagWindowState();
}

class _BagWindowState extends State<BagWindow> {
  int? selectedIndex;

  void _handleBackgroundTap() {
    setState(() {
      selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bagModel = context.watch<BagModel>();
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.2,
      left: MediaQuery.of(context).size.width / 2 -
          (MediaQuery.of(context).size.width * 0.6) / 2,
      child: GestureDetector(
        onTap: _handleBackgroundTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 240,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          child: GridView.builder(
            itemCount: widget.imagePaths.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Stack(
                  children: [
                    Image.asset(
                      'images/background/shop_item_background.png',
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Image.asset(
                        'images/items/${widget.imagePaths[index]}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.itemAmounts[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NaverNanumSquareRound',
                          ),
                        ),
                      ),
                    ),
                    if (selectedIndex == index)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            final response = await ApiBird.feed(widget.itemCodes[index]);
                            if (response != null) {
                              setState(() {
                                int newAmount = int.parse(widget.itemAmounts[index]) - 1;
                                if (newAmount <= 0) {
                                  widget.imagePaths.removeAt(index);
                                  widget.itemAmounts.removeAt(index);
                                  widget.itemCodes.removeAt(index);
                                  selectedIndex = null;
                                } else {
                                  widget.itemAmounts[index] = newAmount.toString();
                                }
                              });
                              //widget.onFeed(widget.itemCodes[index],response);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "주기",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
