import 'package:flutter/material.dart';

enum ComponentCategory {
  cpu,
  motherboard,
  gpu,
  ram,
  storage,
  psu,
  cooler,
  casing,
  fans,
}

extension ComponentCategoryExtension on ComponentCategory {
  String get displayName {
    switch (this) {
      case ComponentCategory.cpu:
        return 'Processor (CPU)';
      case ComponentCategory.motherboard:
        return 'Motherboard';
      case ComponentCategory.gpu:
        return 'Graphics Card (GPU)';
      case ComponentCategory.ram:
        return 'Memory (RAM)';
      case ComponentCategory.storage:
        return 'Storage (SSD/HDD)';
      case ComponentCategory.psu:
        return 'Power Supply (PSU)';
      case ComponentCategory.cooler:
        return 'CPU Cooler';
      case ComponentCategory.casing:
        return 'Casing / Chassis';
      case ComponentCategory.fans:
        return 'Case Fans & RGB';
    }
  }

  String get shortName {
    switch (this) {
      case ComponentCategory.cpu:
        return 'CPU';
      case ComponentCategory.motherboard:
        return 'Motherboard';
      case ComponentCategory.gpu:
        return 'GPU';
      case ComponentCategory.ram:
        return 'RAM';
      case ComponentCategory.storage:
        return 'Storage';
      case ComponentCategory.psu:
        return 'PSU';
      case ComponentCategory.cooler:
        return 'Cooler';
      case ComponentCategory.casing:
        return 'Casing';
      case ComponentCategory.fans:
        return 'Fans';
    }
  }

  IconData get icon {
    switch (this) {
      case ComponentCategory.cpu:
        return Icons.memory_rounded;
      case ComponentCategory.motherboard:
        return Icons.developer_board_rounded;
      case ComponentCategory.gpu:
        return Icons.videogame_asset_rounded;
      case ComponentCategory.ram:
        return Icons.straighten_rounded;
      case ComponentCategory.storage:
        return Icons.storage_rounded;
      case ComponentCategory.psu:
        return Icons.electric_bolt_rounded;
      case ComponentCategory.cooler:
        return Icons.ac_unit_rounded;
      case ComponentCategory.casing:
        return Icons.computer_rounded;
      case ComponentCategory.fans:
        return Icons.mode_fan_off_rounded;
    }
  }
}

class PcComponent {
  final String id;
  final ComponentCategory category;
  final String name;
  final String brand;
  final double price;
  final int wattage;
  final String socket; // e.g. "AM5", "LGA1700", "N/A"
  final String memoryType; // e.g. "DDR5", "DDR4", "N/A"
  final String formFactor; // e.g. "ATX", "Micro-ATX", "Mini-ITX"
  final Map<String, String> specs;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool inStock;
  final String? badge;

  const PcComponent({
    required this.id,
    required this.category,
    required this.name,
    required this.brand,
    required this.price,
    this.wattage = 0,
    this.socket = 'N/A',
    this.memoryType = 'N/A',
    this.formFactor = 'ATX',
    this.specs = const {},
    this.rating = 4.8,
    this.reviewCount = 50,
    this.imageUrl = '',
    this.inStock = true,
    this.badge,
  });

  static ComponentCategory parseCategory(dynamic val) {
    if (val is ComponentCategory) return val;
    if (val is int && val >= 0 && val < ComponentCategory.values.length) {
      return ComponentCategory.values[val];
    }
    final str = val?.toString().toLowerCase().trim() ?? '';
    for (var cat in ComponentCategory.values) {
      if (cat.name.toLowerCase() == str ||
          cat.shortName.toLowerCase() == str ||
          cat.displayName.toLowerCase() == str) {
        return cat;
      }
    }
    return ComponentCategory.cpu;
  }

  factory PcComponent.fromJson(Map<String, dynamic> json, [String? docId]) {
    final Map<String, String> parsedSpecs = {};
    if (json['specs'] is Map) {
      (json['specs'] as Map).forEach((k, v) {
        parsedSpecs[k.toString()] = v?.toString() ?? '';
      });
    }

    return PcComponent(
      id: docId ?? (json['id']?.toString() ?? ''),
      category: parseCategory(json['category']),
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      wattage: (json['wattage'] is num)
          ? (json['wattage'] as num).toInt()
          : int.tryParse(json['wattage']?.toString() ?? '0') ?? 0,
      socket: json['socket']?.toString() ?? 'N/A',
      memoryType: json['memoryType']?.toString() ?? 'N/A',
      formFactor: json['formFactor']?.toString() ?? 'ATX',
      specs: parsedSpecs,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      reviewCount: (json['reviewCount'] is num)
          ? (json['reviewCount'] as num).toInt()
          : int.tryParse(json['reviewCount']?.toString() ?? '50') ?? 50,
      imageUrl: json['imageUrl']?.toString() ?? '',
      inStock: json['inStock'] is bool
          ? (json['inStock'] as bool)
          : (json['inStock']?.toString().toLowerCase() != 'false'),
      badge: json['badge']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'brand': brand,
      'price': price,
      'wattage': wattage,
      'socket': socket,
      'memoryType': memoryType,
      'formFactor': formFactor,
      'specs': specs,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'badge': badge,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category.name,
      'name': name,
      'brand': brand,
      'price': price,
      'wattage': wattage,
      'socket': socket,
      'memoryType': memoryType,
      'formFactor': formFactor,
      'specs': specs,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'badge': badge,
    };
  }
}
