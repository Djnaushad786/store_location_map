import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_location_map/view/home_view_page.dart';
import 'package:store_location_map/viewmodels/storeview_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StoreViewModel()..loadStore(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeViewPage(),
    );
  }
}
