import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:store_location_map/viewmodels/storeview_model.dart';
import 'package:store_location_map/models/store_model.dart';

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({super.key});

  @override
  State<HomeViewPage> createState() => _HomeViewPageState();
}

class _HomeViewPageState extends State<HomeViewPage> {
  GoogleMapController? _mapController;
  final DraggableScrollableController _draggableController = DraggableScrollableController();

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
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(16.688653, 74.272591),
              zoom: 14,
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
          ),
          if (selectedStore != null)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.28,
              left: 16,
              right: 16,
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
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, -2)),
                  ],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: viewModel.stores.length,
                  itemBuilder: (context, index) {
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
                          _moveCameraToStore(store);
                          await Future.delayed(Duration(milliseconds: 300));
                          if (_draggableController.size > 0.26) {
                            _draggableController.animateTo(
                              0.25,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
