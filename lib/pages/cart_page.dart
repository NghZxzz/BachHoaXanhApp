import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm FirebaseAuth để lấy userId
import '../providers/cart_provider.dart';
import 'map_screen.dart';
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}
class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hiển thị Dialog để thanh toán
  Future<void> _showCheckoutDialog(BuildContext context, CartProvider cartProvider) async {
    final TextEditingController addressController = TextEditingController();
    String paymentMethod = "Thanh toán trực tiếp"; // Mặc định là trực tiếp

    // Lấy thông tin người dùng từ Firebase (giả sử bạn đã có AuthService)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần đăng nhập để thanh toán!')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final fullName = userDoc['fullName'] ?? '';
    final phoneNumber = userDoc['phoneNumber'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Thông tin thanh toán'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Họ và tên: $fullName'),
                Text('Số điện thoại: $phoneNumber'),
                SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ giao hàng',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String? selectedAddress = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          onAddressSelected: (String address) {
                            setState(() {
                              addressController.text = address;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Text('Chọn trên bản đồ'),
                ),
                SizedBox(height: 10),
                Text('Phương thức thanh toán:'),
                ListTile(
                  title: Text('Thanh toán trực tiếp'),
                  leading: Radio<String>(
                    value: "Thanh toán trực tiếp",
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      paymentMethod = value!;
                      Navigator.of(dialogContext).pop(); // Đóng dialog cũ
                      _showCheckoutDialog(context, cartProvider); // Hiển thị lại với giá trị mới
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'Thanh toán online',
                    style: TextStyle(
                      color:  Colors.grey,
                    ),
                  ),
                  leading: Radio<String>(
                    value: "Thanh toán online",
                    groupValue: paymentMethod,
                    onChanged: null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng!')),
                  );
                  return;
                }

                // Lưu thông tin hóa đơn vào Firebase
                final invoiceData = {
                  'userId': user.uid, // Lấy userId là ID của tài liệu người dùng
                  'fullName': fullName,
                  'phoneNumber': phoneNumber,
                  'address': addressController.text,
                  'paymentMethod': paymentMethod,
                  'totalPrice': cartProvider.totalPrice,
                  'items': cartProvider.cartItems.map((item) {
                    return {
                      'name': item['name'],
                      'imageUrl': item['imageUrl'],
                      'quantity': item['quantity'],
                      'price': item['price'],
                    };
                  }).toList(),
                  'createdAt': FieldValue.serverTimestamp(),
                };

                await _firestore.collection('invoices').add(invoiceData);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thanh toán thành công!')),
                );

                cartProvider.clearCart(); // Xóa giỏ hàng sau khi thanh toán
                Navigator.of(dialogContext).pop();// Đóng dialog
                Navigator.pop(context, true);
              },
              child: Text('Thanh Toán'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ Hàng'),
        backgroundColor: Colors.green,
      ),
      body: cartProvider.cartItems.isEmpty
          ? Center(
        child: Text(
          'Giỏ hàng trống',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : Column(
        children: [
          Text(
            'Danh Sách Sản Phẩm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['imageUrl'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${item['price']} VND x ${item['quantity']}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.redAccent),
                          onPressed: () {
                            if (item['quantity'] > 1) {
                              cartProvider.updateQuantity(item['id'], item['quantity'] - 1);
                            }
                          },
                        ),
                        Text(
                          '${item['quantity']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            cartProvider.updateQuantity(item['id'], item['quantity'] + 1);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            cartProvider.removeFromCart(item['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã xóa "${item['name']}" khỏi giỏ hàng!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền: ${cartProvider.totalPrice} VND',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: cartProvider.cartItems.isEmpty
                      ? null
                      : () {
                    _showCheckoutDialog(context, cartProvider);
                  },
                  child: Text('Thanh Toán'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
