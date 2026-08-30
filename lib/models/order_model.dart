enum OrderStatus {
  confirmed,
  partsPicked,
  assembly,
  stressTesting,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get title {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.partsPicked:
        return 'Parts Picked & Verified';
      case OrderStatus.assembly:
        return 'Custom Assembly & Wiring';
      case OrderStatus.stressTesting:
        return 'BIOS & 24h Stress Testing';
      case OrderStatus.shipped:
        return 'Shipped with Express Courier';
      case OrderStatus.delivered:
        return 'Delivered & Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    if (this == OrderStatus.cancelled) return -1;
    return OrderStatus.values.indexOf(this);
  }

  static OrderStatus parse(dynamic val) {
    if (val is OrderStatus) return val;
    if (val is int && val >= 0 && val < OrderStatus.values.length) {
      return OrderStatus.values[val];
    }
    final str = val?.toString().toLowerCase().trim() ?? '';
    for (var s in OrderStatus.values) {
      if (s.name.toLowerCase() == str || s.title.toLowerCase() == str) {
        return s;
      }
    }
    if (str.contains('cancel')) return OrderStatus.cancelled;
    if (str.contains('deliv') || str.contains('complete')) return OrderStatus.delivered;
    if (str.contains('ship')) return OrderStatus.shipped;
    if (str.contains('stress') || str.contains('test')) return OrderStatus.stressTesting;
    if (str.contains('assem') || str.contains('process')) return OrderStatus.assembly;
    if (str.contains('pick')) return OrderStatus.partsPicked;
    if (str.contains('pend') || str.contains('confirm')) return OrderStatus.confirmed;
    return OrderStatus.confirmed;
  }
}

class OrderItemModel {
  final String title;
  final String subtitle;
  final double price;
  final int quantity;
  final String iconCode;

  const OrderItemModel({
    required this.title,
    required this.subtitle,
    required this.price,
    this.quantity = 1,
    this.iconCode = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      iconCode: json['iconCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'quantity': quantity,
      'iconCode': iconCode,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

class OrderModel {
  final String id;
  final String userId;
  final String orderDate;
  final String estimatedDelivery;
  final OrderStatus status;
  final double totalAmount;
  final String buildName;
  final List<OrderItemModel> items;
  final String shippingAddress;
  final String paymentMethod;
  final String trackingNumber;

  const OrderModel({
    required this.id,
    this.userId = '',
    required this.orderDate,
    required this.estimatedDelivery,
    required this.status,
    required this.totalAmount,
    required this.buildName,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.trackingNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final List<OrderItemModel> parsedItems = [];
    if (json['items'] is List) {
      for (var item in (json['items'] as List)) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(OrderItemModel.fromJson(item));
        } else if (item is Map) {
          parsedItems.add(OrderItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return OrderModel(
      id: docId ?? (json['id']?.toString() ?? ''),
      userId: json['userId']?.toString() ?? '',
      orderDate: json['orderDate']?.toString() ?? '',
      estimatedDelivery: json['estimatedDelivery']?.toString() ?? '',
      status: OrderStatusExtension.parse(json['status']),
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      buildName: json['buildName']?.toString() ?? 'Custom Rig Build',
      items: parsedItems,
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Cash on Delivery',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderDate': orderDate,
      'estimatedDelivery': estimatedDelivery,
      'status': status.name,
      'totalAmount': totalAmount,
      'buildName': buildName,
      'items': items.map((i) => i.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'orderDate': orderDate,
      'estimatedDelivery': estimatedDelivery,
      'status': status.name,
      'totalAmount': totalAmount,
      'buildName': buildName,
      'items': items.map((i) => i.toFirestore()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
