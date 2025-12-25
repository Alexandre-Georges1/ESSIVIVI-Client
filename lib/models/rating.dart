class Rating {
  final String id;
  final String orderId;
  final String clientId;
  final int stars;
  final String? comment;
  final String? problem;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.stars,
    this.comment,
    this.problem,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      clientId: json['clientId'] ?? '',
      stars: json['stars'] ?? 0,
      comment: json['comment'],
      problem: json['problem'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'clientId': clientId,
      'stars': stars,
      'comment': comment,
      'problem': problem,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
