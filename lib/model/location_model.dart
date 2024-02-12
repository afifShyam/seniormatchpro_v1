class LocationModel {
  final String userId;
  final double latitude;
  final double longitude;

  LocationModel(
      {required this.userId, required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'latitude': latitude, 'longitude': longitude};
  }

  @override
  String toString() {
    return 'Location{ userId: $userId, latitude: $latitude, longitude: $longitude}';
  }
}
