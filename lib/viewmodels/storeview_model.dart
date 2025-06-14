import 'package:flutter/material.dart';
import 'package:store_location_map/models/store_model.dart';
import 'package:store_location_map/services/store_service.dart';

class StoreViewModel with ChangeNotifier {
  final StoreService _storeService = StoreService();

  List<StoreModel> _store = [];
  bool _isLoading = false;
  StoreModel? _selectedStore;

  List<StoreModel> get stores => _store;
  bool get isLoading => _isLoading;
  StoreModel? get selectedStore => _selectedStore;

  Future<void> loadStore() async {

    _isLoading = true;
    notifyListeners();

    _store = await _storeService.fetchStoreLocation();

    _isLoading = false;
    notifyListeners();
  }

  void selectStore(StoreModel store) {
    _selectedStore = store;
    notifyListeners();
  }
}
