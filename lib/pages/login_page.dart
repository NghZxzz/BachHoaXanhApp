import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Đảm bảo đường dẫn đúng
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF008947), Color(0xFF00663F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Image.asset(
                    'assets/bhx_logo.png', // Đường dẫn logo
                    height: 100,
                  ),
                ),
                // Form Đăng Nhập
                _buildForm(context),
                SizedBox(height: 20),
                // Nút Đăng Nhập
                ElevatedButton(
                  onPressed: () async {
                    bool success = await AuthService().signInWithEmailPassword(
                      emailController.text,
                      passwordController.text,
                    );
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đăng nhập thất bại!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                  child: Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Liên kết đến trang Đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Độ trong suốt cho toàn form
        borderRadius: BorderRadius.circular(25), // Bo góc của form
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn trái tất cả tiêu đề
        children: [
          // Tiêu đề và trường nhập Email
          _buildFieldWithLabel(
            label: 'Email',
            controller: emailController,
            icon: Icons.email,
            obscureText: false,
          ),
          SizedBox(height: 20),
          // Tiêu đề và trường nhập Mật khẩu
          _buildFieldWithLabel(
            label: 'Mật khẩu',
            controller: passwordController,
            icon: Icons.lock,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool obscureText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn trái tiêu đề
      children: [
        // Tiêu đề
        Text(
          label,
          style: TextStyle(
            color: Colors.white, // Màu chữ tiêu đề
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8), // Khoảng cách giữa tiêu đề và ô nhập liệu
        // Trường nhập liệu
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5), // Độ trong suốt của trường nhập
            borderRadius: BorderRadius.circular(15), // Bo góc trường nhập
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              prefixIcon: Icon(icon, color: Colors.green.shade700),
              border: InputBorder.none, // Ẩn viền ngoài
            ),
          ),
        ),
      ],
    );
  }
}
