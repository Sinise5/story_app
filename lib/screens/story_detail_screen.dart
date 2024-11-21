import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:story_app/providers/map_zoom_provider.dart';
import 'package:story_app/providers/story_provider.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with SingleTickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  late double _panelHeightOpen;
  final double _panelHeightClosed = 150.0;
  late final _animatedMapController;
  LatLng currentLocation = const LatLng(0, 0);
  List<Marker> markers = [];
  String? currentAddress;
  late final _mapController;
  double _currentZoom = 15.2;
  late final screenWidth;
  late final screenHeight;

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("BACK BUTTON!"); // Do some stuff.
    context.go('/stories');
    return true;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _mapController = MapController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    _panelHeightOpen = screenHeight * 0.6;
  }


  Future<void> _getCurrentLocation() async {
    currentLocation = LatLng(-6.2574673132331, 106.99697880221206);

    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final story = storyProvider.getStoryById(widget.storyId);

    if (story != null) {

      if (story.lat != 0.0 && story.lon != 0.0) {
        currentLocation = LatLng(story.lat ?? 0.0, story.lon ?? 0.0);
        markers.add(Marker(
          point: currentLocation,
          width: screenWidth * 0.3,
          height: screenHeight * 0.16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentAddress != null)
                Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    currentAddress!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _getAddressFromLatLng(currentLocation);
                },
                child: const IgnorePointer(
                  ignoring: false,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ));
        setState(() {});
      }else{
        debugPrint('tidak ada lokasi');

      }


    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          currentAddress =
              '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final story = storyProvider.getStoryById(widget.storyId);

    debugPrint('${story?.lat}  xxx  ${story?.lon}');

    if (story == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Story Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/stories'),
          ),
        ),
        body: const Center(
          child: Text(
            'Story not found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    if(story.lat != null){
      _getCurrentLocation();
    }else{
      debugPrint('tidak ada lokasi');
    }


    Widget mapFlut = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: _currentZoom,
        onMapReady: () {
          _mapController.move(currentLocation, 15.2);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],

    );

    Widget wMapZoomIn = SizedBox(
      width: 50,
      height: 50,
      child: RawMaterialButton(
        onPressed: () {
          final mapZoomProvider = context.read<MapZoomProvider>();
          mapZoomProvider.zoomIn();

          _mapController.move(
            currentLocation,
            mapZoomProvider.currentZoom,
          );
        },
        elevation: 2.0,
        fillColor: Colors.white,
        padding: const EdgeInsets.all(7.0),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.zoom_in,
          size: 25.0,
          color: Colors.teal,
        ),
      ),
    );

    Widget wMapZoomOut = SizedBox(
      width: 50,
      height: 50,
      child: RawMaterialButton(
        onPressed: () {
          final mapZoomProvider = context.read<MapZoomProvider>();
          mapZoomProvider.zoomOut();

          _mapController.move(
            currentLocation,
            mapZoomProvider.currentZoom,
          );
        },
        elevation: 2.0,
        fillColor: Colors.white,
        padding: const EdgeInsets.all(7.0),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.zoom_out,
          size: 25.0,
          color: Colors.teal,
        ),
      ),
    );

    Widget wMapCurrent = SizedBox(
      width: 50,
      height: 50,
      child: RawMaterialButton(
        onPressed: () {
          if (_mapController != null) {
            _mapController.move(currentLocation, 15.2);
          }
        },
        elevation: 2.0,
        fillColor: Colors.white,
        padding: const EdgeInsets.all(7.0),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.location_searching,
          size: 25.0,
          color: Colors.teal,
        ),
      ),
    );

    Widget peta00 = SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 350,
                child: mapFlut,
              ),
              const SizedBox(
                height: 330,
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 5,
            child: Column(
              children: [
                wMapZoomIn,
              ],
            ),
          ),
          Positioned(
            top: 65,
            right: 5,
            child: Column(
              children: [
                wMapZoomOut,
              ],
            ),
          ),
          Positioned(
            top: 215,
            right: 5,
            child: Column(
              children: [
                // wMapCurrent,
              ],
            ),
          ),
        ],
      ),
    );

    Widget datamain = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                story.photoUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              story.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              story.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            if ((story.lat != null) || (currentAddress != null))
              Text(
                'Alamat: $currentAddress',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else
              Text(
                'Tidak ada Lokasi',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Created on: ${story.createdAt.toLocal().toString()}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    Widget slidingUpPanel = SlidingUpPanel(
      controller: _panelController,
      maxHeight: screenHeight * 1,
      minHeight: screenHeight * 0.5,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18.0),
        topRight: Radius.circular(18.0),
      ),
      panel: datamain,
      body: peta00,
    );


    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${story.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/stories'),
        ),
      ),
      body: Stack(
        children: [
          slidingUpPanel,
        ],
      ),
    );
  }
}
