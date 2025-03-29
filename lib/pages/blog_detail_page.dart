import 'package:flutter/material.dart';

class BlogDetailPage extends StatelessWidget {
  final String blogId;
  final String title;
  final String content;
  final String imageUrl;

  // Nhận dữ liệu từ trang HomePage
  BlogDetailPage({
    required this.blogId,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Khuyến Mãi'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(  // Bọc toàn bộ nội dung trong SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị hình ảnh bài blog sử dụng Image.network
            Image.network(
              imageUrl,
              height: 380,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(Icons.error);
              },
            ),
            SizedBox(height: 20),
            // Tiêu đề blog
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            // Nội dung chi tiết của blog, sử dụng "\n" để xuống dòng
            Text(
              content.replaceAll(r'\n', '\n'),  // Thay thế "\n" trong chuỗi
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
