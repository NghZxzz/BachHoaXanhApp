import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  final Map<String, dynamic> order;

  // Constructor nhận thông tin hóa đơn
  OrderPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Hóa Đơn'), // Sử dụng id thay vì orderId
        backgroundColor: Color(0xFF7AC142), // Màu sắc tương tự Bách Hóa Xanh
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card chứa thông tin người nhận
            Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Thông tin người nhận:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tên người nhận: ${order['fullName'] ?? 'Không có tên người nhận'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Số điện thoại: ${order['phoneNumber'] ?? 'Không có số điện thoại'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Địa chỉ: ${order['address'] ?? 'Không có địa chỉ'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Phương thức thanh toán: ${order['paymentMethod'] ?? 'Không có phương thức thanh toán'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // Card chứa danh sách sản phẩm và tổng tiền
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề danh sách sản phẩm
                    Text(
                      'Danh Sách Sản Phẩm:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    // Hiển thị danh sách sản phẩm
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order['items'].map<Widget>((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Hình ảnh sản phẩm
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item['imageUrl'] ?? ''),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Tên và thông tin sản phẩm
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'Tên sản phẩm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Số lượng: ${item['quantity']} - Giá: ${item['price']} VNĐ',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    // Tổng tiền
                    Text(
                      'Tổng Tiền: ${order['totalPrice']} VNĐ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7AC142), // Màu xanh Bách Hóa Xanh
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Nút quay lại trang trước
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Quay lại trang trước
              },
              child: Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF7AC142),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
