  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'pages/login_page.dart';
  import 'package:provider/provider.dart';
  import 'providers/cart_provider.dart';
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MyApp(),
      ),
    );
  }

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
    }
  }
