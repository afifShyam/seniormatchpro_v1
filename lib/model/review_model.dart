class Review {
  final String jobId;
  final String userId;
  final String reviewText;
  final String status;
  final double rating;

  Review(
      {required this.jobId,
      required this.userId,
      required this.reviewText,
      required this.status,
      required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'reviewText': reviewText,
      'status': status,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'Review{jobId: $jobId, userId: $userId, reviewText: $reviewText, status: $status}';
  }
}
