class Client {
  final String id;
  final String phoneNumber;
  final String name;
  final String? storeName;
  final String? responsibleName;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? pinCode;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.storeName,
    this.responsibleName,
    required this.address,
    this.latitude,
    this.longitude,
    this.pinCode,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      storeName: json['storeName'],
      responsibleName: json['responsibleName'],
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      pinCode: json['pinCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'storeName': storeName,
      'responsibleName': responsibleName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pinCode': pinCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Client copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? storeName,
    String? responsibleName,
    String? address,
    double? latitude,
    double? longitude,
    String? pinCode,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      responsibleName: responsibleName ?? this.responsibleName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
