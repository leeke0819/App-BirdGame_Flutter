import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/api_book.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<dynamic>? bookData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookList();
  }

  Future<void> fetchBookList() async {
    final data = await ApiBook.getBookList();
    setState(() {
      bookData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                bookData.toString(),
              ),
            ),
    );
  }
}