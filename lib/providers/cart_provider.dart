import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0;

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    _totalPrice = _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return _totalPrice;
  }

  void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
    bool itemExists = _cartItems.any((existingItem) => existingItem['id'] == product['id']);

    if (itemExists) {
      // Nếu sản phẩm đã tồn tại, tăng số lượng theo giá trị người dùng chọn
      _cartItems.firstWhere((existingItem) => existingItem['id'] == product['id'])['quantity'] += quantity;
    } else {
      // Nếu sản phẩm chưa tồn tại, thêm sản phẩm mới với số lượng
      product['quantity'] = quantity;
      _cartItems.add(product);
    }

    notifyListeners(); // Thông báo cập nhật dữ liệu
  }


  void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity > 0) {
      _cartItems.firstWhere((item) => item['id'] == id)['quantity'] = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

