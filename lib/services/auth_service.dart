import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký tài khoản
  Future<bool> signUpWithEmailPassword(
      String email, String password, String fullName, String phoneNumber) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Lưu thông tin cá nhân vào Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      return false;
    }
  }

  // Đăng nhập
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return false;
    }
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi lấy thông tin: $e');
      return null;
    }
  }

  Future<String> getCurrentUserId() async {
    final User? user = _auth.currentUser; // Lấy người dùng hiện tại
    if (user != null) {
      return user.uid; // Trả về userId nếu người dùng tồn tại
    } else {
      throw Exception("Người dùng chưa đăng nhập!"); // Xử lý trường hợp không có user
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
