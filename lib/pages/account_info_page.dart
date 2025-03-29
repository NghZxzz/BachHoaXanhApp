import 'package:flutter/material.dart';

class AccountInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tùy chỉnh giao diện và lấy thông tin người dùng từ Firebase tại đây
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông Tin Tài Khoản'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên người dùng: [Tên ở đây]',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: [Email ở đây]',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Số điện thoại: [Số điện thoại ở đây]',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Thêm chức năng chỉnh sửa thông tin nếu cần
              },
              child: Text('Chỉnh sửa thông tin'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
