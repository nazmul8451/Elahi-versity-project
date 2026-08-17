enum OrderStatus {
  confirmed,
  partsPicked,
  assembly,
  stressTesting,
  shipped,
  delivered,
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
    }
  }

  int get stepIndex {
    return OrderStatus.values.indexOf(this);
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
}

class OrderModel {
  final String id;
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
}
