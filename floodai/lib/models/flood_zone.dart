class FloodZone {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String riskLevel; // 'High', 'Moderate', 'Low'
  final String description;
  final double? distance; // Distance from user

  FloodZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.description,
    this.distance,
  });

  factory FloodZone.fromJson(Map<String, dynamic> json) {
    return FloodZone(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      riskLevel: json['risk_level'] ?? 'Low',
      description: json['description'] ?? '',
      distance: json['distance'] != null 
          ? double.tryParse(json['distance'].toString()) 
          : null,
    );
  }
}

class Shelter {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int capacity;
  final String phone;
  final String type;
  final double? distance;

  Shelter({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.capacity,
    required this.phone,
    required this.type,
    this.distance,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      address: json['address'] ?? '',
      capacity: json['capacity'] ?? 0,
      phone: json['phone'] ?? '',
      type: json['type'] ?? 'Other',
      distance: json['distance'] != null 
          ? double.tryParse(json['distance'].toString()) 
          : null,
    );
  }
}
