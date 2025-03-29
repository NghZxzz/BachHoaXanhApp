import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'edit_profile_page.dart';
import 'blog_detail_page.dart';
import 'login_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  int _selectedIndex = 0;

  final List<String> _banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  List<Map<String, dynamic>> _blogs = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    // Quản lý tự động chuyển banner
    _currentPage = 0; // Đảm bảo trang đầu tiên là 0
    _startBannerAutoScroll(); // Gọi hàm để bắt đầu chuyển đổi banne
    _fetchBlogs();
    _fetchProducts();
    _fetchOrders();
  }

  void _startBannerAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nếu timer không được khởi tạo lại, khởi tạo lại ở đây
    if (_timer == null || !_timer!.isActive) {
      _startBannerAutoScroll(); // Khởi động lại việc tự động chuyển banner
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBlogs() async {
    List<Map<String, dynamic>> blogs = await FirestoreService().getBlogs();
    setState(() {
      _blogs = blogs;
    });
  }

  Future<void> _fetchProducts() async {
    List<Map<String, dynamic>> products = await FirestoreService().getProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _fetchOrders() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("Chưa đăng nhập");
        return;
      }

      print("Đang lấy danh sách hóa đơn cho userId: $userId");

      List<Map<String, dynamic>> orders = await FirestoreService().getInvoices(userId);

      print("Dữ liệu hóa đơn nhận được: $orders"); // In dữ liệu nhận được

      setState(() {
        _orders = orders;
      });

      print("Số đơn hàng: ${_orders.length}");
    } catch (e) {
      print("Lỗi khi lấy danh sách hóa đơn: $e");
    }
  }



  void _reloadPage() {
    setState(() {});
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Khởi tạo số lượng sản phẩm là 1
        int quantity = 1;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Chọn số lượng'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--; // Giảm số lượng
                        });
                      }
                    },
                  ),
                  Text(
                    '$quantity',
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++; // Tăng số lượng
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng hộp thoại khi nhấn Hủy
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    // Gửi sản phẩm và số lượng vào giỏ hàng
                    context.read<CartProvider>().addToCart(product, quantity: quantity);

                    // Hiển thị thông báo thêm sản phẩm thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm ${product['name']} ($quantity) vào giỏ hàng!'),
                      ),
                    );

                    Navigator.pop(context); // Đóng hộp thoại sau khi thêm
                  },
                  child: Text('Thêm vào giỏ hàng'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _logout(BuildContext context) async {
    try {
      // Gọi phương thức signOut() từ AuthService
      await AuthService().signOut();

      // Chuyển người dùng về màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Xóa tất cả các màn hình trước đó
      );
    } catch (e) {
      // Hiển thị lỗi nếu xảy ra sự cố
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng xuất thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/bhx_logo.png', // Đường dẫn tới logo
          height: 40, // Chiều cao logo
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () async {
              // Điều hướng đến CartPage và chờ giá trị trả về
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );

              // Nếu thanh toán thành công, gọi _fetchOrders()
              if (result == true) {
                _fetchOrders();
              }
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Column(
        children: [
          // Slider quảng cáo
          Container(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Bo tròn các góc
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _banners[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
// Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _banners.map((image) {
              int index = _banners.indexOf(image);
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.green
                      : Colors.black38,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Thông tin khuyến mãi:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _blogs.length,
              itemBuilder: (context, index) {
                final blog = _blogs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailPage(
                          blogId: blog['id'],
                          title: blog['title'],
                          content: blog['content'],
                          imageUrl: blog['imageUrl'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Column(
                      children: [
                        Text(
                          'Chương trình đã hết hạn',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        // Ảnh bài blog
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            blog['imageUrl'],
                            width: double.infinity,  // Đảm bảo hình ảnh chiếm toàn bộ chiều rộng
                            height: 200,  // Chiều cao cố định
                            fit: BoxFit.cover,  // Đảm bảo hình ảnh phủ toàn bộ
                            loadingBuilder: (context, child, loadingProgress) {
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
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tiêu đề bài blog
                              Text(
                                blog['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Mô tả bài blog
                              Text(
                                blog['content'].substring(0, 50) + '...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
          : _selectedIndex == 1
          ? Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Danh Sách Sản Phẩm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 sản phẩm mỗi hàng
                crossAxisSpacing: 10, // Khoảng cách giữa các cột
                mainAxisSpacing: 10, // Khoảng cách giữa các hàng
                childAspectRatio: 0.7, // Tỷ lệ chiều rộng/chiều cao của mỗi item
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh sản phẩm với kích thước đồng đều và không bị cắt
                      Container(
                        height: 150,
                        width: double.infinity, // Đảm bảo chiều rộng đầy đủ
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(product['imageUrl']),
                            fit: BoxFit.contain, // Hình ảnh sẽ vừa khung mà không bị cắt
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Tên sản phẩm với cỡ chữ lớn hơn, sử dụng Flexible để tự động co giãn
                      Flexible(
                        child: Text(
                          product['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Cỡ chữ lớn hơn
                          ),
                          overflow: TextOverflow.ellipsis, // Hiển thị tên sản phẩm nếu quá dài
                          maxLines: 2, // Giới hạn tên sản phẩm hiển thị tối đa 2 dòng
                        ),
                      ),
                      SizedBox(height: 5),
                      // Giá sản phẩm với cỡ chữ lớn hơn
                      Flexible(
                        child: Text(
                          'Giá: ${product['price']} VNĐ',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16, // Cỡ chữ lớn hơn
                          ),
                        ),
                      ),
                      Spacer(), // Giúp kéo phần nội dung lên trên
                      // Nút thêm vào giỏ hàng
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            _addToCart(product);  // Gọi phương thức _addToCart để chọn số lượng và thêm vào giỏ hàng
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      )
          : _selectedIndex == 2
          ? Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Danh Sách Đơn Hàng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];

                if (order.isEmpty) {
                  return Center(child: Text("Không có đơn hàng nào"));
                }

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mã đơn hàng
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Mã Đơn Hàng: ${order['id']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Sản phẩm trong đơn hàng
                      Column(
                        children: List.generate(order['items']?.length ?? 0, (productIndex) {
                          final product = order['items'][productIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(product['imageUrl'] ?? ''),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Tên sản phẩm',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      'Giá: ${product['price']} VNĐ',
                                      style: TextStyle(fontSize: 14, color: Colors.orange),
                                    ),
                                    Text(
                                      'Số lượng: ${product['quantity']}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tổng Tiền: ${order['totalPrice']} VNĐ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Nút xem chi tiết
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Chuyển đến OrderPage với thông tin đơn hàng
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(order: order),
                              ),
                            );
                          },
                          child: Text('Xem Chi Tiết'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )

        ],
      )
          : FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Thông tin tài khoản',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email: ${userData['email']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Họ và tên: ${userData['fullName']}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Số điện thoại: ${userData['phoneNumber']}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            bool isUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(),
                              ),
                            );
                            if (isUpdated) {
                              _reloadPage();
                            }
                          },
                          child: Text('Chỉnh Sửa Thông Tin'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(height: 10), // Khoảng cách giữa hai nút
                        ElevatedButton(
                          onPressed: () async {
                            await _logout(context);
                          },
                          child: Text('Đăng xuất'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('Không tìm thấy thông tin người dùng.'));
          }
        },
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Đặt Hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), // Biểu tượng đơn hàng
            label: 'Đơn Hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài Khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
