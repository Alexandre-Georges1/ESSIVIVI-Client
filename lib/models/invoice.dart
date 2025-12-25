class Invoice {
  final String id;
  final String clientId;
  final DateTime date;
  final double amount;
  final bool isPaid;
  final List<InvoiceItem> items;
  final DateTime? paidAt;

  Invoice({
    required this.id,
    required this.clientId,
    required this.date,
    required this.amount,
    required this.isPaid,
    required this.items,
    this.paidAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      amount: json['amount']?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] ?? false,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'date': date.toIso8601String(),
      'amount': amount,
      'isPaid': isPaid,
      'items': items.map((item) => item.toJson()).toList(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}

class InvoiceItem {
  final String orderId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime deliveryDate;

  InvoiceItem({
    required this.orderId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.deliveryDate,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      orderId: json['orderId'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'deliveryDate': deliveryDate.toIso8601String(),
    };
  }
}
