import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:store_location_map/models/store_model.dart';
import 'package:store_location_map/viewmodels/storeview_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({super.key});

  @override
  State<HomeViewPage> createState() => _HomeViewPageState();
}

class _HomeViewPageState extends State<HomeViewPage> {
  GoogleMapController? _mapController;
  double _mapHeight = 400;
  final ScrollController _scrollController = ScrollController();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveCameraToStore(StoreModel store) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(store.latitude, store.longitude),
          zoom: 16.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<StoreViewModel>(context);
    var selectedStore = viewModel.selectedStore;

    return Scaffold(
      appBar: AppBar(
        title: Text("Stores"),
        backgroundColor: Colors.orange,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.axis == Axis.vertical) {
            final offset = scrollNotification.metrics.pixels;
            setState(() {
              _mapHeight = (400 - offset).clamp(250.0, 400.0);
            });
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _mapHeight,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(18.5204, 73.8567),
                    zoom: 13,
                  ),
                  markers: viewModel.stores.map((store) {
                    return Marker(
                      markerId: MarkerId(store.code),
                      position: LatLng(store.latitude, store.longitude),
                      icon: store.isNearestStore
                          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
                          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(title: store.storeLocation),
                      onTap: () {
                        viewModel.selectStore(store);
                        _moveCameraToStore(store);
                      },
                    );
                  }).toSet(),
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                ),
              ),
            ),
            if (selectedStore != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.store, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedStore.storeLocation,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                "${selectedStore.distance.toStringAsFixed(2)} km\nAway",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(selectedStore.storeAddress),
                          SizedBox(height: 6),
                          Text("Today, Thursday 12:00 PM - 11:00 PM"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final store = viewModel.stores[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.orange.shade100),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.store,
                          color: store.isNearestStore ? Colors.deepPurple : Colors.grey),
                      title: Text(
                        store.storeLocation,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.storeAddress),
                          SizedBox(height: 4),
                          Text(
                            "Distance: ${store.distance.toStringAsFixed(2)} KM\nToday, Thursday 12:00 PM - 11:00 PM",
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () async {
                        viewModel.selectStore(store);
                        await Future.delayed(Duration(milliseconds: 300));
                        _moveCameraToStore(store);
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  );
                },
                childCount: viewModel.stores.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
