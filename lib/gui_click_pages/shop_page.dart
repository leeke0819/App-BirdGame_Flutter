import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPage();
}

class _ShopPage extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 100,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'images/GUI/gold_GUI.png',
                          width: 200,
                          height: 100,
                        ),
                        const Text(
                          '0',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 100,
                child: Image.asset(
                  'images/GUI/star_coin_GUI.png',
                  width: 200,
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 145, 238, 207)
            ),
            child: const Center(
              child: Text('상점 페이지입니다'),
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      (index * 37) % 255,
                      (index * 73) % 255, 
                      (index * 127) % 255,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blue[100],
                    child: const Center(child: Text('도감')),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green[100],
                    child: const Center(child: Text('모험')),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'images/GUI/shop_GUI.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print('가방을 클릭했습니다.');
                    },
                    child: Image.asset(
                      'images/GUI/bag_GUI.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
