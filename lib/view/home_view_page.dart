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
  StoreModel? selectedStore;

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<StoreViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Stores"),
        backgroundColor: Colors.orange,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Upper Half: Google Map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(16.688653, 74.272591),
                    zoom: 14,
                  ),
                  markers: viewModel.stores.map((e) {
                    return Marker(
                      markerId: MarkerId(e.code),
                      position: LatLng(e.latitude, e.longitude),
                      icon: e.isNearestStore
                          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
                          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(title: e.storeLocation),
                      onTap: () {
                        setState(() {
                          selectedStore = e;
                        });
                      },
                    );
                  }).toSet(),
                ),

                // Optional: Info card when marker clicked
                if (selectedStore != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 10,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                      elevation: 8,
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
                                      selectedStore!.storeLocation,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${selectedStore!.distance.toStringAsFixed(2)} km\nAway",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(selectedStore!.storeAddress),
                            SizedBox(height: 6),
                            Text("Today, Thursday 12:00 PM - 11:00 PM"),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Half: Scrollable List of Store Details
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: viewModel.stores.length,
              itemBuilder: (context, index) {
                final store = viewModel.stores[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
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
                            "Distance: ${store.distance.toStringAsFixed(2)} KM\nToday, Thursday 12:00 PM - 11:00 PM"),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      setState(() {
                        selectedStore = store;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
