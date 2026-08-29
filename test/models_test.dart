import 'package:flutter_test/flutter_test.dart';
import 'package:elahiversityproject/models/custom_build_state.dart';
import 'package:elahiversityproject/models/order_model.dart';
import 'package:elahiversityproject/models/pc_build_model.dart';
import 'package:elahiversityproject/models/pc_component_model.dart';

void main() {
  group('RigCraft Models & State Unit Tests', () {
    test('PcComponent JSON serialization and category parsing', () {
      final json = {
        'id': 'cpu_123',
        'category': 'cpu',
        'name': 'AMD Ryzen 7 7800X3D',
        'brand': 'AMD',
        'price': 369.99,
        'wattage': 120,
        'socket': 'AM5',
        'memoryType': 'DDR5',
        'formFactor': 'ATX',
        'specs': {'Cores': '8', 'Threads': '16'},
        'rating': 4.9,
        'reviewCount': 100,
        'imageUrl': 'https://example.com/image.png',
        'inStock': true,
        'badge': 'BESTSELLER',
      };

      final comp = PcComponent.fromJson(json, 'cpu_123');
      expect(comp.id, 'cpu_123');
      expect(comp.category, ComponentCategory.cpu);
      expect(comp.name, 'AMD Ryzen 7 7800X3D');
      expect(comp.socket, 'AM5');
      expect(comp.price, 369.99);

      final toMap = comp.toFirestore();
      expect(toMap['category'], 'cpu');
      expect(toMap['wattage'], 120);
    });

    test('CustomBuildState compatibility and wattage calculations', () {
      final state = CustomBuildState();

      final cpuAm5 = PcComponent(
        id: 'cpu_1',
        category: ComponentCategory.cpu,
        name: 'AMD Ryzen 7',
        brand: 'AMD',
        price: 300.0,
        wattage: 105,
        socket: 'AM5',
      );

      final moboLga = PcComponent(
        id: 'mobo_1',
        category: ComponentCategory.motherboard,
        name: 'Intel Z790',
        brand: 'ASUS',
        price: 200.0,
        socket: 'LGA1700',
        memoryType: 'DDR5',
      );

      state.selectComponent(cpuAm5);
      state.selectComponent(moboLga);

      expect(state.selectedCount, 2);
      expect(state.totalPrice, 500.0);
      expect(state.isFullyCompatible, false);
      expect(state.compatibilityWarnings.first, contains('Socket mismatch'));
    });

    test('OrderModel serialization and status parser', () {
      expect(OrderStatusExtension.parse('confirmed'), OrderStatus.confirmed);
      expect(OrderStatusExtension.parse('partsPicked'), OrderStatus.partsPicked);
      expect(OrderStatusExtension.parse('stressTesting'), OrderStatus.stressTesting);
      expect(OrderStatusExtension.parse('Shipped with Express Courier'), OrderStatus.shipped);
      expect(OrderStatusExtension.parse('delivered'), OrderStatus.delivered);

      final orderJson = {
        'id': 'ord_1',
        'userId': 'usr_99',
        'orderDate': 'Aug 29, 2026',
        'estimatedDelivery': 'Sep 02, 2026',
        'status': 'assembly',
        'totalAmount': 1850.50,
        'buildName': 'Pro Gaming Rig',
        'items': [
          {
            'title': 'AMD Ryzen 7',
            'subtitle': 'CPU • AMD',
            'price': 300.0,
            'quantity': 1,
          }
        ],
        'shippingAddress': 'Banani, Dhaka',
        'paymentMethod': 'Cash on Delivery',
        'trackingNumber': 'RC-2026-123456',
      };

      final order = OrderModel.fromJson(orderJson, 'ord_1');
      expect(order.id, 'ord_1');
      expect(order.userId, 'usr_99');
      expect(order.status, OrderStatus.assembly);
      expect(order.items.length, 1);
      expect(order.items.first.title, 'AMD Ryzen 7');
      expect(order.totalAmount, 1850.50);
    });

    test('PcBuildModel serialization and discount percent', () {
      final buildJson = {
        'title': 'Titan Gaming Beast',
        'tier': 'Ultimate Gaming',
        'price': 2000.0,
        'originalPrice': 2500.0,
        'rating': 4.9,
        'reviews': 30,
        'description': 'High end PC',
        'imageUrl': 'https://example.com/pc.png',
        'cpu': 'Ryzen 7',
        'gpu': 'RTX 4080',
        'ram': '32GB DDR5',
        'storage': '2TB SSD',
        'motherboard': 'X670',
        'psu': '850W',
        'cooler': '360mm AIO',
        'casing': 'NZXT H9',
        'totalWattage': 650,
        'tags': ['Gaming', '4K'],
        'badge': 'HOT DEAL',
        'isFeatured': true,
      };

      final build = PcBuildModel.fromJson(buildJson, 'build_1');
      expect(build.id, 'build_1');
      expect(build.title, 'Titan Gaming Beast');
      expect(build.discountPercent, 20.0);
    });
  });
}
