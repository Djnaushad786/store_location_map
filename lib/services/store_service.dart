import 'dart:convert';

import 'package:store_location_map/models/store_model.dart';
import 'package:http/http.dart' as http;

class StoreService {

  final baseUrl = "https://podpalsapis.neosao.co.in/nearest-store";

  Future<List<StoreModel>> fetchStoreLocation()async{
    final response = await http.get(Uri.parse(baseUrl));
    final jsonData = json.decode(response.body);
    final List store = jsonData["data"];
    return store.map((e) => StoreModel.fromJson(e),).toList();
  }
}