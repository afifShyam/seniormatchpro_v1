class Location {
  final String jobId;
  final String userId;
  final double latitude;
  final double longitude;

  Location(
      {
      required this.jobId,
      required this.userId,
      required this.latitude,
      required this.longitude
});

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude
    };
  }

  @override
  String toString() {
    return 'Location{jobId: $jobId, userId: $userId, latitude: $latitude, longitude: $longitude}';
  }
}
