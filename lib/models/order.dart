enum OrderStatus { pending, accepted, inDelivery, delivered, cancelled }

class Order {
  final String id;
  final String clientId;
  final int quantity;
  final DateTime preferredDeliveryDate;
  final String deliveryAddress;
  final String? specialInstructions;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? deliveryAgentId;
  final String? deliveryAgentName;
  final double? amount;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  Order({
    required this.id,
    required this.clientId,
    required this.quantity,
    required this.preferredDeliveryDate,
    required this.deliveryAddress,
    this.specialInstructions,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.deliveryAgentId,
    this.deliveryAgentName,
    this.amount,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      quantity: json['quantity'] ?? 0,
      preferredDeliveryDate: json['preferredDeliveryDate'] != null
          ? DateTime.parse(json['preferredDeliveryDate'])
          : DateTime.now(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      specialInstructions: json['specialInstructions'],
      status: _statusFromString(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      deliveryAgentId: json['deliveryAgentId'],
      deliveryAgentName: json['deliveryAgentName'],
      amount: json['amount']?.toDouble(),
      deliveryLatitude: json['deliveryLatitude']?.toDouble(),
      deliveryLongitude: json['deliveryLongitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'quantity': quantity,
      'preferredDeliveryDate': preferredDeliveryDate.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'deliveryAgentId': deliveryAgentId,
      'deliveryAgentName': deliveryAgentName,
      'amount': amount,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
    };
  }

  static OrderStatus _statusFromString(String? status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'inDelivery':
        return OrderStatus.inDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.accepted:
        return 'Acceptée';
      case OrderStatus.inDelivery:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}
