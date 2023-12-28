class Review {
  final String jobId;
  final String userId;
  final String reviewText;

  Review({
    required this.jobId,
    required this.userId,
    required this.reviewText,
  });

  // Implement toString to make it easier to print when debugging
  @override
  String toString() {
    return 'Review{jobId: $jobId, userId: $userId, reviewText: $reviewText}';
  }
}
