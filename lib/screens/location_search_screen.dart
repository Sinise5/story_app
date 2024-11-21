import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:story_app/providers/location_provider.dart';

class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {

  final TextEditingController _searchController = TextEditingController();
  late final _mapController ;


  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.getCurrentLocation();
    _mapController = MapController();
  }


  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("BACK BUTTON!"); // Do some stuff.
    context.go('/addStory');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locationProvider.currentLocation,
              initialZoom: locationProvider.currentZoom,
              onTap: (tapPosition, point) {
                locationProvider.updateMarkerPosition(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: locationProvider.markers.map((marker) {
                  return Marker(
                    point: marker,
                    child: GestureDetector(
                      onLongPress: () {
                        // Simulasi drag marker
                        locationProvider.updateMarkerPosition(marker);
                      },
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              color: Colors.white,
              child:TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Address',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  locationProvider.searchAddress(value);
                }
              },
            ),
            ),
          ),
          if (locationProvider.searchResults.isNotEmpty)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locationProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final item = locationProvider.searchResults[index];
                    return ListTile(
                      title: Text(
                        item['display_name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        final lat = double.parse(item['lat']);
                        final lon = double.parse(item['lon']);
                        locationProvider.selectAddress(lat, lon);
                        _mapController.move(
                          LatLng(lat, lon),
                          locationProvider.currentZoom,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Text(
                'Lat: ${locationProvider.currentLocation.latitude.toStringAsFixed(6)}, '
                    'Lon: ${locationProvider.currentLocation.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                final lat = locationProvider.currentLocation.latitude;
                final lon = locationProvider.currentLocation.longitude;

                debugPrint('/addStory?lat=$lat&lon=$lon');
                context.go('/addStory?lat=$lat&lon=$lon');
              },
              heroTag: "Pilih",
              child: const Icon(Icons.subdirectory_arrow_left_outlined),
            ),
          ),
          Positioned(
            top: 86,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    locationProvider.setZoom(locationProvider.currentZoom + 1);
                    _mapController.move(
                      locationProvider.currentLocation,
                      locationProvider.currentZoom,
                    );
                  },
                  heroTag: "Zoom In",
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    locationProvider.setZoom(locationProvider.currentZoom - 1);
                    _mapController.move(
                      locationProvider.currentLocation,
                      locationProvider.currentZoom,
                    );
                  },
                  heroTag: "Zoom Out",
                  child: const Icon(Icons.zoom_out),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                 // onPressed: locationProvider.getCurrentLocation,
                  onPressed: () async {
                    await context.read<LocationProvider>().getCurrentLocation();
                    _mapController.move(context.read<LocationProvider>().currentLocation, locationProvider.currentZoom);
                  },
                  heroTag: "Current Location",
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
