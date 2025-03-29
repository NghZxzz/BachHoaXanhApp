import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = true; // Hiển thị trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData(); // Gọi hàm để tải dữ liệu người dùng
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm tải dữ liệu người dùng từ Firestore
  Future<void> _loadUserData() async {
    try {
      // Lấy UID của người dùng hiện tại
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Nếu người dùng chưa đăng nhập, điều hướng về trang đăng nhập
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Tải dữ liệu người dùng từ Firestore bằng UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData =
        userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['fullName'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không tìm thấy thông tin người dùng!'),
        ));
        Navigator.pop(context); // Quay lại nếu không tìm thấy dữ liệu
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Có lỗi xảy ra. Vui lòng thử lại!'),
      ));
      Navigator.pop(context); // Quay lại nếu có lỗi
    }
  }

  // Hàm cập nhật thông tin người dùng
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      String updatedName = _nameController.text;
      String updatedPhone = _phoneController.text;

      try {
        // Lấy UID của người dùng hiện tại
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Vui lòng đăng nhập để chỉnh sửa thông tin'),
          ));
          return;
        }

        // Cập nhật thông tin người dùng trong Firestore
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        await userRef.update({
          'fullName': updatedName,
          'phoneNumber': updatedPhone,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
        ));
        Navigator.pop(context, true); // Quay lại sau khi cập nhật thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Có lỗi xảy ra. Vui lòng thử lại!'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Thông Tin'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên người dùng
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Số điện thoại
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Nút lưu thông tin
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Lưu Thay Đổi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
