import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Thêm người dùng vào Firestore
  Future<void> addUser(String userId, String email) async {
    await _db.collection('users').doc(userId).set({
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getBlogs() async {
    try {
      // Lấy dữ liệu từ Firestore collection "blogs"
      QuerySnapshot snapshot = await _db.collection('blogs').get();

      // Chuyển dữ liệu từ Firestore thành danh sách các Map
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Lấy id của blog từ Firestore
          'title': doc['title'],
          'content': doc['content'],
          'imageUrl': doc['imageUrl'], // Lấy URL hình ảnh từ Firestore
        };
      }).toList();
    } catch (e) {
      print("Error getting blogs: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      // Truy cập vào collection "products" trên Firestore
      QuerySnapshot snapshot = await _db.collection('products').get();

      // Chuyển đổi dữ liệu thành danh sách Map
      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Lưu lại ID của sản phẩm
        return data;
      }).toList();

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Phương thức lấy blog theo ID
  Future<Map<String, dynamic>> getBlogById(String blogId) async {
    DocumentSnapshot snapshot = await _db.collection('blogs').doc(blogId).get();

    if (snapshot.exists) {
      var blogData = snapshot.data() as Map<String, dynamic>;

      // Kiểm tra trường hợp null để tránh lỗi khi sử dụng
      if (blogData['title'] == null || blogData['title'] == '') {
        throw Exception('Title is missing');
      }
      if (blogData['content'] == null || blogData['content'] == '') {
        throw Exception('Content is missing');
      }

      return blogData;
    } else {
      throw Exception('Blog not found');
    }
  }
  Future<String> getCurrentUserId() async {
    // Lấy ID của người dùng hiện tại từ AuthService (cần tích hợp)
    // Giả sử bạn đã có AuthService để quản lý người dùng
    return AuthService().getCurrentUserId();
  }

  Future<List<Map<String, dynamic>>> getInvoices(String userId) async {
    try {
      final snapshot = await _db
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print("Số lượng hóa đơn lấy được: ${snapshot.docs.length}"); // In số lượng docs nhận được

      List<Map<String, dynamic>> orders = snapshot.docs.map((doc) {
        return {
          'id': doc.id,  // Đảm bảo lấy đúng id của document
          ...doc.data() as Map<String, dynamic>, // Lấy dữ liệu của document
        };
      }).toList();

      return orders;
    } catch (e) {
      print('Lỗi khi lấy hóa đơn: $e');
      return [];
    }
  }


  // Lấy thông tin người dùng
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }
}
