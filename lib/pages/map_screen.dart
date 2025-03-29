import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final Function(String) onAddressSelected;

  MapScreen({required this.onAddressSelected});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(10.8231, 106.6297); // Vị trí mặc định: Hồ Chí Minh
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn địa chỉ'),
        actions: [
          if (_selectedAddress.isNotEmpty)
            TextButton(
              onPressed: () {
                widget.onAddressSelected(_selectedAddress);
                Navigator.pop(context);
              },
              child: Text('Xác nhận', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: (LatLng position) async {
              String address = await _getAddressFromLatLng(position);
              setState(() {
                _currentPosition = position;  // Cập nhật vị trí khi người dùng chạm vào bản đồ
                _selectedAddress = address;   // Cập nhật địa chỉ
              });
            },
          ),
          if (_selectedAddress.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  'Địa chỉ: $_selectedAddress',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    String apiKey = ""; // Thay bằng API Key của bạn
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Response data: $data");
        if (data["results"] != null && data["results"].isNotEmpty) {
          return data["results"][0]["formatted_address"];
        }
      }
      return "Không tìm thấy địa chỉ";
    } catch (e) {
      return "Lỗi khi lấy địa chỉ";
    }
  }
}
