import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/flood_zone.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LatLng? userLocation;
  bool isLoading = true;
  List<FloodZone> floodZones = [];
  List<Shelter> shelters = [];
  FloodZone? selectedZone;
  bool showShelters = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadFloodZones();
  }

  Future<void> _initializeLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
      // Don't move map here, let it happen after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userLocation != null && mounted) {
          mapController.move(userLocation!, 12);
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  void _loadFloodZones() async {
    try {
      final zones = await ApiService.getFloodZones();
      final sheltersList = await ApiService.getShelters();
      setState(() {
        floodZones = zones;
        shelters = sheltersList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return Colors.red;
      case 'Moderate':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FloodAi Map'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital),
            tooltip: 'Toggle Shelters',
            onPressed: () {
              setState(() => showShelters = !showShelters);
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (!isLoading && userLocation != null) {
                mapController.move(userLocation!, 12);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userLocation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Unable to get your location'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeLocation,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: userLocation ?? const LatLng(51.5, -0.09),
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    CircleLayer(
                      circles: [
                        for (var zone in floodZones)
                          CircleMarker(
                            point: LatLng(zone.latitude, zone.longitude),
                            radius: 30,
                            color: _getRiskColor(zone.riskLevel)
                                .withOpacity(0.3),
                            borderColor: _getRiskColor(zone.riskLevel),
                            borderStrokeWidth: 2,
                          ),
                      ],
                    ),
                    // User location marker
                    MarkerLayer(
                      markers: [
                        if (userLocation != null)
                          Marker(
                            point: userLocation!,
                            width: 40,
                            height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        // Flood zone markers
                        ...floodZones.map(
                          (zone) => Marker(
                            point: LatLng(zone.latitude, zone.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedZone = zone);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getRiskColor(zone.riskLevel),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Bottom info card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildInfoCard(),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedZone != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getRiskColor(selectedZone!.riskLevel),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedZone!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Risk Level: ${selectedZone!.riskLevel}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getRiskColor(selectedZone!.riskLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedZone!.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to safety routes
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text('Find Safe Routes'),
                ),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tap on a flood zone marker to see details',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => selectedZone = null);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}